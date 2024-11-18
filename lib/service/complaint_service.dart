import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';

class ComplaintService {
  final ImagePicker picker = ImagePicker();
  final Logger _logger = Logger(); // Initialize logger

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

    // Method to pick an image from the gallery or camera
 // Method to pick an image from either the gallery or the camera
  Future<String?> pickImage({ImageSource source = ImageSource.gallery}) async {
    final XFile? pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      return pickedFile.path; // Return the path of the selected image
    }
    return null; // Return null if no image is picked
  }

  // Method to submit a complaint API request
  Future<bool> submitComplaint({
    required String description,
    required String location,
    required DateTime date,
    String? imagePath,
  }) async {
    String? token = await getToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8000/api/complaints'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['comp_date'] = DateFormat('yyyy-MM-dd').format(date);
    request.fields['comp_time'] = DateFormat('HH:mm').format(DateTime.now().toUtc());
    request.fields['comp_desc'] = description;
    request.fields['comp_location'] = location;

    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('comp_image', imagePath));
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Log the response for debugging purposes
      _logger.i('Response: ${response.statusCode}, Body: ${response.body}');

       if (response.statusCode == 200 || response.statusCode == 201){
        // Check and parse the response body if necessary
        final responseData = response.body;
        _logger.i('Complaint submitted successfully: $responseData');
        return true; // Indicate successful submission
      } else if (response.statusCode == 401) {
        _logger.e('Unauthorized. Please log in again.');
        throw Exception('Unauthorized. Please log in again.');
      } else {
        // Log unexpected status codes or responses
        _logger.e('Failed to submit complaint: ${response.body}');
        return false; // Return false instead of throwing an exception
      }
    } catch (error) {
      // Log and rethrow the error for debugging
      _logger.e('Error occurred during complaint submission: $error');
      rethrow; // Use rethrow to preserve the original error stack
    }
  }

  
}
