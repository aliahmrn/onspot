import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/forgot_password_provider.dart';
import 'enter_code.dart';
import 'login.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);
    final theme = Theme.of(context);
    
    // Handle navigation trigger
    if (forgotPasswordState.navigateToEnterCode) {
      logger.i('Navigation to EnterCodeScreen is triggered.');
      Future.delayed(const Duration(seconds: 3), () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final email = forgotPasswordState.email; // Get the trimmed email here once
          if (email.isNotEmpty) {
            logger.i('Navigating to EnterCodeScreen with email: $email');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EnterCodeScreen(email: email), // Pass the email correctly
              ),
            ).then((_) {
              // Reset state when navigating back from EnterCodeScreen
              forgotPasswordNotifier.resetState();
              forgotPasswordNotifier.resetNavigation();
            });
          } else {
            logger.e('Error: Email is empty during navigation to EnterCodeScreen.');
          }
        });
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
                  'Lupa Kata Laluan',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: <Widget>[
                        _buildInputField('E-mel', emailController, isReadOnly: forgotPasswordState.isLoading),
                        if (forgotPasswordState.message.contains('alamat E-mel yang sah'))
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
                                    final email = emailController.text.trim();
                                    if (email.isNotEmpty) {
                                      logger.i('Sending reset code for email: $email');
                                      forgotPasswordNotifier.sendResetCode(email);
                                    } else {
                                      logger.e('Error: Email is empty when attempting to send reset code.');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              minimumSize: const Size(200, 30), // Reduced width
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: forgotPasswordState.isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Hantar Kod Tetapan Semula', style: TextStyle(color: Colors.white)),
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
                    ).then((_) {
                      // Reset state when navigating back from LoginScreen
                      forgotPasswordNotifier.resetState();
                    });
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: Text(
                    'Kembali ke Log masuk',
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

  Widget _buildInputField(String label, TextEditingController controller, {bool isReadOnly = false}) {
    IconData? getIcon(String label) {
      switch (label) {
        case 'E-mel':
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
            readOnly: isReadOnly,
            decoration: InputDecoration(
              prefixIcon: Icon(
                getIcon(label),
                color: Colors.grey, // Grey icon color for subtle design
              ),
              hintText: 'Masukkan E-mel',
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
