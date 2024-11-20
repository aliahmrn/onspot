import 'dart:convert';
import 'dart:io'; // Import Platform for platform-specific checks
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging
import 'package:onspot_officer/utils/device_utils.dart'; // Import device utility

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  var logger = Logger(); // Create a logger instance

  // Login function for officers
  Future<void> login(String input, String password) async {
    try {
      // Prepare the request body
      final requestBody = jsonEncode({
        'login': input,
        'password': password,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/flutterlogin'), // Endpoint for login
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract token and role from the response
        final String token = data['token'];
        final String role = data['user']['role'];

        // Check if role is "officer" before proceeding
        if (role == 'officer') {
          // Save token and role
          await saveToken(token, role);
          logger.i('Login successful. Token saved for officer.');

          // Fetch and save FCM token
          logger.i('Token saved. Calling saveFcmTokenIfNeeded...');
          await saveFcmTokenIfNeeded(token);
        } else {
          throw Exception('Access denied: User is not an officer');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid login credentials.');
      }
    } catch (e) {
      throw Exception('Error during login: ${e.toString()}');
    }
  }

  // Register function with default role "officer"
  Future<void> register(String name, String username, String email, String password, String phoneNo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/flutterregister'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'phone_no': phoneNo,
          'role': 'officer',
        }),
      );

      if (response.statusCode == 201) {
        logger.i('Registration successful.');

        // Automatically fetch and save FCM token after registration
        final data = jsonDecode(response.body);
        final String token = data['token'];
        logger.i('Registration successful. Calling saveFcmTokenIfNeeded...');
        await saveFcmTokenIfNeeded(token);
      } else {
        logger.w('Registration failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      logger.e('Error during registration', error: e);
      throw Exception('Error during registration: $e');
    }
  }

  // Save FCM token to the backend
  Future<void> saveFcmToken(String authToken, String fcmToken) async {
    try {
      final deviceId = await getDeviceId(); // Fetch device ID dynamically

      final response = await http.post(
        Uri.parse('$baseUrl/store-token'), // Use the correct endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'device_token': fcmToken,
          'device_id': deviceId,
          'device_type': Platform.isAndroid ? 'android' : 'ios',
        }),
      );

      if (response.statusCode == 200) {
        logger.i('FCM token saved successfully.');
      } else {
        logger.w('Failed to save FCM token: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      logger.e('Error while saving FCM token', error: e);
    }
  }

// Utility function to fetch and save FCM token if needed
Future<void> saveFcmTokenIfNeeded(String authToken) async {
  try {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final deviceId = await getDeviceId(); // Fetch device ID dynamically

    logger.i('Preparing to send FCM token to backend:');
    logger.i('Device ID: $deviceId');
    logger.i('FCM Token: $fcmToken');
    logger.i('Authorization Token: $authToken');

    if (fcmToken != null) {
      logger.i('Retrieved FCM token: $fcmToken');
      await saveFcmToken(authToken, fcmToken); // Save token to backend
    } else {
      logger.w('FCM token is null. Skipping token save.');
    }
  } catch (e) {
    logger.e('Error while retrieving FCM token', error: e);
  }
}


  // Logout function
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse('$baseUrl/flutterlogout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'device_id': deviceId}),
      );

      if (response.statusCode == 200) {
        await clearUserDetails();
        logger.i('Logout successful. User details cleared.');
      } else {
        logger.w('Logout failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to logout: ${response.body}');
      }
    } catch (e) {
      logger.e('Error during logout', error: e);
      throw Exception('Error during logout: $e');
    }
  }

  Future<void> sendResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        logger.i('Reset code sent successfully.');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to send reset code.');
      }
    } catch (e) {
      throw Exception('Error during forgot password request: ${e.toString()}');
    }
  }

  Future<void> resetPassword(String email, String code, String password, String confirmPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'code': code,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      if (response.statusCode == 200) {
        logger.i('Password has been reset successfully.');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to reset password.');
      }
    } catch (e) {
      throw Exception('Error during password reset: ${e.toString()}');
    }
  }

  // Save token and role to shared preferences
  Future<void> saveToken(String token, String userRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userRole', userRole);
    logger.i('Token and role saved successfully.');
  }

  // Clear all stored user details from shared preferences
  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    logger.i('User details cleared successfully.');
  }

  // Get current user details
  Future<Map<String, dynamic>> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        logger.i('User data fetched successfully.');
        return jsonDecode(response.body);
      } else {
        logger.w('Failed to load user: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user: ${response.body}');
      }
    } catch (e) {
      logger.e('Error while getting user', error: e);
      throw Exception('Error while getting user: $e');
    }
  }
}
