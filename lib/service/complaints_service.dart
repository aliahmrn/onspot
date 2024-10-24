import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintsService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<List<Map<String, dynamic>>> fetchComplaints() async {
    try {
      // Retrieve token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token'); // Assume the token is stored with the key 'token'

      // Set headers including authorization
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/complaints'),
        headers: headers, // Include headers in the request
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load complaints: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching complaints: $e');
      throw Exception('Error fetching complaints: $e');
    }
  }

Future<Map<String, dynamic>> getComplaintDetails(String complaintId) async {
  try {
    // Retrieve token from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Set headers including authorization
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Make the request to fetch complaint details
    final response = await http.get(
      Uri.parse('$baseUrl/supervisor/assign-task/$complaintId'), 
      headers: headers, // Include headers in the request
    );

    // Print the response status and raw body before decoding
    print('Response status: ${response.statusCode}');
    print('Raw response body: ${response.body}'); // Print raw response for analysis

    if (response.statusCode == 200) {
      // Decode the JSON response into a Map
      final data = json.decode(response.body);

      // Check the type of each field to ensure the data is as expected
      print('Decoded complaint details: $data');
      print('Type of "id": ${data['id'].runtimeType}');
      print('Type of "officer_id": ${data['officer_id'].runtimeType}');

      return data;
    } else {
      print('Failed to fetch complaint details with status: ${response.statusCode}');
      throw Exception('Failed to load complaint details');
    }
  } catch (e) {
    print('Error fetching complaint details: $e');
    throw Exception('Error fetching complaint details: $e');
  }
}

}
