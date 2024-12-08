import 'dart:convert';
import 'dart:io'; // For platform checks
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/device_utils.dart';
import '../utils/shared_preferences_manager.dart';
import '../providers/attendance_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AuthService {
  final String baseUrl = 'http://192.168.1.105:8000/api'; // Your API base URL
  final Logger logger = Logger(); // Initialize Logger

  // Login function for cleaners
  Future<void> login(String username, String password, WidgetRef ref) async {
    try {
      final requestBody = jsonEncode({
        'login': username,
        'password': password,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/flutterlogin'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['token'];
        final String role = data['user']['role'];

        // Save the token in SharedPreferences
        await SharedPreferencesManager.prefs.setString('token', token);

        // Update authTokenProvider
        ref.read(authTokenProvider.notifier).state = token;

        if (role == 'cleaner') {
          await saveUserDetails(
            token: token,
            role: role,
            email: data['user']['email'],
            username: data['user']['username'],
            name: data['user']['name'],
            phoneNo: data['user']['phone_no'],
            id: data['user']['id'].toString(),
          );

          // Fetch and save FCM token
          await saveFcmTokenIfNeeded(token);
        } else {
          throw Exception('Access denied: User is not a cleaner');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid login credentials.');
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during login: $e');
    }
  }

  Future<void> saveUserDetails({
    required String token,
    required String role,
    required String email,
    required String username,
    required String name,
    required String phoneNo,
    required String id,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setString('name', name);
    await prefs.setString('phoneNo', phoneNo);
    await prefs.setString('cleanerId', id);
    logger.i('Cleaner details saved successfully.');
  }

  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    logger.i('User details cleared.');
  }

  // Save FCM token to the backend
  Future<void> saveFcmToken(String authToken, String fcmToken) async {
    try {
      final deviceId = await getDeviceId();

      final response = await http.post(
        Uri.parse('$baseUrl/store-token'),
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
      logger.e('Error while saving FCM token: $e');
    }
  }

  // Fetch and save FCM token if needed
  Future<void> saveFcmTokenIfNeeded(String authToken) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();

      logger.i('Retrieved FCM token: $fcmToken');

      if (fcmToken != null) {
        await saveFcmToken(authToken, fcmToken);
      } else {
        logger.w('FCM token is null. Skipping save.');
      }
    } catch (e) {
      logger.e('Error retrieving FCM token: $e');
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
        await clearUserDetails(); // Clear user-specific details
        logger.i('Logout successful. User details cleared.');
      } else {
        logger.w('Logout failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to logout: ${response.body}');
      }
    } catch (e) {
      logger.e('Error during logout: $e');
      throw Exception('Error during logout: $e');
    }
  }

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
          'role': 'cleaner',
        }),
      );

      if (response.statusCode == 201) {
        logger.i('Registration successful.');

        final data = jsonDecode(response.body);
        final String token = data['token'];

        logger.i('Registration complete. Fetching and saving FCM token...');
        await saveFcmTokenIfNeeded(token);
      } else {
        logger.w('Registration failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      logger.e('Error during registration: $e');
      throw Exception('Error during registration: $e');
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


   Future<void> storeNotificationToken(String deviceToken, String deviceId, String deviceType) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Retrieve the stored token

    if (token == null) {
      Logger().e('Error: No token found. User might not be logged in.');
      return; // Exit the function if no token is found
    }

    final response = await http.post(
      Uri.parse('$baseUrl/store-token'), // Fixed URL based on your base URL
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'device_token': deviceToken,
        'device_id': deviceId,
        'device_type': deviceType,
      }),
    );

    if (response.statusCode == 200) {
      logger.i('Device token saved successfully');
    } else {
      logger.e('Failed to save device token: ${response.body}');
    }
  }

  // Save token to SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    logger.i('Token saved: $token'); // Debug log
  }
  

}
