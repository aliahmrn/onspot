import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/auth_service.dart';
import 'enter_code.dart';
import 'login.dart';
import '../main.dart'; // Import navigatorKeyProvider from main.dart

// State class for forgot password logic
class ForgotPasswordState {
  final bool isLoading;
  final String message;

  ForgotPasswordState({this.isLoading = false, this.message = ''});

  ForgotPasswordState copyWith({bool? isLoading, String? message}) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }
}

// StateNotifier to handle forgot password logic
class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthService _authService;
  final GlobalKey<NavigatorState> _navigatorKey;

  ForgotPasswordNotifier(this._authService, this._navigatorKey)
      : super(ForgotPasswordState());

  Future<void> sendResetCode(String email) async {
    if (email.isEmpty) {
      state = state.copyWith(message: 'Please enter your email');
      return;
    }

    state = state.copyWith(isLoading: true, message: '');

    try {
      await _authService.sendResetCode(email);

      state = state.copyWith(message: 'A reset code has been sent to your email.');

      // Navigate to EnterCodeScreen after a short delay
      Future.delayed(const Duration(seconds: 3), () {
        _navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (context) => EnterCodeScreen(email: email)),
        );
      });
    } catch (e) {
      state = state.copyWith(message: 'Error: ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Riverpod provider for ForgotPasswordNotifier
final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>(
  (ref) => ForgotPasswordNotifier(AuthService(), ref.read(navigatorKeyProvider)), // Use global navigatorKeyProvider
);

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forgotPasswordState = ref.watch(forgotPasswordProvider);
    final forgotPasswordNotifier = ref.read(forgotPasswordProvider.notifier);

    final TextEditingController emailController = TextEditingController();
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
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        _buildInputField('Email', emailController),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: forgotPasswordState.isLoading
                              ? null
                              : () => forgotPasswordNotifier.sendResetCode(emailController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(250, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: forgotPasswordState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Send Reset Code', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        if (forgotPasswordState.message.isNotEmpty)
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
                const SizedBox(height: 20),
                // Back to Login Button
                TextButton(
                  onPressed: () {
                    ref.read(navigatorKeyProvider).currentState?.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
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
              hintText: 'Enter your email',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
