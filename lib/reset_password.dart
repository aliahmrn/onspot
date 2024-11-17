import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/auth_service.dart';
import 'login.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({required this.email, required this.code, super.key});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  String _message = '';
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _message = 'Passwords do not match.';
        _isLoading = false;
      });
      return;
    }

    try {
      await _authService.resetPassword(
        widget.email,
        widget.code,
        _passwordController.text,
        _confirmPasswordController.text,
      );

      setState(() {
        _message = 'Your password has been reset successfully.';
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
            (route) => false,
          );
        }
      });
    } catch (e) {
      setState(() {
        _message = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme colors

    return Scaffold(
      backgroundColor: theme.primaryColor, // Set background color to primary color
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 60),
                Text(
                  'Reset Password',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary, // Use secondary color
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        _buildInputField('New Password', _passwordController, isPassword: true),
                        const SizedBox(height: 20),
                        _buildInputField('Confirm New Password', _confirmPasswordController, isPassword: true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(250, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Reset Password', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        if (_message.isNotEmpty)
                          Text(
                            _message,
                            style: TextStyle(color: _message.contains('Error') ? Colors.red : Colors.green),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: isPassword ? 'Enter your password' : 'Enter your $label',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
