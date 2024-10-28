
import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import 'register.dart'; 
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _inputController = TextEditingController(); // Changed to be more generic for input (username/email)
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _login() async {
    final String input = _inputController.text; // Use 'input' to accept both username and email
    final String password = _passwordController.text;

    // Input validation
    if (input.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username/email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      await _authService.login(input, password); // Pass 'input' instead of just 'email'

      // Navigate to Supervisor Home Screen upon successful login
      // Navigate to MainNavigator upon successful login
      Navigator.pushReplacementNamed(context, '/main-navigator');

    } catch (e) {
      // Handle exceptions with a specific message for invalid credentials
      setState(() {
        _errorMessage = e.toString() == 'Exception: Invalid login credentials.'
            ? 'Invalid login credentials.'
            : 'Failed to login: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF92AEB9),
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 60),
              Column(
                children: [
                  Text(
                    'OnSpot',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800, // ExtraBold weight
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  Text(
                    'Facility',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.w800, // ExtraBold weight
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ],
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildInputField('Username or Email', _inputController),
                      const SizedBox(height: 20),
                      _buildInputField('Password', _passwordController, obscureText: true),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(150, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign In', style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      if (_errorMessage.isNotEmpty) ...[
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 10),
                      ],
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                          );
                        },
                        child: const Text(
                          "Don't have an account? Register",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 60),
              Transform.rotate(
                angle: -90 * 3.1415926535 / 180,
                child: Image.asset(
                  'assets/images/vacuum.png',
                  height: 200,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


Widget _buildInputField(String label, TextEditingController controller, {bool obscureText = false}) {
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
          obscureText: obscureText,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), // Increase border radius for more rounded corners
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), // Apply to enabled border as well
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), // Apply to focused border
              borderSide: const BorderSide(color: Colors.black),
            ),
          ),
        ),
      ),
    ],
  );
}
}
