import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class ProfileService {
  final String baseUrl = 'http://192.168.1.105:8000/api';
  final Logger _logger = Logger();
  

  Future<Map<String, dynamic>> fetchProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> profileData = json.decode(response.body);
      _logger.i('Profile data fetched: $profileData');
      return profileData;
    } else {
      _logger.e('Failed to load profile: ${response.body}');
      throw Exception('Failed to load profile');
    }
  }

Future<void> updateProfile(String token, Map<String, String> updatedData) async {
  final uri = Uri.parse('$baseUrl/profile?_method=PUT');
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  // Log the token and the data being sent
  _logger.i('Token being sent: $token');
  _logger.i('Updated Data being sent: $updatedData');

  try {
    final response = await http.post(
      uri,
      headers: headers,
      body: updatedData,
    );

    if (response.statusCode == 200) {
      _logger.i('Profile updated successfully: ${response.body}');
    } else {
      _logger.e('Error response: ${response.body}');
      throw Exception('Failed to update profile: ${response.body}');
    }
  } catch (e) {
    _logger.e('Exception occurred: $e');
    rethrow; // Rethrow the error for further handling
  }
}

}
