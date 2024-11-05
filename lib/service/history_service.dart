import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Function to fetch the complaint history and return the most recent complaint
Future<Map<String, dynamic>?> fetchMostRecentComplaint() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');  // Retrieve token from SharedPreferences

  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.get(
    Uri.parse('http://192.168.1.121:8000/api/complaints-history'),
    headers: {
      'Authorization': 'Bearer $token', // Pass token in Authorization header
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> complaints = json.decode(response.body);

    // Return the first complaint as the most recent, if available
    return complaints.isNotEmpty ? complaints.first : null;
  } else {
    throw Exception('Failed to load complaints');
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
    Uri.parse('http://192.168.1.121:8000/api/complaints-history'),
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
