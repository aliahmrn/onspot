import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Function to fetch complaint history from the API
Future<List<dynamic>> fetchComplaintHistory() async {
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
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load complaints');
  }
}
