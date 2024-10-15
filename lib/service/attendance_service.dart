import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  final String baseUrl = 'http://127.0.0.1:8000/api';
  final String token;

  AttendanceService(this.token);

  // Function to submit attendance
  Future<void> submitAttendance({
    required String status, // 'present' or 'absent'
    required int cleanerId
  }) async {
    final url = Uri.parse('$baseUrl/attendance');

    try {
      // Retrieve cleanerId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? cleanerIdString = prefs.getString('cleanerID'); // cleanerID from login
      // Log the retrieved cleaner ID
       print('Retrieved Cleaner ID: $cleanerIdString');

      if (cleanerIdString == null) {
        print('Cleaner ID is missing');
        throw Exception('Cleaner ID is missing from SharedPreferences');
      }

      final int cleanerId = int.parse(cleanerIdString); // Convert to int

      // Attendance data
      Map<String, dynamic> attendanceData = {
        'cleaner_id': cleanerId, // Use cleanerId directly as int for the backend
        'status': status,
      };

      // Making POST request to the API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // Pass the token from login
        },
        body: json.encode(attendanceData),
      );

      // Check the response status
      if (response.statusCode == 201) {
        // Success handling
        print('Attendance submitted successfully: ${response.body}');
      } else {
        // Log the error response body for more insight
        print('Error submitting attendance: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to submit attendance: ${response.body}');
      }
    } catch (e) {
      // Exception handling
      print('Exception: $e');
      throw Exception('Exception while submitting attendance: $e');
    }
  }
}
