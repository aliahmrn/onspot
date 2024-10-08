import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http; // Import the HTTP package

// A function to handle the logout request
Future<void> logoutUser(String token) async {
  final url = Uri.parse('https://your-laravel-app.com/api/logout'); // Replace with your actual Laravel logout endpoint

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Logout successful');
    } else {
      print('Logout failed: ${response.body}');
    }
  } catch (e) {
    print('Error occurred while logging out: $e');
  }
}

// A function to fetch user data
Future<void> fetchUserData(String token) async {
  final url = Uri.parse('https://your-laravel-app.com/api/user'); // Replace with your actual Laravel user endpoint

  try {
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      print('User data: $userData');
    } else {
      print('Failed to retrieve user data: ${response.body}');
    }
  } catch (e) {
    print('Error occurred while fetching user data: $e');
  }
}
