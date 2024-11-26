import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart'; // Import the logger package
import '../service/notification_service.dart'; // Import your NotificationService

final notificationsProvider = StateNotifierProvider<NotificationNotifier, List<Map<String, dynamic>>>(
  (ref) => NotificationNotifier(),
);

class NotificationNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  NotificationNotifier() : super([]);

  final NotificationService _notificationService = NotificationService();
  final Logger _logger = Logger(); // Create a logger instance
  bool isLoading = false;

  Future<void> fetchNotifications() async {
    if (isLoading) return; // Prevent multiple concurrent calls
    isLoading = true;

    try {
      // Retrieve the token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('token'); // Token saved under 'token'
      if (authToken == null) {
        throw Exception("Auth token not found in SharedPreferences.");
      }

      // Use the token to fetch notifications
      final notifications = await _notificationService.fetchNotifications(authToken);
      state = notifications; // Update the state with fetched notifications
    } catch (e, stackTrace) {
      _logger.e("Error fetching notifications", e, stackTrace); // Use logger for error handling
    } finally {
      isLoading = false;
    }
  }
}
