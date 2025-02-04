import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ComplaintsService {
  final String baseUrl =
      'http://10.0.2.2:8000/api'; // Replace with your base URL

  // Fetch all complaints history for the officer
  Future<List<Map<String, dynamic>>> fetchOfficerComplaints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      final url = Uri.parse('$baseUrl/complaints-history');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to fetch complaints: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching complaints: $e');
    }
  }

  // Fetch details of a specific complaint
  Future<Map<String, dynamic>> fetchComplaintDetails(String complaintId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      final url = Uri.parse('$baseUrl/complaints/$complaintId/details');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to fetch complaint details: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching complaint details: $e');
    }
  }

  // Fetch officer complaints history with optional filters
  Future<List<Map<String, dynamic>>> fetchOfficerComplaintsHistory({
    required int officerId,
    String? statusFilter,
    String? monthFilter,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      final queryParams = {
        if (statusFilter != null) 'status': statusFilter,
        if (monthFilter != null) 'month': monthFilter,
      };

      final url = Uri.parse('$baseUrl/complaints-history')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to fetch history: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  // Fetch the latest complaint for the officer
  Future<Map<String, dynamic>?> fetchLatestComplaint() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearerToken = prefs.getString('token');

      if (bearerToken == null) {
        throw Exception('Bearer token is missing. Please log in again.');
      }

      final url = Uri.parse('$baseUrl/complaints-recent');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data != null ? Map<String, dynamic>.from(data) : null;
      } else {
        throw Exception(
            'Failed to fetch latest complaint: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching latest complaint: $e');
    }
  }
}
