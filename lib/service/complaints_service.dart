import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String baseUrl = 'http://192.168.179.145:8000/api';



Future<List<Map<String, dynamic>>> fetchComplaints() async {
  final response = await _client
      .from('complaint')
      .select()
      .eq('comp_status', 'pending'); // Filters for complaints with comp_status = 'pending'

  return List<Map<String, dynamic>>.from(response);
}


Future<Map<String, dynamic>> fetchComplaintDetails(String complaintId) async {
  try {
    final url = Uri.parse('$baseUrl/supervisor/assign-task/$complaintId');

    // Retrieve the bearer token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final bearerToken = prefs.getString('token'); // Replace with your token key

    if (bearerToken == null) {
      throw Exception('Bearer token is missing. Please log in again.');
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken', // Include the token in the header
      },
    );
    

    // Debug log the response body for further inspection
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid bearer token.');
    } else {
      throw Exception(
        'Failed to fetch complaint details. Status code: ${response.statusCode}',
      );
    }
  } catch (e) {
    print('Error fetching complaint details: $e');
    throw Exception('Error fetching complaint details: $e');
  }
}

Future<List<Map<String, dynamic>>> fetchAssignedTasksHistory({
  required int supervisorId,
  String? statusFilter,
  String? monthFilter,
}) async {
  try {
    print('Fetching tasks for supervisorId: $supervisorId, statusFilter: $statusFilter, monthFilter: $monthFilter');

    // Call the RPC function or query with filters
    final response = await _client.rpc(
      'filter_by_month',
      params: {
        'supervisor_id': supervisorId,
        'status_filter': statusFilter,
        'month_filter': monthFilter,
      },
    );

    // Log the raw response
    print('RPC Response: $response');

    // Ensure the response is a List of JSON objects
    if (response is List<dynamic>) {
      // Parse the JSON response into a list of maps
      final List<Map<String, dynamic>> tasks = List<Map<String, dynamic>>.from(
        response.map((task) => Map<String, dynamic>.from(task)),
      )..sort((a, b) {
          // Sort by comp_date in descending order
          final dateA = DateTime.tryParse(a['assigned_date'] ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b['assigned_date'] ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

      print('Raw tasks: $tasks');

      // Map tasks to include `complaint_id` and `assigned_date`
      final List<Map<String, dynamic>> formattedTasks = tasks.map((task) {
        return {
          'complaint_id': task['complaint_id'], // Use the correct complaint_id
          'comp_desc': task['comp_desc'],
          'comp_date': task['comp_date'],
          'assigned_date': task['assigned_date'], // Include the assigned_date from complaint_cleaner
          'no_of_cleaners': task['no_of_cleaners'],
          'comp_status': task['comp_status'], // Add additional fields as needed
        };
      }).toList();

      // Filter tasks to include only one per unique complaint_id
      final Set<int> seenComplaintIds = {};
      final List<Map<String, dynamic>> uniqueTasks = formattedTasks.where((task) {
        final complaintId = task['complaint_id'] as int?;
        if (complaintId != null && !seenComplaintIds.contains(complaintId)) {
          seenComplaintIds.add(complaintId);
          return true;
        }
        return false;
      }).toList();

      print('Filtered unique tasks: $uniqueTasks');
      return uniqueTasks;
    } else {
      throw Exception('Unexpected response type from RPC function');
    }
  } catch (e) {
    print('Error in fetchAssignedTasksHistory: $e');
    throw Exception('Error fetching task history: $e');
  }
}


  Future<Map<String, dynamic>> fetchHistoryDetails(String complaintId) async {
    try {
      print('Fetching complaint details for complaintId: $complaintId');

      // Step 1: Fetch complaint and complaint_cleaner details from Supabase
      final response = await _client
          .from('complaint')
          .select('*, complaint_cleaner(cleaner_id, assigned_date)')
          .eq('id', complaintId)
          .maybeSingle(); // Fetch single row or null if not found

      print('Complaint response from Supabase: $response');

      if (response == null) {
        print('No complaint found for ID: $complaintId');
        throw Exception('Complaint not found');
      }

      // Step 2: Parse complaint data
      final complaint = Map<String, dynamic>.from(response);

      // Extract cleaner IDs and officer ID
      final cleanerIds = (complaint['complaint_cleaner'] as List<dynamic>? ?? [])
          .map((e) => e['cleaner_id'] as int)
          .toList();
      final officerId = complaint['officer_id'] as int?;

      print('Cleaner IDs: $cleanerIds');
      print('Officer ID: $officerId');

      if (officerId == null || cleanerIds.isEmpty) {
        throw Exception('Invalid officer or cleaner IDs');
      }

      // Step 3: Fetch officer and cleaner names from Laravel using user_mapping table
      final userIds = <int>[officerId, ...cleanerIds];
      print('Fetching user names for userIds: $userIds');
      final userNames = await _fetchUserNames(userIds);

      print('User names fetched: $userNames');

      // Step 4: Add names and related details to complaint object
      complaint['officer_name'] = userNames[officerId] ?? 'Unknown Officer';
      complaint['assigned_cleaners'] = cleanerIds
          .map((id) => {
                'cleaner_id': id,
                'cleaner_name': userNames[id] ?? 'Unknown Cleaner',
              })
          .toList();

      print('Final complaint object: $complaint');

      return complaint;
    } catch (e) {
      print('Error fetching history details: $e');
      throw Exception('Error fetching history details: $e');
    }
  }

  Future<Map<int, String>> _fetchUserNames(List<int> userIds) async {
    try {
      final url = Uri.parse('$baseUrl/user-names'); // Laravel API endpoint
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_ids': userIds}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return {for (var user in data) user['id'] as int: user['name'] as String};
      } else {
        throw Exception('Failed to fetch user names. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user names: $e');
      throw Exception('Error fetching user names: $e');
    }
  }


  Future<Map<String, dynamic>?> fetchLatestComplaint() async {
  try {
    print('Fetching the latest complaint...');
    final response = await _client
        .from('complaint')
        .select()
        .eq('comp_status', 'pending') // Filter by `comp_status = 'pending'`
        .order('created_at', ascending: false) // Order by creation date (newest first)
        .limit(1)
        .maybeSingle(); // Fetch the latest complaint or return null if none exist

    print('Query response: $response'); // Log the response

    if (response == null) {
      print('No pending complaints found.');
      return null;
    }

    return Map<String, dynamic>.from(response); // Convert response to Map
  } catch (e) {
    print('Error in fetchLatestComplaint: $e');
    throw Exception('Error fetching latest complaint: $e');
  }
  }
  

 Future<Map<String, dynamic>> assignTask({
    required String complaintId,
    required List<int> cleanerIds,
    required int noOfCleaners,
    required int assignedBy,
  }) async {
    try {
      // Step 1: Prepare the request body
      final Map<String, dynamic> requestBody = {
        'cleaner_ids': cleanerIds,
        'no_of_cleaners': noOfCleaners,
        'assigned_by': assignedBy,
      };

      // Step 2: Retrieve Bearer Token
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      // Step 3: Make the HTTP request
      final url = Uri.parse('$baseUrl/supervisor/assign-task/$complaintId/assign');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: json.encode(requestBody),
      );

      // Step 4: Parse the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Invalid bearer token.');
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(
            'Failed to assign task. Status code: ${response.statusCode}. Error: ${errorBody['message']}');
      }
    } catch (e) {
      print('Error in assignTask: $e');
      throw Exception('Error assigning task: $e');
    }
  }
}

