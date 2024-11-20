import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class AuthService {
  final String baseUrl = 'http://192.168.1.105:8000/api'; // Android Emulator
  final Logger _logger = Logger(); // Initialize Logger


  // Login function for supervisors
Future<void> login(String input, String password) async {
  try {
    final requestBody = jsonEncode({
      'login': input,
      'password': password,
    });

    final response = await http.post(
      Uri.parse('$baseUrl/flutterlogin'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _logger.i("Login Response: $data");

      final String token = data['token'];
      final String role = data['user']['role'];
      final String svId = data['user']['id'].toString();
      final String email = data['user']['email'];
      final String username = data['user']['username'];
      final String name = data['user']['name'];
      final String phoneNo = data['user']['phone_no'];

      if (role == 'supervisor') {
        await saveUserDetails(token, role, svId, email, username, name, phoneNo);
        
        // Store the notification token after login
        final String? deviceToken = await FirebaseMessaging.instance.getToken();
        if (deviceToken != null) {
          await storeNotificationToken(deviceToken, "device_id_placeholder", "android"); // Replace "device_id_placeholder" with actual device ID if needed
        }
      } else {
        throw Exception('Access denied: User is not a supervisor');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Invalid login credentials.');
    }
  } catch (e) {
    throw Exception('Error during login: ${e.toString()}');

  }
}

  Future<void> saveUserDetails(String token, String role, String svId, String email, String username, String name, String phoneNo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
    await prefs.setString('supervisorId', svId);
    await prefs.setString('email', email);
    await prefs.setString('username', username);
    await prefs.setString('name', name);
    await prefs.setString('phoneNo', phoneNo);
    _logger.i('Supervisor details saved successfully');
  }

  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('supervisorId'); 
    await prefs.remove('email');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('phoneNo');
    _logger.i('User details cleared');
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/flutterlogout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        _logger.w('Logout failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to logout: ${response.body}');
      }

      await clearUserDetails();
    } catch (e) {
      _logger.e('Error during logout: $e');
      throw Exception('Error during logout: $e');
    }
  }

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

      if (response.statusCode != 200) {
        _logger.w('Failed to load user: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      _logger.e('Error while getting user: $e');
      throw Exception('Error while getting user: $e');
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
        'role': 'supervisor',
      }),
    );

    if (response.statusCode == 201) {
      // Assuming successful registration, get the notification token and store it
      final String? deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken != null) {
        await storeNotificationToken(deviceToken, "device_id_placeholder", "android"); // Replace "device_id_placeholder" with actual device ID if needed
      }
    } else {
      _logger.w('Registration failed: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to register user: ${response.body}');
    }
  } catch (e) {
    _logger.e('Error during registration: $e');
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
        _logger.i('Reset code sent successfully.');
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
        _logger.i('Password has been reset successfully.');
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
    _logger.i('Device token saved successfully');
  } else {
    _logger.e('Failed to save device token: ${response.body}');
  }
}


}