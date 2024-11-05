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
      Uri.parse('http://192.168.1.121:8000/api/complaints'),
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

      if (response.statusCode == 201) {
        _logger.i('Complaint submitted successfully');
        return true;
      } else if (response.statusCode == 401) {
        _logger.e('Unauthorized. Please log in again.');
        throw Exception('Unauthorized. Please log in again.');
      } else {
        _logger.e('Failed to submit complaint: ${response.body}');
        throw Exception('Failed to submit complaint: ${response.body}');
      }
    } catch (error) {
      _logger.e('Error occurred during complaint submission: $error');
      throw Exception('Error occurred during complaint submission: $error');
    }
  }

  
}
