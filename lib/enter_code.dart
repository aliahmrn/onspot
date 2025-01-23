import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reset_password.dart';
import '../service/auth_service.dart';
import 'forgot_password.dart';

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

  Future<void> verifyCode(String email, String code) async {
    if (code.isEmpty || code.length != 6) {
      state = state.copyWith(message: 'Kod tidak sah. Sila masukkan kod yang sah.');
      return;
    }

    state = state.copyWith(isLoading: true, message: '', navigateToResetPassword: false);

    try {
      // Call the API to verify the reset code
      await AuthService().verifyResetCode(email: email, code: code);

      // Update state to trigger navigation
      state = state.copyWith(
        isLoading: false,
        navigateToResetPassword: true,
      );
    } catch (e) {
      if (e is Exception && e.toString().contains('Kata laluan tidak sah')) {
        state = state.copyWith(
          isLoading: false,
          message: 'Kata laluan tidak sah atau tamat tempoh.',
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          message: 'Ralat tidak dijangka. Sila cuba lagi.',
        );
      }
    }
  }
  
  void resetState() {
    state = EnterCodeState();
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

class EnterCodeScreen extends ConsumerStatefulWidget {
  final String email;

  const EnterCodeScreen({required this.email, super.key});

  @override
  ConsumerState<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends ConsumerState<EnterCodeScreen> {
  late TextEditingController codeController;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(enterCodeProvider.notifier).resetState());
    codeController = TextEditingController(); // Initialize controller
  }

  @override
  void dispose() {
    codeController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enterCodeState = ref.watch(enterCodeProvider);
    final enterCodeNotifier = ref.read(enterCodeProvider.notifier);
    final theme = Theme.of(context);

    // Handle navigation trigger
    if (enterCodeState.navigateToResetPassword) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('Navigating to ResetPasswordScreen.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordScreen(email: widget.email),
          ),
        ).then((_) {
          debugPrint('ResetPasswordScreen navigation completed.');
          // Reset state when navigating back
          enterCodeNotifier.resetState();
        });
        enterCodeNotifier.resetNavigation();
      });
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
                  'Masukkan Kod',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        _buildInputField(
                          'Kod Tetapan Semula',
                          codeController,
                          isReadOnly: enterCodeState.isLoading,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: enterCodeState.isLoading
                              ? null
                              : () {
                                  final code = codeController.text.trim();
                                  enterCodeNotifier.verifyCode(widget.email, code);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(250, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: enterCodeState.isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Sahkan Kod', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 10),
                        if (enterCodeState.message.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              enterCodeState.message,
                              style: TextStyle(
                                color: enterCodeState.message.contains('Ralat') ? Colors.red : Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                      ).then((_) {
                        ref.read(enterCodeProvider.notifier).resetState(); // Reset EnterCodeNotifier state
                   });
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

  Widget _buildInputField(String label, TextEditingController controller, {bool isReadOnly = false}) {
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
            readOnly: isReadOnly, // Maintain input while making it read-only
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              hintText: 'Masukkan kod',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

