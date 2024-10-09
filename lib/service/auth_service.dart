import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Replace with your API URL

  Future<void> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to register user');
    }
  }

  // Modified login function for cleaner only
  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_type': 'cleaner', // Fixed user type for cleaner login
        'username': username, // Only username for cleaner login
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Store token and role in shared preferences
      await saveToken(data['token'], 'cleaner'); // Save with user type as 'cleaner'
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Method to save token and user role
  Future<void> saveToken(String token, String userRole) async {
    // Store token and user role in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('userRole', userRole); // Store user role if needed
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }

    await prefs.remove('token'); // Remove token on logout
    await prefs.remove('userRole'); // Remove user role on logout
  }

  Future<Map<String, dynamic>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load user');
    }

    return jsonDecode(response.body);
  }
}
