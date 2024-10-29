import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Function to fetch complaint details by ID
Future<Map<String, dynamic>?> fetchComplaintDetails(int complaintId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');  // Retrieve token from SharedPreferences

  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/api/complaints/$complaintId/details'),  // Corrected endpoint
    headers: {
      'Authorization': 'Bearer $token', // Pass token in Authorization header
    },
  );

  if (response.statusCode == 200) {
    // Parse and return the complaint details
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load complaint details');
  }
}
