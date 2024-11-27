import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class TaskService {
  final String baseUrl = 'http://192.168.1.105:8000/api';
  final Logger logger = Logger();

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Fetch tasks (complaints) assigned to a specific cleaner
  Future<List<Map<String, dynamic>>?> getCleanerTasks(int cleanerId) async {
    String? token = await _getToken();

    if (token == null) {
      logger.w('User not authenticated.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/cleaner/$cleanerId/tasks'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        logger.e('Failed to fetch cleaner tasks. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching cleaner tasks', error: e);
      return null;
    }
  }

  // Fetch details of a specific complaint
  Future<Map<String, dynamic>?> getComplaintDetails(int complaintId) async {
    String? token = await _getToken();

    if (token == null) {
      logger.w('User not authenticated.');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks/complaint/$complaintId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, dynamic>.from(data);
      } else {
        logger.e('Failed to fetch complaint details. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching complaint details', error: e);
      return null;
    }
  }

  // Fetch the latest task assigned to a specific cleaner
Future<Map<String, dynamic>?> getLatestTask(int cleanerId) async {
  String? token = await _getToken();

  if (token == null) {
    logger.w('User not authenticated.');
    return null;
  }

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/cleaner/$cleanerId/tasks/latest'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['task']; // Ensure this key exists in the response.
    } else {
      logger.e('Failed to fetch latest task. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    logger.e('Error fetching latest task', error: e);
    return null;
  }
}


}
