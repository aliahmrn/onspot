import 'package:flutter_riverpod/flutter_riverpod.dart';

final appRefreshProvider = StateNotifierProvider<AppRefreshNotifier, bool>((ref) {
  return AppRefreshNotifier();
});

class AppRefreshNotifier extends StateNotifier<bool> {
  AppRefreshNotifier() : super(false);

  // Trigger a refresh by toggling the state
  void refreshApp() {
    state = true; // Indicate that a refresh is required
  }

  // Reset the refresh state
  void refreshCompleted() {
    state = false; // Reset state after refresh is done
  }
}
