import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';
import 'package:logger/logger.dart'; 

/// State class for Forgot Password
class ForgotPasswordState {
  final String email; // Email entered by the user
  final bool isLoading; // Tracks loading state
  final String message; // Stores success/error messages
  final bool navigateToEnterCode; // Triggers navigation
  

  ForgotPasswordState({
    this.email = '',
    this.isLoading = false,
    this.message = '',
    this.navigateToEnterCode = false,
  });

  /// Copy with method for immutability
  ForgotPasswordState copyWith({
    String? email,
    bool? isLoading,
    String? message,
    bool? navigateToEnterCode,
  }) {
    return ForgotPasswordState(
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      navigateToEnterCode: navigateToEnterCode ?? this.navigateToEnterCode,
    );
  }
}

/// ForgotPasswordNotifier to manage the state
class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthService _authService;
  final Logger logger = Logger();

  ForgotPasswordNotifier(this._authService) : super(ForgotPasswordState());

  /// Method to send the reset code
  Future<void> sendResetCode(String email) async {
    email = email.trim();
    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      state = state.copyWith(message: 'Sila masukkan E-mel yang sah.');
      logger.e('Invalid email entered: $email');
      return;
    }

    state = state.copyWith(isLoading: true, email: email, message: '', navigateToEnterCode: false);
    logger.i('Sending reset code for email: $email');

    try {
      await _authService.sendResetCode(email);
      state = state.copyWith(
        isLoading: false,
        message: 'Kod tetapan semula telah dihantar ke E-mel anda.',
        navigateToEnterCode: true, // Triggers navigation
      );
      logger.i('Reset code sent successfully. Navigate to EnterCodeScreen triggered.');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        message: 'Ralat: ${e.toString()}',
      );
      logger.e('Failed to send reset code: ${e.toString()}');
    }
  }

  /// Reset navigation state
  void resetNavigation() {
    state = state.copyWith(navigateToEnterCode: false);
  }

  /// Reset the state (for reusability on revisit)
  void resetState() {
    state = ForgotPasswordState(); // Reset to initial state
    logger.i('ForgotPasswordState has been reset.');
  }
}

/// The provider for ForgotPasswordNotifier
final forgotPasswordProvider = StateNotifierProvider.autoDispose<ForgotPasswordNotifier, ForgotPasswordState>(
  (ref) => ForgotPasswordNotifier(AuthService()),
);
