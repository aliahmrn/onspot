import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Add this for date formatting

class AuthService {
  final String baseUrl = 'http://192.168.1.110:8000/api'; // Android Emulator

  // Login function for cleaners
  // Login function for cleaners
  Future<void> login(String input, String password) async {
    try {
      final requestBody = jsonEncode({
        'login': input,
        'password': password,
      });

      print('Request Body: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/flutterlogin'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['user'] != null && data['user']['id'] != null) {
          final String token = data['token'];
          final String role = data['user']['role'];
          final String userName = data['user']['name'];
          final String cleanerId = data['user']['id'].toString(); 
          final String email = data['user']['email'];
          final String phoneNo = data['user']['phone_no'];

          // Save the details using the newly defined saveUserDetails method
          await saveUserDetails(token, role, userName, cleanerId, email, phoneNo);

          // Check if the cleaner has submitted attendance for today
          bool hasSubmittedAttendance = await checkAttendanceStatus();
          print('Has submitted attendance today: $hasSubmittedAttendance');
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

  // Method to save user details in SharedPreferences
  Future<void> saveUserDetails(String token, String role, String userName, String cleanerId, String email, String phoneNo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('role', role);
      await prefs.setString('userName', userName);
      await prefs.setString('cleanerId', cleanerId); // Save cleaner ID
      await prefs.setString('email', email);
      await prefs.setString('phoneNo', phoneNo);
      print('User details saved successfully');
    } catch (e) {
      print('Failed to save user details: $e');
      throw Exception('Failed to save user details: $e');
    }
  }

  // Save attendance submission date
  Future<void> saveAttendanceSubmissionDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await prefs.setString('attendanceDate', today);
      print('Attendance submission date saved: $today');
    } catch (e) {
      print('Failed to save attendance submission date: $e');
      throw Exception('Failed to save attendance submission date: $e');
    }
  }

  // Check if attendance has been submitted for today
  Future<bool> checkAttendanceStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? attendanceDate = prefs.getString('attendanceDate');
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (attendanceDate == today) {
      return true; // Attendance has been submitted for today
    } else {
      return false; // Attendance has not been submitted today
    }
  }

  // Clear all stored user details from shared preferences
  Future<void> clearUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userRole');
    await prefs.remove('userName');
    await prefs.remove('cleanerId');
    await prefs.remove('email');
    await prefs.remove('phoneNo');
    await prefs.remove('attendanceDate'); // Clear attendance date on logout
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
          'Accept': 'application/json', // Ensure you accept JSON responses
        },
      );

      if (response.statusCode != 200) {
        print('Logout failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to logout: ${response.body}');
      }

      await clearUserDetails(); // Clear all stored user details upon successful logout
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Error during logout: $e');
    }
  }

  // Get current user details from API
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
        'role': 'cleaner',                // 7. Role: cleaner
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

  Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? ''; // Return token or empty string if not found
  }
}
