import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onspot_officer/widget/constants.dart';

/// Fetches complaint details by ID
Future<Map<String, dynamic>?> fetchComplaintDetails(int complaintId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Retrieve token from SharedPreferences

  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.get(
    Uri.parse('$baseUrl/complaints/$complaintId/details'), // Use baseUrl
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

/// Marks a complaint as completed
Future<bool> completeComplaint(int complaintId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Retrieve token from SharedPreferences

  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.post(
    Uri.parse('$baseUrl/complaints/$complaintId/complete'), // Use baseUrl
    headers: {
      'Authorization': 'Bearer $token', // Pass token in Authorization header
      'Content-Type': 'application/json', // Set content type if needed
    },
  );

  if (response.statusCode == 200) {
    // Handle successful response
    return true;
  } else {
    // Handle error response
    throw Exception('Failed to complete complaint: ${response.body}');
  }
}
