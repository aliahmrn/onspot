import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart'; // Import logger package

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
          logger.i('Login successful. Token saved for officer.'); // Log info
        } else {
          throw Exception('Access denied: User is not an officer');
        }
      } else if (response.statusCode == 401) {
        // Handle invalid credentials with specific message
        throw Exception('Invalid login credentials.');
      }
    } catch (e) {
      logger.e('Error during login', error: e); // Correct logging
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
          'Accept': 'application/json', // Expect JSON response
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
        logger.i('Registration successful.'); // Log info
      } else {
        logger.w('Registration failed: ${response.statusCode} - ${response.body}'); // Correct logging
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      logger.e('Error during registration', error: e); // Correct logging
      throw Exception('Error during registration: $e');
    }
  }

  // Save token and role to shared preferences
  Future<void> saveToken(String token, String userRole) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userRole', userRole); // Store user role
    logger.i('Token and role saved successfully.'); // Log info
  }

  // Clear all stored user details from shared preferences
  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all user details
    logger.i('User details cleared successfully.'); // Log info
  }

  // Logout function
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/flutterlogout'), // Use the logout endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Pass the token in the header
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await clearUserDetails(); // Clear all stored user details upon successful logout
        logger.i('Logout successful. User details cleared.'); // Log info
      } else {
        logger.w('Logout failed: ${response.statusCode} - ${response.body}'); // Correct logging
        throw Exception('Failed to logout: ${response.body}');
      }
    } catch (e) {
      logger.e('Error during logout', error: e); // Correct logging
      throw Exception('Error during logout: $e');
    }
  }

  // Get current user details
  Future<Map<String, dynamic>> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/profile'), // Endpoint to get user details
        headers: {
          'Authorization': 'Bearer $token', // Pass the token in the header
        },
      );

      if (response.statusCode == 200) {
        logger.i('User data fetched successfully.'); // Log info
        return jsonDecode(response.body); // Return user data as a map
      } else {
        logger.w('Failed to load user: ${response.statusCode} - ${response.body}'); // Correct logging
        throw Exception('Failed to load user: ${response.body}');
      }
    } catch (e) {
      logger.e('Error while getting user', error: e); // Correct logging
      throw Exception('Error while getting user: $e');
    }
  }
}
