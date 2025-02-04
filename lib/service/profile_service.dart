import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class ProfileService {
  final String baseUrl = 'http://192.168.184.146:8000/api';
  final Logger _logger = Logger();

  Future<Map<String, dynamic>> fetchProfile(String token) async {
    final url = Uri.parse('$baseUrl/profile');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final profileData = jsonDecode(response.body);
        return profileData; // Include all returned fields, including 'building'
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch profile. Error: $e');
    }
  }

  Future<void> updateProfile(String token, Map<String, dynamic> updatedData) async {
    final uri = Uri.parse('$baseUrl/profile');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: updatedData,
      );

      if (response.statusCode == 200) {
        return; // Update successful
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during profile update: $e');
    }
  }


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
        final responseData = jsonDecode(response.body);
        return responseData['profile_pic']; // Returns the updated profile picture URL
      } else {
        throw Exception('Failed to upload profile picture: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during profile picture upload: $e');
    }
  }

  Future<String?> deleteProfilePicture(String token) async {
    final uri = Uri.parse('$baseUrl/profile/picture');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.delete(uri, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final profilePic = responseData['profile_pic'];
        _logger.i('✅ Profile picture deleted successfully. New profilePic: $profilePic');
        return profilePic; // Return the updated profile picture URL
      } else {
        throw Exception('Failed to delete profile picture: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during profile picture deletion: $e');
    }
  }
}
