import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // For JSON parsing
import 'dart:async';

class ComplaintService {
  final ImagePicker picker = ImagePicker();
  final Logger _logger = Logger();

  // Base URL for API
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method to pick an image from the gallery or camera
  Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final XFile? pickedFile = await picker.pickImage(source: source);
    return pickedFile?.path; // Return the path or null
  }

  // Method to submit a complaint API request
  Future<bool> submitComplaint({
    required String description,
    required String location,
    required DateTime date,
    String? imagePath,
  }) async {
    // Validate input
    if (description.isEmpty || location.isEmpty) {
      throw Exception('Description and location are required.');
    }

    String? token = await getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/complaints'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['comp_date'] = DateFormat('yyyy-MM-dd').format(date);
    request.fields['comp_time'] = DateFormat('HH:mm').format(date); // Use the time from the scheduledDateTime
    request.fields['comp_desc'] = description;
    request.fields['comp_location'] = location;

    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('comp_image', imagePath));
    }

    try {
      var streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      // Log the response for debugging purposes
      _logger.i('Response: ${response.statusCode}, Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse and log the response
        final responseData = jsonDecode(response.body);
        _logger.i('Complaint submitted successfully: $responseData');
        return true;
      } else if (response.statusCode == 401) {
        _logger.e('Unauthorized. Please log in again.');
        throw Exception('Unauthorized. Please log in again.');
      } else {
        _logger.e('Failed to submit complaint: ${response.body}');
        return false;
      }
    } catch (error) {
      if (error is TimeoutException) {
        _logger.e('Request timed out: $error');
        throw Exception('Request timed out. Please try again.');
      } else {
        _logger.e('Unexpected error: $error');
        rethrow;
      }
    }
  }
}
