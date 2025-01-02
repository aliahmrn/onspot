import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class ProfileService {
  final String baseUrl = 'http://192.168.1.105:8000/api';
  final Logger _logger = Logger();

  /// Fetch profile data
  Future<Map<String, dynamic>> fetchProfile(String token) async {
    final url = Uri.parse('$baseUrl/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Timeout added

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        _logger.i('Profile data fetched successfully: $profileData');
        return profileData;
      } else if (response.statusCode == 401) {
        _logger.e('Unauthorized access. Please log in again.');
        throw Exception('Unauthorized. Please log in again.');
      } else {
        _logger.e('Failed to fetch profile: ${response.body}');
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error during profile fetch: $e');
      throw Exception('Failed to fetch profile. Error: $e');
    }
  }

  /// Update profile data
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
        _logger.e('Error during profile update: ${response.body}');
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      _logger.e('Exception occurred during profile update: $e');
      throw Exception('Error during profile update: $e');
    }
  }

  /// Upload profile picture
  Future<String> uploadProfilePicture(String token, String filePath) async {
    final uri = Uri.parse('$baseUrl/profile/picture');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath('profile_pic', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final profilePicUrl = responseData['profile_pic'];
        _logger.i('Profile picture uploaded successfully: $profilePicUrl');
        return profilePicUrl;
      } else {
        _logger.e('Failed to upload profile picture: ${response.body}');
        throw Exception('Failed to upload profile picture: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error during profile picture upload: $e');
      throw Exception('Error during profile picture upload: $e');
    }
  }

  /// Delete profile picture
  Future<String?> deleteProfilePicture(String token) async {
    final uri = Uri.parse('$baseUrl/profile/picture');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final profilePic = responseData['profile_pic'];
        _logger.i('Profile picture deleted successfully. New profile picture: $profilePic');
        return profilePic;
      } else {
        _logger.e('Failed to delete profile picture: ${response.body}');
        throw Exception('Failed to delete profile picture: ${response.body}');
      }
    } catch (e) {
      _logger.e('Error during profile picture deletion: $e');
      throw Exception('Error during profile picture deletion: $e');
    }
  }
}
