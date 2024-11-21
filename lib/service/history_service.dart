import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Function to fetch the complaint history and return the most recent complaint
Future<Map<String, dynamic>?> fetchMostRecentComplaint() async {
  try {
    final allComplaints = await fetchComplaintHistory(); // Reuse the existing function
    if (allComplaints.isEmpty) {
      return null; // Return null if there are no complaints
    }
    // Assuming complaints are sorted by most recent first
    return allComplaints.first; 
  } catch (e) {
    throw Exception('Failed to fetch recent complaint: $e');
  }
}


// Function to fetch the entire complaint history
Future<List<Map<String, dynamic>>> fetchComplaintHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');  // Retrieve token from SharedPreferences

  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/api/complaints-history'),
    headers: {
      'Authorization': 'Bearer $token', // Pass token in Authorization header
    },
  );

  if (response.statusCode == 200) {
    // Parse and return the list of complaints
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to load complaints');
  }
}
