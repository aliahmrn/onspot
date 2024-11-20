import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/auth_service.dart';
import 'login.dart';
import '../main.dart'; // Import global navigatorKeyProvider

// State class for reset password logic
class ResetPasswordState {
  final bool isLoading;
  final String message;

  ResetPasswordState({this.isLoading = false, this.message = ''});

  ResetPasswordState copyWith({bool? isLoading, String? message}) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }
}

// StateNotifier for reset password logic
class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  final AuthService _authService;
  final GlobalKey<NavigatorState> _navigatorKey;

  ResetPasswordNotifier(this._authService, this._navigatorKey) : super(ResetPasswordState());

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      state = state.copyWith(message: 'Passwords do not match.');
      return;
    }

    state = state.copyWith(isLoading: true, message: '');

    try {
      await _authService.resetPassword(email, code, password, confirmPassword);

      state = state.copyWith(message: 'Your password has been reset successfully.');

      // Navigate to LoginScreen after success
      Future.delayed(const Duration(seconds: 3), () {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      });
    } catch (e) {
      state = state.copyWith(message: 'Error: ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Provider for ResetPasswordNotifier
final resetPasswordProvider = StateNotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
  (ref) => ResetPasswordNotifier(AuthService(), ref.read(navigatorKeyProvider)), // Use the global navigatorKeyProvider
);

class ResetPasswordScreen extends ConsumerWidget {
  final String email;
  final String code;

  const ResetPasswordScreen({required this.email, required this.code, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resetPasswordState = ref.watch(resetPasswordProvider);
    final resetPasswordNotifier = ref.read(resetPasswordProvider.notifier);

    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 60),
                Text(
                  'Reset Password',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        _buildInputField('New Password', passwordController, isPassword: true),
                        const SizedBox(height: 20),
                        _buildInputField('Confirm New Password', confirmPasswordController, isPassword: true),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: resetPasswordState.isLoading
                              ? null
                              : () => resetPasswordNotifier.resetPassword(
                                    email: email,
                                    code: code,
                                    password: passwordController.text,
                                    confirmPassword: confirmPasswordController.text,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(250, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: resetPasswordState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Reset Password', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        if (resetPasswordState.message.isNotEmpty)
                          Text(
                            resetPasswordState.message,
                            style: TextStyle(
                              color: resetPasswordState.message.contains('Error') ? Colors.red : Colors.green,
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

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: isPassword ? 'Enter your password' : 'Enter your $label',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
