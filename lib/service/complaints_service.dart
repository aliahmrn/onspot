import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class ComplaintsService {
  final String baseUrl = 'http://192.168.1.105:8000/api';
  final Logger _logger = Logger(); // Initialize Logger

  Future<List<Map<String, dynamic>>> fetchComplaints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/complaints'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        _logger.w('Response status: ${response.statusCode}');
        _logger.w('Response body: ${response.body}');
        throw Exception('Failed to load complaints: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching complaints: $e');
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
      final responseData = json.decode(response.body);
      return responseData;
    } else {
      throw Exception('Failed to load complaint details');
    }
  }

  Future<void> assignTask(String complaintId, Map<String, dynamic> body) async {
    try {
      // Retrieve credentials
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final supervisorIdStr = prefs.getString('supervisorId');
      final supervisorId = int.tryParse(supervisorIdStr ?? '');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token is missing.');
      }
      if (supervisorId == null) {
        throw Exception('Supervisor ID is missing.');
      }

      // Prepare request body
      final modifiedBody = {
        'cleaner_ids': body['cleaner_ids'],
        'no_of_cleaners': body['no_of_cleaners'],
        'assigned_by': supervisorId,
      };

      // Log debug info
      _logger.i('Assign Task URL: $baseUrl/supervisor/assign-task/$complaintId/assign');
      _logger.i('Request Body: ${jsonEncode(modifiedBody)}');
      _logger.i('Token: $token');
      _logger.i('Supervisor ID: $supervisorId');

      // Send the request
      final response = await http.post(
        Uri.parse('$baseUrl/supervisor/assign-task/$complaintId/assign'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(modifiedBody),
      );

      // Log response
      _logger.i('Response Status: ${response.statusCode}');
      _logger.i('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to assign task: ${response.statusCode} - ${response.body}');
      }

      _logger.i('Task assigned successfully!');
    } catch (e, stackTrace) {
      _logger.e('Error in assignTask: $e', stackTrace);
      rethrow;
    }
  }

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

Future<Map<String, dynamic>> fetchAssignedTaskDetails(String complaintId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');

  final url = '$baseUrl/supervisor/history/$complaintId';
  _logger.i('Fetching task details from URL: $url with token: $token');

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    _logger.i('Response Status: ${response.statusCode}');
    _logger.i('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      _logger.w('Failed to fetch task details: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load task details');
    }
  } catch (e) {
    _logger.e('Error fetching task details: $e');
    throw Exception('Failed to load task details');
  }
}

}
