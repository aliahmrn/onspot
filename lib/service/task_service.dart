import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskService {
  final String baseUrl = 'http://192.168.124.145:8000/api';
  final Logger logger = Logger();
   final SupabaseClient _client = Supabase.instance.client;

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Map<String, dynamic>>> fetchTasks(int cleanerId) async {
    try {
      logger.i('Fetching tasks for Cleaner ID: $cleanerId');

      // Step 1: Fetch unnotified tasks from Laravel API
      String? token = await _getToken();

      if (token == null) {
        logger.w('User not authenticated.');
        throw Exception('Authentication failed');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tasks/unnotified/$cleanerId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        logger.e('Failed to fetch unnotified tasks. Status: ${response.statusCode}');
        throw Exception('Failed to fetch unnotified tasks');
      }

      logger.i('Response from Laravel API: ${response.body}');

      // Parse the Laravel API response
      final List<dynamic> apiData = jsonDecode(response.body)['data'];
      if (apiData.isEmpty) {
        logger.w('No unnotified tasks found.');
        return [];
      }

      // Extract complaint IDs and their `is_notified` statuses
      final Map<int, bool> taskNotificationStatus = {
        for (var item in apiData)
          int.parse(item['complaint_id'].toString()): item['is_notified'] == 1
      };

      logger.i('Task Notification Status: $taskNotificationStatus');

      // Step 2: Fetch tasks from Supabase using the complaint IDs
      final List<int> complaintIds = taskNotificationStatus.keys.toList();
      final orQuery = complaintIds.map((id) => 'complaint_id.eq.$id').join(',');

      final supabaseResponse = await _client
          .from('complaint_cleaner')
          .select('*, complaint(*)')
          .or(orQuery)
          .order('assigned_date', ascending: false);

      if (supabaseResponse.isEmpty) {
        logger.w('No matching tasks found in Supabase.');
        return [];
      }

      logger.i('Tasks from Supabase: $supabaseResponse');

      // Merge Supabase tasks with notification status from Laravel, avoiding duplicates
      final Set<int> seenComplaintIds = {};
      final tasks = List<Map<String, dynamic>>.from(supabaseResponse)
          .where((task) {
            final complaintId = task['complaint']['id'];
            if (seenComplaintIds.contains(complaintId)) {
              return false; // Skip duplicate complaint_id
            } else {
              seenComplaintIds.add(complaintId);
              return true;
            }
          })
          .map((task) {
            final complaintId = task['complaint']['id'];
            return {
              'complaint_id': complaintId,
              'comp_desc': task['complaint']['comp_desc'],
              'comp_location': task['complaint']['comp_location'],
              'comp_date': task['complaint']['comp_date'],
              'comp_time': task['complaint']['comp_time'],
              'comp_status': task['complaint']['comp_status'],
              'assigned_date': task['assigned_date'],
              'no_of_cleaners': task['no_of_cleaners'],
              'assigned_by': task['assigned_by'],
              'is_notified': taskNotificationStatus[complaintId] ?? false, // Add `is_notified` status
            };
          })
          .toList();

      logger.i('Mapped Tasks: $tasks');
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
    // Fetch the latest task assigned to the cleaner
    final response = await _client
        .from('complaint_cleaner') // Fetch data from the complaint_cleaner table
        .select('*, complaint(*)') // Include related complaint details
        .eq('cleaner_id', cleanerId) // Filter by cleaner_id
        .order('assigned_date', ascending: false) // Order by assigned_date descending
        .limit(1) // Limit the result to the latest task
        .single(); // Fetch a single task

    // Check if the response is valid
    if (response.isEmpty) {
      logger.w('No latest task found for Cleaner ID: $cleanerId');
      return null;
    }

    // Log the fetched response
    logger.i('Latest Task Fetched: $response');

    // Map the response to a usable structure
    return {
      'complaint_id': response['complaint']['id'],
      'comp_desc': response['complaint']['comp_desc'],
      'comp_location': response['complaint']['comp_location'],
      'comp_date': response['complaint']['comp_date'],
      'comp_time': response['complaint']['comp_time'],
      'assigned_date': response['assigned_date'],
      'no_of_cleaners': response['no_of_cleaners'],
      'assigned_by': response['assigned_by'],
    };
  } catch (e) {
    // Log any errors encountered
    logger.e('Error fetching latest task: $e');
    return null;
  }
}

  Future<void> notifiedTasks(int complaintId, int cleanerId) async {
    try {
      String? token = await _getToken();

      if (token == null) {
        logger.w('User not authenticated.');
        throw Exception('Authentication failed');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/tasks/notified'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'complaint_id': complaintId,
          'cleaner_id': cleanerId,
        }),
      );

      if (response.statusCode == 200) {
        logger.i('Task marked as completed successfully');
      } else {
        logger.e('Failed to mark task as completed. Status: ${response.statusCode}');
        throw Exception('Failed to mark task as completed');
      }
    } catch (e) {
      logger.e('Error marking task as completed: $e');
      throw e;
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
