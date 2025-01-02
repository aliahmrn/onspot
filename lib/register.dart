import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';
import 'login.dart';
import 'package:logger/logger.dart';

// State class for Registration
class RegistrationState {
  final bool isLoading; // Loading state
  final String errorMessage; // Error message
  final Map<String, String> userInput; // User input data

  RegistrationState({
    this.isLoading = false,
    this.errorMessage = '',
    Map<String, String>? userInput,
  }) : userInput = userInput ?? const {};

  // Create a copy with optional modifications
  RegistrationState copyWith({
    bool? isLoading,
    String? errorMessage,
    Map<String, String>? userInput,
  }) {
    return RegistrationState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      userInput: userInput ?? this.userInput,
    );
  }
}

// Notifier for Registration Logic
class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final AuthService _authService;
  final Logger _logger = Logger();

  RegistrationNotifier(this._authService) : super(RegistrationState());

  Future<bool> register({
    required String fullName,
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
  }) async {
    if (fullName.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        phoneNumber.isEmpty) {
      state = state.copyWith(errorMessage: 'Please fill out all the fields');
      return false;
    }

    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: 'Passwords do not match');
      return false;
    }

    // Store user input, including passwords, in the state
    state = state.copyWith(
      isLoading: true,
      errorMessage: '',
      userInput: {
        'Full Name': fullName,
        'Email': email,
        'Username': username,
        'Password': password,
        'Confirm Password': confirmPassword,
        'Phone Number': phoneNumber,
      },
    );

    try {
      await _authService.register(fullName, username, email, password, phoneNumber);
      _logger.i('Registration successful');

      // Reset user input after successful registration
      state = state.copyWith(
        userInput: {}, // Clear the input fields
      );

      return true;
    } catch (e) {
      final error = 'Failed to register: ${e.toString()}';
      _logger.e(error);
      state = state.copyWith(errorMessage: error);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Riverpod Provider for RegistrationNotifier
final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>(
  (ref) => RegistrationNotifier(AuthService()),
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

    // Pre-fill controllers with state data, including passwords
    fullNameController.text = registrationState.userInput['Full Name'] ?? '';
    emailController.text = registrationState.userInput['Email'] ?? '';
    usernameController.text = registrationState.userInput['Username'] ?? '';
    passwordController.text = registrationState.userInput['Password'] ?? '';
    confirmPasswordController.text = registrationState.userInput['Confirm Password'] ?? '';
    phoneNumberController.text = registrationState.userInput['Phone Number'] ?? '';

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'Register',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
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
                        _buildInputField(
                          'Full Name',
                          fullNameController,
                          isEnabled: !registrationState.isLoading,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          'Email',
                          emailController,
                          isEnabled: !registrationState.isLoading,
                        ),
                        const SizedBox(height: 10),
                        _buildInputField(
                          'Username',
                          usernameController,
                          isEnabled: !registrationState.isLoading,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          'Password',
                          passwordController,
                          isEnabled: !registrationState.isLoading,
                          obscureText: true,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          'Confirm Password',
                          confirmPasswordController,
                          isEnabled: !registrationState.isLoading,
                          obscureText: true,
                        ),
                        const SizedBox(height: 8),
                        _buildInputField(
                          'Phone Number',
                          phoneNumberController,
                          isEnabled: !registrationState.isLoading,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: registrationState.isLoading
                              ? null
                              : () async {
                                  final success = await registrationNotifier.register(
                                    fullName: fullNameController.text,
                                    email: emailController.text,
                                    username: usernameController.text,
                                    password: passwordController.text,
                                    confirmPassword: confirmPasswordController.text,
                                    phoneNumber: phoneNumberController.text,
                                  );

                                  if (success && context.mounted) {
                                    // Show the success dialog
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Registration Successful'),
                                          content: const Text(
                                              'Your account has been created. Please log in to continue.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context); // Close the dialog
                                                Navigator.of(context).pushReplacement(
                                                  MaterialPageRoute(
                                                      builder: (context) => const LoginScreen()),
                                                );
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(150, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: registrationState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Register', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const LoginScreen(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: const Text(
                            'Already have an account? Sign In',
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
                          const SizedBox(height: 8),
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

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscureText = false, bool isEnabled = true}) {
    IconData? getIcon(String label) {
      switch (label) {
        case 'Full Name':
          return Icons.person;
        case 'Email':
          return Icons.email;
        case 'Username':
          return Icons.account_circle;
        case 'Password':
        case 'Confirm Password':
          return Icons.lock;
        case 'Phone Number':
          return Icons.phone;
        default:
          return null;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            enabled: isEnabled,
            decoration: InputDecoration(
              prefixIcon: getIcon(label) != null ? Icon(getIcon(label), color: Colors.grey) : null,
              hintText: 'Enter $label',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
