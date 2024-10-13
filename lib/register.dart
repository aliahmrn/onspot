import 'package:flutter/material.dart';
import 'login.dart'; 

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // New email controller
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _register() async {
    final String fullName = _fullNameController.text;
    final String email = _emailController.text; // New email field
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String phoneNumber = _phoneNumberController.text;

    // Input validation
    if (fullName.isEmpty ||
        email.isEmpty ||  // Check if email is empty
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill out all the fields';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call your registration function here
      // await _authService.register(fullName, email, username, password, phoneNumber);

      // Navigate to Login Screen upon successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to LoginScreen
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to register: ${e.toString()}';
      });
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                const Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4C7D90),
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
                        _buildInputField('Full Name', _fullNameController),
                        const SizedBox(height: 20),
                        _buildInputField('Email', _emailController), // New email field
                        const SizedBox(height: 20),
                        _buildInputField('Username', _usernameController),
                        const SizedBox(height: 20),
                        _buildInputField('Password', _passwordController, obscureText: true),
                        const SizedBox(height: 20),
                        _buildInputField('Confirm Password', _confirmPasswordController, obscureText: true),
                        const SizedBox(height: 20),
                        _buildInputField('Phone Number', _phoneNumberController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register, // Disable button while loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Register', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        if (_errorMessage.isNotEmpty) ...[
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 10),
                        ],
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

  Widget _buildInputField(String label, TextEditingController controller, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}
