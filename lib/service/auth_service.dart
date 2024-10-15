import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator

  // Login function for officers
  Future<void> login(String input, String password) async {
    try {
      // Prepare the request body
      final requestBody = jsonEncode({
        'login': input, 
        'password': password,
      });

      print('Request Body: $requestBody'); 

      final response = await http.post(
        Uri.parse('$baseUrl/flutterlogin'), // Endpoint for login
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract token and role from the response
        final String token = data['token'];
        final String role = data['user']['role']; // Extracts officer role from json

        // Log successful response and token
        print('Login successful, token: $token, role: $role'); // Log for debugging

        // Save token and role 
        await saveToken(token, role);
      } else {
        // Log server response for failed login 
        print('Login failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      // Log errors during the login process
      print('Error during login: $e');
      throw Exception('Error during login: $e');
    }
}



  // Register function (if needed)
  Future<void> register(String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      if (response.statusCode != 201) {
        // Log the server response for debugging
        print('Registration failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Error during registration: $e');
    }
  }

  // Save token and role to shared preferences
  Future<void> saveToken(String token, String userRole) async { 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userRole', userRole); // Store user role
  }

  // Clear token and role from shared preferences
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
  }

  // Logout function
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/logout'), // Use the logout endpoint
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Pass the token in the header
        'Accept': 'application/json', // Ensure you accept JSON responses
        },
      );

      if (response.statusCode != 200) {
        // Log the server response for debugging
        print('Logout failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to logout: ${response.body}');
      }

      await clearToken(); // Clear the token upon successful logout
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Error during logout: $e');
    }
  }

  // Get current user details
  Future<Map<String, dynamic>> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/flutterprofile'), // Endpoint to get user details
        headers: {
          'Authorization': 'Bearer $token', // Pass the token in the header
        },
      );

      if (response.statusCode != 200) {
        // Log the server response for debugging
        print('Failed to load user: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user: ${response.body}');
      }

      return jsonDecode(response.body); // Return user data as a map
    } catch (e) {
      print('Error while getting user: $e');
      throw Exception('Error while getting user: $e');
    }
  }
}
