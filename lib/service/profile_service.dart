import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileService {
  final String baseUrl = 'http://192.168.1.110:8000/api';

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
    throw Exception('Failed to load profile');
  }
}

 // Update profile data
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

    // Add the profile picture
    if (profilePicturePath != null && profilePicturePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePicturePath));
    }

    // Logging the request details
    print('Request URL: ${request.url}');
    print('Request Headers: ${request.headers}');
    print('Request Fields: ${request.fields}');

    try {
      // Send request
      final streamedResponse = await request.send();
      final responseData = await streamedResponse.stream.bytesToString();

      // Check for success
      if (streamedResponse.statusCode != 200) {
        print('Error updating profile: $responseData');
        throw Exception('Failed to update profile: $responseData');
      }

      print('Profile updated successfully: $responseData');
    } catch (error) {
      print('Error updating profile: $error');
      throw Exception('Error occurred during profile update: $error');
    }
  }
}
