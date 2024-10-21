import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class ComplaintService {
  // Get token from SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method to submit a complaint API request
  Future<bool> submitComplaint({
    required String description,
    required String location,
    required DateTime date,
    String? imagePath,
  }) async {
    String? token = await getToken();
    print('Token: $token'); // Debugging
    if (token == null) {
      throw Exception('User not authenticated');
    }

    var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:8000/api/complaints'));
    request.headers['Authorization'] = 'Bearer $token';

    // Fields
    request.fields['comp_date'] = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    request.fields['comp_time'] = DateFormat('HH:mm').format(DateTime.now().toUtc());
    request.fields['comp_desc'] = description;
    request.fields['comp_location'] = location;

    // Add image if it exists
    if (imagePath != null && imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('comp_image', imagePath));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // Check the response status code and return a boolean
    if (response.statusCode == 201) {
      return true; // Success
    } else {
      print('Failed to submit complaint: ${response.body}');
      return false; // Failure
    }
  }

  // Image picker
  Future<String?> pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return image.path; // Return image path
      }
    } catch (e) {
      throw Exception('Error selecting image: $e');
    }
    return null;
  }
}
