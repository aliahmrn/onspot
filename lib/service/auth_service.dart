import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://127.0.0.1:8000/api'; // Android Emulator

  // Login function for supervisors
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
        print("Login Response: $data");

        // Extract token and store credentials from the response
        final String token = data['token'];
        final String role = data['user']['role'];
        final String svId = data['user']['id'].toString();
        final String email = data['user']['email'];
        final String username = data['user']['username'];
        final String name = data['user']['name'];
        final String phoneNo = data['user']['phone_no'];

        // Check if role is "supervisor" before proceeding
        if (role == 'supervisor') {
          // Save token, role, and additional details
          await saveUserDetails(token, role, svId, email, username, name, phoneNo);
        } else {
          throw Exception('Access denied: User is not a supervisor');
        }
      } else if (response.statusCode == 401) {
        // Handle invalid credentials with a specific message
        throw Exception('Invalid login credentials.');
      }
    } catch (e) {
      throw Exception('Error during login: ${e.toString()}');
    }
  }

  // Save token, role, and additional user details (ID, email, username, name, phone number)
  Future<void> saveUserDetails(String token, String role, String svId, String email, String username, String name, String phoneNo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);               // Save token
    await prefs.setString('role', role);         // Save role
    await prefs.setString('supervisorId', svId);       // Save supervisor ID
    await prefs.setString('email', email);               // Save email
    await prefs.setString('username', username);         // Save username
    await prefs.setString('name', name);                 // Save name
    await prefs.setString('phoneNo', phoneNo);           // Save phone number
    print('Supervisor details saved successfully');
  }

  // Clear stored user details
  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('supervisorId'); 
    await prefs.remove('email');
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('phoneNo');
    print('User details cleared');
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

      await clearUserDetails(); // Clear the token and user details upon successful logout
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
        Uri.parse('$baseUrl/profile'), // Endpoint to get user details
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

  // Register function with default role "supervisor"
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

      // Check if the registration failed (any status other than 201)
      if (response.statusCode != 201) {
        print('Registration failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register user: ${response.body}');
      }
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Error during registration: $e');
    }
  }
 

  // Send Reset Code
  Future<void> sendResetCode(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        print('Reset code sent successfully.');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to send reset code.');
      }
    } catch (e) {
      throw Exception('Error during forgot password request: ${e.toString()}');
    }
  }

  // Reset Password (sends the email, code, and new password to the backend for verification and reset)
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
        print('Password has been reset successfully.');
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to reset password.');
      }
    } catch (e) {
      throw Exception('Error during password reset: ${e.toString()}');
    }
  }
}


