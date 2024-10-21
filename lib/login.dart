import 'package:flutter/material.dart';
import 'package:onspot_facility/service/auth_service.dart';
import 'package:onspot_facility/service/attendance_service.dart'; // Import the AttendanceService
import 'cleaner/homescreen.dart';
import 'register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  late AttendanceService attendanceService; // Declare attendanceService here
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _login() async {
    final String input = _inputController.text;
    final String password = _passwordController.text;

    // Input validation
    if (input.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password';
      });
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      await _authService.login(input, password); // Perform login

      // Initialize attendanceService with the token
      final String token = await _authService.getToken();
      attendanceService = AttendanceService(token); // Store attendanceService for later use

      // Check if attendance is already submitted for today
      bool attendanceSubmitted = await attendanceService.isAttendanceSubmittedToday();

      // Navigate to Cleaner Home Screen upon successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CleanerHomeScreen(attendanceSubmitted: attendanceSubmitted)), // Pass attendance status
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to login: ${e.toString()}'; // Update error message
      });
      print('Error: $e'); // Log the error for debugging purposes
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
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
                        // Input fields for username/email and password
                        _buildInputField('Username', _inputController),
                        const SizedBox(height: 40),
                        _buildInputField('Password', _passwordController, obscureText: true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _login, // Disable button while loading
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white) // Show loading indicator
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
                          onPressed: () {}, // Add forgot password functionality if needed
                          child: const Text(
                            'Forgot password?',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to RegistrationScreen when clicked
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
