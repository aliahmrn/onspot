import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';
import 'enter_code.dart';
import 'login.dart';

class ForgotPasswordState {
  final bool isLoading; // Tracks loading state
  final String message; // Stores success/error messages
  final bool navigateToEnterCode; // Triggers navigation

  ForgotPasswordState({
    this.isLoading = false,
    this.message = '',
    this.navigateToEnterCode = false,
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? message,
    bool? navigateToEnterCode,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      navigateToEnterCode: navigateToEnterCode ?? this.navigateToEnterCode,
    );
  }
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthService _authService;

  ForgotPasswordNotifier(this._authService) : super(ForgotPasswordState());

  Future<void> sendResetCode(String email) async {
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      state = state.copyWith(message: 'Please enter a valid email address.');
      return;
    }

    state = state.copyWith(isLoading: true, message: '', navigateToEnterCode: false);

    try {
      await _authService.sendResetCode(email);
      state = state.copyWith(
        isLoading: false,
        message: 'A reset code has been sent to your email.',
        navigateToEnterCode: true, // Trigger navigation
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Error: ${e.toString()}',
      );
    }
  }

  /// Reset navigation state
  void resetNavigation() {
    state = state.copyWith(navigateToEnterCode: false);
  }
}

final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
  (ref) => ForgotPasswordNotifier(AuthService()),
);

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);

    final TextEditingController emailController = TextEditingController();

    final theme = Theme.of(context);

    // Handle navigation trigger
    if (forgotPasswordState.navigateToEnterCode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EnterCodeScreen(email: emailController.text),
          ),
        );
        // Reset navigation flag
        forgotPasswordNotifier.resetNavigation();
      });
    }

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 60),
                Text(
                  'Forgot Password',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        _buildInputField('Email', emailController),
                        if (forgotPasswordState.message.contains('valid email'))
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              forgotPasswordState.message,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: forgotPasswordState.isLoading
                              ? null
                              : () {
                                  forgotPasswordNotifier.sendResetCode(emailController.text);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(150, 30), // Reduced width
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: forgotPasswordState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Send Reset Code', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 8),
                        if (forgotPasswordState.message.isNotEmpty &&
                            !forgotPasswordState.message.contains('valid email'))
                          Text(
                            forgotPasswordState.message,
                            style: TextStyle(
                              color: forgotPasswordState.message.contains('Error') ? Colors.red : Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                      (route) => false,
                    );
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: Text(
                    'Back to Login',
                    style: TextStyle(
                      color: theme.colorScheme.secondary,
                      decoration: TextDecoration.underline,
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
    IconData? getIcon(String label) {
      switch (label) {
        case 'Email':
          return Icons.email;
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
        const SizedBox(height: 6),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(
                getIcon(label),
                color: Colors.grey, // Grey icon color for subtle design
              ),
              hintText: 'Enter your email',
              hintStyle: const TextStyle(color: Colors.grey), // Soft grey for hint text
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
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
