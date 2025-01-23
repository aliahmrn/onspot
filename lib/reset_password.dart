import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/auth_service.dart';
import 'enter_code.dart';
import 'login.dart';

// State class for Reset Password
class ResetPasswordState {
  final bool isLoading; // Tracks loading state
  final String message; // Stores success/error messages

  ResetPasswordState({
    this.isLoading = false,
    this.message = '',
  });

  // Create a copy with optional changes
  ResetPasswordState copyWith({
    bool? isLoading,
    String? message,
  }) {
    return ResetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
    );
  }
}

// Notifier for Reset Password logic
class ResetPasswordNotifier extends StateNotifier<ResetPasswordState> {
  final AuthService _authService;

  ResetPasswordNotifier(this._authService) : super(ResetPasswordState());

  Future<void> resetPassword({
    required String email,
    required String password,
    required String confirmPassword,
    required BuildContext context,
  }) async {
    if (password != confirmPassword) {
      state = state.copyWith(message: 'Kata Laluan tidak sepadan.');
      return;
    }

    state = state.copyWith(isLoading: true, message: '');

    try {
      // Call the API to reset the password
      await _authService.resetPassword(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      state = state.copyWith(message: 'Kata laluan anda telah berjaya ditetapkan semula.');

      // Delay before navigation
      await Future.delayed(const Duration(seconds: 3));
      if (context.mounted) {
        // Reset the state before navigating to the login screen
        resetState();

        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          (route) => false,
        );
      }
    } catch (e) {
      state = state.copyWith(message: 'Ralat: ${e.toString()}');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // Reset the state to its initial values
  void resetState() {
    state = ResetPasswordState();
  }
}

// Riverpod Provider for ResetPasswordNotifier
final resetPasswordProvider = StateNotifierProvider<ResetPasswordNotifier, ResetPasswordState>(
  (ref) => ResetPasswordNotifier(AuthService()),
);

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({required this.email, super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resetPasswordState = ref.watch(resetPasswordProvider);
    final resetPasswordNotifier = ref.read(resetPasswordProvider.notifier);

    final theme = Theme.of(context);

    // If loading, update the input fields to show placeholders
    if (resetPasswordState.isLoading) {
      passwordController.text = passwordController.text.isEmpty
          ? ''
          : passwordController.text.replaceAll(RegExp(r'.'), '*'); // Display placeholder as '*****'
      confirmPasswordController.text = confirmPasswordController.text.isEmpty
          ? ''
          : confirmPasswordController.text.replaceAll(RegExp(r'.'), '*');
    }

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
                  'Tetapkan Semula Kata Laluan',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        _buildInputField(
                          'Kata Laluan Baru',
                          passwordController,
                          isPassword: true,
                          isReadOnly: resetPasswordState.isLoading,
                        ),
                        const SizedBox(height: 20),
                        _buildInputField(
                          'Sahkan Kata Laluan Baru',
                          confirmPasswordController,
                          isPassword: true,
                          isReadOnly: resetPasswordState.isLoading,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: resetPasswordState.isLoading
                              ? null
                              : () {
                                  resetPasswordNotifier.resetPassword(
                                    email: widget.email,
                                    password: passwordController.text,
                                    confirmPassword: confirmPasswordController.text,
                                    context: context,
                                  );
                                },
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
                              : const Text('Tetapkan Semula Kata Laluan', style: TextStyle(color: Colors.white)),
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
                const SizedBox(height: 20),
                // Back Button
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnterCodeScreen(email: widget.email),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  label: Text(
                    'Kembali',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
    bool isReadOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        SizedBox(
          width: 350,
          child: TextField(
            controller: controller,
            readOnly: isReadOnly,
            obscureText: isPassword && !isReadOnly, // Show actual password only if not loading
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: isPassword ? 'Masukkan kata laluan' : 'Masukkan $label',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

