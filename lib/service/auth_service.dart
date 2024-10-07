import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost/onspot_facility/public/api'; // Use your API URL

  Future<void> saveToken(String token) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> clearToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://localhost/onspot_facility/public/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['access_token']); // Save the token
    } else {
      throw Exception('Failed to login: ${response.body}'); // More informative error
    }
  }

  Future<void> logout() async {
    final token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token', // Use the stored token
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await clearToken(); // Clear the token after logout
    } else {
      throw Exception('Failed to logout: ${response.body}'); // More informative error
    }
  }
}
