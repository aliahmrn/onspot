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

  Future<void> updateProfile(String token, Map<String, String> updatedData, String? profilePicturePath) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/profile?_method=PUT'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    updatedData.forEach((key, value) {
      request.fields[key] = value;
    });

    if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePicturePath));
    }

    final streamedResponse = await request.send();
    final responseData = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      _logger.i('Profile updated successfully: $responseData');
    } else {
      _logger.e('Failed to update profile: $responseData');
      throw Exception('Failed to update profile: $responseData');
    }
  }
}
