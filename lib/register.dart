import 'package:flutter/material.dart';
import 'login.dart';
import 'service/auth_service.dart'; // Import AuthService

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
}

class RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController(); // Username controller
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  final AuthService _authService = AuthService(); // Instantiate AuthService
  bool _isDisposed = false; // Track if the widget is disposed

  // Define setStateIfMounted method to avoid errors after async tasks
  void setStateIfMounted(f) {
    if (!_isDisposed && mounted) {
      setState(f);
    }
  }

  Future<void> _register() async {
    final String fullName = _fullNameController.text;
    final String email = _emailController.text;
    final String username = _usernameController.text; // Use username
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;
    final String phoneNumber = _phoneNumberController.text;

    // Input validation
    if (fullName.isEmpty || email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty || phoneNumber.isEmpty) {
      setStateIfMounted(() {
        _errorMessage = 'Please fill out all the fields';
      });
      return;
    }

    if (password != confirmPassword) {
      setStateIfMounted(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setStateIfMounted(() {
      _isLoading = true;
    });

    try {
      // Call the register method from AuthService with username
      await _authService.register(fullName, username, email, password, phoneNumber);

      if (!mounted || _isDisposed) return; // Prevents continuing if disposed

      // Navigate to the Login Screen upon successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      setStateIfMounted(() {
        _errorMessage = 'Failed to register: ${e.toString()}';
      });
      print('Error: $e');
    } finally {
      setStateIfMounted(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true; // Mark the widget as disposed
    _fullNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
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
                        _buildInputField('Email', _emailController),
                        const SizedBox(height: 20),
                        _buildInputField('Username', _usernameController), // Username field
                        const SizedBox(height: 20),
                        _buildInputField('Password', _passwordController, obscureText: true),
                        const SizedBox(height: 20),
                        _buildInputField('Confirm Password', _confirmPasswordController, obscureText: true),
                        const SizedBox(height: 20),
                        _buildInputField('Phone Number', _phoneNumberController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _register,
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

                        // Button to redirect to the Login page
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            'Already have an account? Log in',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

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
