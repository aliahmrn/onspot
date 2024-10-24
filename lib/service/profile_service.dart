import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class ProfileService {
  final String baseUrl = 'http://10.0.2.2:8000/api';
  final Logger _logger = Logger(); // Initialize the logger

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
      // Ensure the profile picture URL is complete
      if (profileData['profile_pic'] != null) {
        profileData['profile_pic'] = '$baseUrl${profileData['profile_pic']}';
      }
      return profileData;
    } else {
      _logger.e('Failed to load profile: ${response.body}');
      throw Exception('Failed to load profile');
    }
  }

  Future<void> updateProfile(
    String token,
    Map<String, String> updatedData,
    String? profilePicturePath,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/profile?_method=PUT'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Add updated fields
    updatedData.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add the profile picture if provided
    if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePicturePath));
    }

    // Log the request details
    _logger.i('Request URL: ${request.url}');
    _logger.d('Request Headers: ${request.headers}');
    _logger.d('Request Fields: ${request.fields}');

    try {
      final streamedResponse = await request.send();
      final responseData = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200) {
        _logger.i('Profile updated successfully: $responseData');
      } else {
        _logger.e('Failed to update profile: $responseData');
        throw Exception('Failed to update profile: $responseData');
      }
    } catch (error) {
      _logger.e('Error occurred during profile update: $error');
      throw Exception('Error occurred during profile update: $error');
    }
  }
}