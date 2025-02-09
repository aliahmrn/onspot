import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart'; 

class ComplaintsService {
  final String baseUrl = 'http://192.168.248.145:8000/api';
  final Logger logger = Logger();


  Future<List<Map<String, dynamic>>> fetchComplaints() async {
    try {
      logger.i('Fetching pending complaints from Laravel...');

      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/supervisor/complaints'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $bearerToken', // ✅ Add token
        },
      );

      logger.i('Raw Response: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (!data.containsKey('data')) {
          logger.e('API response missing "data" key: $data');
          throw Exception('Invalid API response format');
        }

        final List<Map<String, dynamic>> complaints = List<Map<String, dynamic>>.from(data['data']);
        logger.i('Parsed Complaints: $complaints');

        return complaints;
      } else if (response.statusCode == 401) {
        logger.e('Unauthorized: Bearer token might be missing or invalid.');
        throw Exception('Unauthorized: Please log in again.');
      } else {
        logger.e('Failed to fetch complaints. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to fetch complaints');
      }
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

      final response = await http.get(
        Uri.parse('$baseUrl/complaints/latest'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $bearerToken', // ✅ Add Bearer Token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        logger.i('Latest Complaint Fetched: $data');

        return data['data']; // Extract complaint details
      } else if (response.statusCode == 401) {
        logger.e('Unauthorized: Bearer token might be missing or invalid.');
        throw Exception('Unauthorized: Please log in again.');
      } else if (response.statusCode == 404) {
        logger.w('No pending complaints found.');
        return null;
      } else {
        logger.e('Failed to fetch latest complaint. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
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

