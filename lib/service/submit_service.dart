import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class ComplaintService {
  final _logger = Logger();
  final ImagePicker _picker = ImagePicker();

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// **🔹 Pick Image (Fixed - Now Accessible)**
  Future<String?> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 1024, // Optional: Resize image to save space
        maxWidth: 1024,
      );
      if (pickedFile != null) {
        _logger.i('Image picked: ${pickedFile.path}');
        return pickedFile.path;
      } else {
        _logger.w('No image selected.');
        return null;
      }
    } catch (e) {
      _logger.e('Error picking image: $e');
      return null;
    }
  }

  /// **🔹 Submit Complaint API Request**
  Future<bool> submitComplaint({
    required String description,
    required String location,
    required DateTime date,
    required String time,
    String? imagePath,
  }) async {
    final url = Uri.parse('$baseUrl/complaints');
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] =
          'Bearer 2088|8CLSJccW6xonzPlOedzEWeB848vZBXuKID3Iyk1y4ff54565' // ✅ Added Bearer Token
      ..fields['comp_desc'] = description
      ..fields['comp_location'] = location
      ..fields['comp_date'] = date.toIso8601String().split('T').first
      ..fields['comp_time'] = time;

    // **✅ Attach Image if Available**
    if (imagePath != null && File(imagePath).existsSync()) {
      request.files
          .add(await http.MultipartFile.fromPath('comp_image', imagePath));
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(responseBody);
        _logger
            .i('Complaint submitted successfully: ${jsonResponse['message']}');
        return true; // ✅ Return success
      } else {
        final errorResponse = json.decode(responseBody);
        _logger.e('Failed to submit complaint: ${errorResponse['message']}');
        return false; // ✅ Return failure
      }
    } catch (e) {
      _logger.e('Error submitting complaint: $e');
      return false; // ✅ Return failure
    }
  }
}
