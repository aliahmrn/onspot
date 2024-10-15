import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Android Emulator

  // Login function for cleaners
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

        // Log the entire response to see its structure
        print('API Response: $data');

        // Check if the expected keys exist
        if (data['user'] != null && data['user']['id'] != null) {
          // Extract token, role, name, and cleanerID from the response
          final String token = data['token'];
          final String role = data['user']['role'];
          final String userName = data['user']['name'];
          final String cleanerID = data['user']['id'].toString(); // Store cleanerID as a string

          // Log successful response
          print('Login successful, token: $token, role: $role, name: $userName, cleanerID: $cleanerID');

          // Save token, role, cleaner's name, and cleanerID
          await saveUserDetails(token, role, userName, cleanerID);
        } else {
          print('Error: User ID or user object is null in response.');
          throw Exception('User ID or user object is null in response.');
        }
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to login: ${response.body}');
      }
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Error during login: $e');
    }
  }

  // Save token, role, cleaner's name, and cleanerID to shared preferences
  Future<void> saveUserDetails(String token, String userRole, String userName, String cleanerID) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);       // Store token
      await prefs.setString('userRole', userRole); // Store user role
      await prefs.setString('userName', userName); // Store cleaner's name
      await prefs.setString('cleanerID', cleanerID); // Store cleaner's ID as a string

      // Log a success message
      print('User details saved successfully');
    } catch (e) {
      print('Failed to save user details: $e'); // Log the error
      throw Exception('Failed to save user details: $e');
    }
  }

  // Clear token, role, cleaner's name, and cleanerID from shared preferences
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
    await prefs.remove('userName');
    await prefs.remove('cleanerID'); // Clear cleaner's ID
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
        print('Failed to load user: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load user: ${response.body}');
      }

      return jsonDecode(response.body); // Return user data as a map
    } catch (e) {
      print('Error while getting user: $e');
      throw Exception('Error while getting user: $e');
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
        print('Registration failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Error during registration: $e');
    }
  }
}
