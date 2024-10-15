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
      } else {
        throw Exception('Access denied: User is not an officer');
      }
    } else if (response.statusCode == 401) {
      // Handle invalid credentials with specific message
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
      headers: {'Content-Type': 'application/json',
      'Accept': 'application/json', // Add this line to expect JSON response
      },
      body: jsonEncode({
        'username': username,             // 1. Username
        'name': name,                     // 2. Name
        'email': email,                   // 3. Email
        'password': password,             // 4. Password
        'password_confirmation': password, // 5. Confirm Password
        'phone_no': phoneNo,              // 6. Phone Number
        'role': 'officer',                // 7. Role: officer
      }),
    );

    // Check if the registration failed (any status other than 201)
    if (response.statusCode != 201) {
      // Print status code and response body for debugging
      print('Registration failed: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to register user: ${response.body}');
    }
  } catch (e) {
    // Print the error for further investigation
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
