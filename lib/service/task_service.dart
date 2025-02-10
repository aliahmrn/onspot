import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';


class TaskService {
  final String baseUrl = 'http://192.168.248.145:8000/api';
  final Logger logger = Logger();

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Map<String, dynamic>>> fetchTasks(int cleanerId) async {
    try {
      logger.i('Fetching tasks for Cleaner ID: $cleanerId');

      // Fetch tasks from Laravel API
      String? token = await _getToken();

      if (token == null) {
        logger.w('User not authenticated.');
        throw Exception('Authentication failed');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tasks/$cleanerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        logger.e('Failed to fetch tasks. Status: ${response.statusCode}');
        throw Exception('Failed to fetch tasks');
      }

      logger.i('Response from Laravel API: ${response.body}');

      // Parse response
      final List<dynamic> apiData = jsonDecode(response.body)['data'];
      if (apiData.isEmpty) {
        logger.w('No tasks found.');
        return [];
      }

      // Convert response into List<Map<String, dynamic>>
      final tasks = apiData.map<Map<String, dynamic>>((task) => {
        'complaint_id': task['complaint_id'],
        'comp_desc': task['comp_desc'],
        'comp_location': task['comp_location'],
        'comp_date': task['comp_date'],
        'comp_time': task['comp_time'],
        'comp_status': task['comp_status'],
        'assigned_date': task['assigned_date'],
        'no_of_cleaners': task['no_of_cleaners'],
        'assigned_by': task['assigned_by'],
        'is_notified': (task['is_notified'] ?? 0) == 1, // Convert 1 → true, 0 → false
      }).toList();

      logger.i('Fetched Tasks: $tasks');
      return tasks;
    } catch (e) {
      logger.e('Error fetching tasks: $e');
      throw Exception('Error fetching tasks: $e');
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

        // Extract officer and supervisor details
        final officer = data['officer'];
        final supervisor = data['supervisor'];

        logger.i('Complaint Details: Officer: $officer, Supervisor: $supervisor');

        return {
          ...Map<String, dynamic>.from(data),
          'officer_name': officer?['name'] ?? 'Unknown',
          'supervisor_name': supervisor?['name'] ?? 'Unknown',
        };
      } else {
        logger.e('Failed to fetch complaint details. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching complaint details: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getLatestTask(int cleanerId) async {
    try {
      // Retrieve token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        logger.e('Token is missing. User might not be authenticated.');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tasks/latest/$cleanerId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Include Bearer Token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        logger.i('Latest Task Fetched: $data');
        return data['data']; // Extract the task details
      } else if (response.statusCode == 401) {
        logger.w('Unauthorized request. Token might be invalid.');
        return null;
      } else if (response.statusCode == 404) {
        logger.w('No latest task found for Cleaner ID: $cleanerId');
        return null;
      } else {
        logger.e('Failed to fetch latest task. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      logger.e('Error fetching latest task: $e');
      return null;
    }
  }


    Future<List<Map<String, dynamic>>> fetchHistoryTasks(int cleanerId) async {
    try {
      String? token = await _getToken();

      if (token == null) {
        logger.w('User not authenticated.');
        throw Exception('Authentication failed');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tasks/history/$cleanerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        logger.i('History tasks fetched successfully: $data');

        return List<Map<String, dynamic>>.from(data);
      } else {
        logger.e('Failed to fetch history tasks. Status: ${response.statusCode}');
        throw Exception('Failed to fetch history tasks');
      }
    } catch (e) {
      logger.e('Error fetching history tasks: $e');
      throw e;
    }
  }

}
