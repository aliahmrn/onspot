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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.get(
      Uri.parse('$baseUrl/supervisor/assign-task/$complaintId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load complaint details');
    }
  }

// New method to send assigned task data to the backend with detailed logging
Future<void> assignTask(String complaintId, Map<String, dynamic> body) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  // Modify the body to ensure no_of_cleaners is an integer
  final modifiedBody = {
    'cleaner_ids': body['cleaner_ids'], // List of integers
    'no_of_cleaners': int.tryParse(body['no_of_cleaners']?.toString() ?? '1'), // Convert to int if needed
    'assigned_by': body['assigned_by'], // Assuming assigned_by is a string ID
  };

  print('Modified Request Body: ${jsonEncode(modifiedBody)}'); // Log the modified body

  final response = await http.post(
    Uri.parse('$baseUrl/supervisor/assign-task/$complaintId/assign'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(modifiedBody),
  );

  print('Response Status: ${response.statusCode}');
  print('Response Body: ${response.body}');

  if (response.statusCode != 200) {
    print('Error assigning task: ${response.statusCode} - ${response.body}');
    throw Exception('Failed to assign task: ${response.body}');
  } else {
    print('Task assigned successfully!');
  }
}

  //history
  Future<List<Map<String, dynamic>>> fetchAssignedTasksHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/supervisor/history'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load assigned tasks history');
    }
  }

    //history details
 Future<Map<String, dynamic>> fetchAssignedTaskDetails(String complaintId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/history/$complaintId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch task details: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load task details');
      }
    } catch (e) {
      print('Error fetching task details: $e');
      throw Exception('Failed to load task details');
    }
  }

}
