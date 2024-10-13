import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://10.0.2.2/onspot_facility/public/api'; // Update as needed for emulator

  // Login function for officers
  Future<void> login(String input, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/flutterlogin'), // Endpoint for officer login
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'input': input, // The input can be either username or email
        'password': password, // Password for login
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String token = data['token']; // Ensure your API returns a token

      // Save token and role (officer in this case)
      await saveToken(token, 'officer');
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Register function (if needed)
  Future<void> register(String name, String email, String password, String role) async {
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
      throw Exception('Failed to register user: ${response.body}');
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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/logout'), // Use the logout endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Pass the token in the header
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout: ${response.body}');
    }

    await clearToken(); // Clear the token upon successful logout
  }

  // Get current user details
  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/flutterprofile'), // Endpoint to get user details
      headers: {
        'Authorization': 'Bearer $token', // Pass the token in the header
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load user: ${response.body}');
    }

    return jsonDecode(response.body); // Return user data as a map
  }
}
