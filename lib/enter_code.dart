
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_password.dart';

// State class for Enter Code
class EnterCodeState {
  final bool isLoading; // Tracks loading state
  final String message; // Stores success/error messages
  final bool navigateToResetPassword; // Triggers navigation

  EnterCodeState({
    this.isLoading = false,
    this.message = '',
    this.navigateToResetPassword = false,
  });

  // Create a copy with optional changes
  EnterCodeState copyWith({
    bool? isLoading,
    String? message,
    bool? navigateToResetPassword,
  }) {
    return EnterCodeState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      navigateToResetPassword: navigateToResetPassword ?? this.navigateToResetPassword,
    );
  }
}

// Notifier for Enter Code logic
class EnterCodeNotifier extends StateNotifier<EnterCodeState> {
  EnterCodeNotifier() : super(EnterCodeState());

  Future<void> verifyCode(String code) async {
    if (code.isEmpty) {
      state = state.copyWith(message: 'Please enter the reset code.');
      return;
    }

    state = state.copyWith(isLoading: true, message: '', navigateToResetPassword: false);

    try {
      // Simulate verification process (replace with actual API call if needed)
      await Future.delayed(const Duration(seconds: 1));

      // Update state to trigger navigation
      state = state.copyWith(
        isLoading: false,
        navigateToResetPassword: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Error: Unable to verify the code.',
      );
    }
  }

  /// Reset navigation state
  void resetNavigation() {
    state = state.copyWith(navigateToResetPassword: false);
  }
}

// Riverpod Provider for EnterCodeNotifier
final enterCodeProvider = StateNotifierProvider<EnterCodeNotifier, EnterCodeState>(
  (ref) => EnterCodeNotifier(),
);

class EnterCodeScreen extends ConsumerWidget {
  final String email;

  const EnterCodeScreen({required this.email, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enterCodeState = ref.watch(enterCodeProvider);
    final enterCodeNotifier = ref.read(enterCodeProvider.notifier);

    final TextEditingController codeController = TextEditingController();

    final theme = Theme.of(context); // Access theme colors

    // Handle navigation trigger
    if (enterCodeState.navigateToResetPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(
              email: email,
              code: codeController.text,
            ),
          ),
        );
        // Reset navigation flag
        enterCodeNotifier.resetNavigation();
      });
    }

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
                        _buildInputField('Reset Code', codeController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: enterCodeState.isLoading
                              ? null
                              : () {
                                  enterCodeNotifier.verifyCode(
                                    codeController.text,
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(250, 40),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: enterCodeState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Verify Code', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        if (enterCodeState.message.isNotEmpty)
                          Text(
                            enterCodeState.message,
                            style: TextStyle(
                              color: enterCodeState.message.contains('Error') ? Colors.red : Colors.green,
                            ),
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
