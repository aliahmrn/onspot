import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'service/auth_service.dart'; // Import AuthService
import 'package:logger/logger.dart'; // Import the logger package

// Define a global navigator key provider
final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

// Define a state class for registration
class RegistrationState {
  final bool isLoading;
  final String errorMessage;

  RegistrationState({this.isLoading = false, this.errorMessage = ''});

  RegistrationState copyWith({bool? isLoading, String? errorMessage}) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Define a StateNotifier to manage registration logic
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final AuthService _authService;
  final Logger _logger = Logger();
  final GlobalKey<NavigatorState> _navigatorKey;

  RegistrationNotifier(this._authService, this._navigatorKey) : super(RegistrationState());

  Future<void> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    // Input validation
    if (fullName.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phoneNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill out all the fields');
      return;
    }

    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: 'Passwords do not match');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: '');

    try {
      // Call the register method from AuthService
      await _authService.register(fullName, username, email, password, phoneNumber);

      // Navigate to the login screen after successful registration
      _navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to register: ${e.toString()}');
      _logger.e('Registration error: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Define a provider for the registration notifier
final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>(
  (ref) => RegistrationNotifier(AuthService(), ref.read(navigatorKeyProvider)),
);

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationState = ref.watch(registrationProvider);
    final registrationNotifier = ref.read(registrationProvider.notifier);

    final TextEditingController fullNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

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
                        _buildInputField('Full Name', fullNameController),
                        const SizedBox(height: 20),
                        _buildInputField('Email', emailController),
                        const SizedBox(height: 20),
                        _buildInputField('Username', usernameController),
                        const SizedBox(height: 20),
                        _buildInputField('Password', passwordController, obscureText: true),
                        const SizedBox(height: 20),
                        _buildInputField('Confirm Password', confirmPasswordController, obscureText: true),
                        const SizedBox(height: 20),
                        _buildInputField('Phone Number', phoneNumberController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: registrationState.isLoading
                              ? null
                              : () {
                                  registrationNotifier.register(
                                    fullName: fullNameController.text,
                                    email: emailController.text,
                                    username: usernameController.text,
                                    password: passwordController.text,
                                    confirmPassword: confirmPasswordController.text,
                                    phoneNumber: phoneNumberController.text,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: registrationState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Register', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            ref.read(navigatorKeyProvider).currentState?.pushReplacement(
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
                        if (registrationState.errorMessage.isNotEmpty) ...[
                          Text(
                            registrationState.errorMessage,
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
