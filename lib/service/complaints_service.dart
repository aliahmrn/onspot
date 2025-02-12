import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart'; 

class ComplaintsService {
  final String baseUrl = 'http://192.168.151.145:8000/api';
  final Logger logger = Logger();


  Future<List<Map<String, dynamic>>> fetchComplaints() async {
    try {
      logger.i('Fetching pending complaints from Laravel...');

      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      // ✅ Step 1: Fetch complaints
      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/complaints'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch complaints');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey('data')) {
        throw Exception('Invalid API response format');
      }

      List<Map<String, dynamic>> complaints = List<Map<String, dynamic>>.from(data['data']);

      // ✅ Step 2: Extract unique officer IDs
      final Set<int> officerIds = {};
      for (var complaint in complaints) {
        if (complaint.containsKey('officer_id')) {
          officerIds.add(complaint['officer_id']);
        }
      }

      if (officerIds.isEmpty) {
        return complaints; // No officer IDs to fetch
      }

      // ✅ Step 3: Fetch officer names
      final officerResponse = await http.post(
        Uri.parse('$baseUrl/user-names'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'user_ids': officerIds.toList()}),
      );

      if (officerResponse.statusCode != 200) {
        throw Exception('Failed to fetch officer names');
      }

      final List<dynamic> officerData = jsonDecode(officerResponse.body);
      final Map<int, String> officerNames = {
        for (var officer in officerData) officer['id']: officer['name']
      };

      // ✅ Step 4: Attach officer names to complaints
      for (var complaint in complaints) {
        complaint['officer_name'] = officerNames[complaint['officer_id']] ?? 'Tidak Diketahui';
      }

      logger.i('Final Complaints with Officer Names: $complaints');

      return complaints;
    } catch (e) {
      logger.e('Error fetching complaints: $e');
      throw Exception('Error fetching complaints: $e');
    }
  }

  Future<Map<String, dynamic>> fetchComplaintDetails(String complaintId) async {
    try {
      final url = Uri.parse('$baseUrl/supervisor/assign-task/$complaintId');

      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch complaint details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching complaint details: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAssignedTasksHistory({
    required String bearerToken, // ✅ Add this parameter
    String? statusFilter,
    String? monthFilter,
  }) async {
    try {
      logger.i('Fetching tasks, statusFilter: $statusFilter, monthFilter: $monthFilter');

      final url = Uri.parse('$baseUrl/supervisor/history'); // Ensure this matches the backend route

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $bearerToken', // ✅ Include Bearer token for authentication
        },
      );

      logger.i('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Failed to fetch task history. Status: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching task history: $e');
      throw Exception('Error fetching task history: $e');
    }
  }
  
  Future<Map<String, dynamic>> fetchHistoryDetails(String complaintId, String bearerToken) async {
    try {
      final url = Uri.parse('$baseUrl/supervisor/history/$complaintId');
      logger.i('Fetching details for complaintId: $complaintId with URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      logger.i('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch history details. Status: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching history details: $e');
      throw Exception('Error fetching history details: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchLatestComplaint() async {
    try {
      logger.i('Fetching the latest complaint...');

      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      // ✅ Step 1: Fetch the latest complaint
      final response = await http.get(
        Uri.parse('$baseUrl/complaints/latest'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        logger.i('Latest Complaint Fetched: $data');

        final complaint = data['data'];

        if (complaint == null) return null;

        // ✅ Step 2: Check if officer_id is available
        if (!complaint.containsKey('officer_id') || complaint['officer_id'] == null) {
          logger.w('No officer ID found for latest complaint.');
          return complaint; // Return as-is
        }

        final int officerId = complaint['officer_id'];

        // ✅ Step 3: Fetch the officer name
        final officerResponse = await http.post(
          Uri.parse('$baseUrl/user-names'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $bearerToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'user_ids': [officerId]}),
        );

        if (officerResponse.statusCode == 200) {
          final List<dynamic> officerData = jsonDecode(officerResponse.body);
          if (officerData.isNotEmpty) {
            complaint['officer_name'] = officerData.first['name'];
          } else {
            complaint['officer_name'] = 'Tidak Diketahui';
          }
        } else {
          logger.e('Failed to fetch officer name.');
          complaint['officer_name'] = 'Tidak Diketahui';
        }

        logger.i('Latest Complaint with Officer Name: $complaint');
        return complaint;
      } else {
        throw Exception('Failed to fetch latest complaint. Status: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error fetching latest complaint: $e');
      return null;
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
      logger.i('Error in assignTask: $e');
      throw Exception('Error assigning task: $e');
    }
  }
}

