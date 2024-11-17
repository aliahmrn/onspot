import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_password.dart';

class EnterCodeScreen extends StatefulWidget {
  final String email;

  const EnterCodeScreen({required this.email, super.key});

  @override
  EnterCodeScreenState createState() => EnterCodeScreenState();
}

class EnterCodeScreenState extends State<EnterCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final String _message = '';
  final bool _isLoading = false;

  void _navigateToResetPassword() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ResetPasswordScreen(
          email: widget.email,
          code: _codeController.text,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
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
                  'Enter Code',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary, // Use secondary color
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        _buildInputField('Reset Code', _codeController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _navigateToResetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(250, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('Verify Code', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        if (_message.isNotEmpty)
                          Text(
                            _message,
                            style: TextStyle(color: Colors.red),
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

  Widget _buildInputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: 'Enter the reset code',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
