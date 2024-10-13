import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:onspot_facility/cleaner/homescreen.dart'; // Adjust the import based on your file structure
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _errorMessage = '';

  Future<void> _saveUserName(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name); // Save cleaner's name locally
  }

  Future<void> _login() async {
    final String usernameOrEmail = _usernameController.text;
    final String password = _passwordController.text;

    if (usernameOrEmail.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter all required fields';
      });
      return;
    }

    try {
      // Prepare the body for login
      final Map<String, dynamic> body = {
        'user_type': 'cleaner', // Fixed user type for cleaner login
        'password': password,
        'username': usernameOrEmail, // Always use username for cleaner
      };

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/flutterlogin'), // Your API endpoint
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(body),
      );

      // Check the response status
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final String token = data['token']; // Adjust this line based on your API response
        final String userName = data['user']['name']; // Cleaner’s name

        print('Login successful, token: $token'); // Log the token for debugging

        // Save token securely
        await _authService.saveToken(token, data['role']); // Updated to save token

        // Save the cleaner's name locally
        await _saveUserName(userName);

        // Navigate to the cleaner home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CleanerHomeScreen()), // Navigate to cleaner home screen
        );
      } else {
        // Handle error response
        setState(() {
          _errorMessage = 'Invalid credentials';
        });
      }
    } catch (e) {
      // Handle exceptions, such as network issues
      setState(() {
        _errorMessage = 'Failed to login: $e';
      });
      print('Error: $e'); // Log the error for debugging
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
                const Column(
                  children: [
                    Text(
                      'OnSpot',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C7D90),
                      ),
                    ),
                    Text(
                      'Facility',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C7D90),
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
                      children: <Widget>[
                        // Input fields for username and password
                        _buildInputField('Username', _usernameController), // Only username input
                        const SizedBox(height: 40),
                        _buildInputField('Password', _passwordController, obscureText: true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
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
                          onPressed: () {}, // Add your forgot password logic here
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
