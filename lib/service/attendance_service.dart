import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceService {
  final String baseUrl = 'http://127.0.0.1:8000/api';  // Base URL of the API
  final String token;  // Token for authorization

  AttendanceService(this.token);

  // Function to submit attendance
  Future<void> submitAttendance({
    required String status,  // 'present' or 'absent'
  }) async {
    final url = Uri.parse('$baseUrl/attendance');  // API endpoint for submitting attendance

    try {
      // Retrieve cleanerId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final String? cleanerIdString = prefs.getString('cleanerId'); 
      print('Retrieved Cleaner ID: $cleanerIdString');

      if (cleanerIdString == null) {
        print('Cleaner ID is missing');
        throw Exception('Cleaner ID is missing from SharedPreferences');
      }

      final int cleanerId = int.parse(cleanerIdString); 

      // Attendance data
      Map<String, dynamic> attendanceData = {
        'id': cleanerId,  // Cleaner ID
        'status': status,  // Attendance status ('present' or 'absent')
      };

      // Making POST request to the API
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',  // Authorization header
        },
        body: json.encode(attendanceData),
      );

      // Check the response status
      if (response.statusCode == 201) {
        print('Attendance submitted successfully: ${response.body}');

        // Save today's date to SharedPreferences if submission is successful
        final today = DateTime.now();
        await prefs.setString('lastAttendanceDate', today.toIso8601String().substring(0, 10)); // Store date in 'yyyy-MM-dd' format
      } else {
        print('Error submitting attendance: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to submit attendance: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
      throw Exception('Exception while submitting attendance: $e');
    }
  }

  // Method to check if attendance is already submitted today
  Future<bool> isAttendanceSubmittedToday() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastAttendanceDate = prefs.getString('lastAttendanceDate');  // Get the last attendance submission date

    if (lastAttendanceDate == null) {
      return false;  // No attendance submitted yet
    }

    // Parse the last attendance date
    DateTime lastDate = DateTime.parse(lastAttendanceDate);

    // Get today's date
    final today = DateTime.now();
    
    // Check if the last attendance date is today (compare year, month, and day)
    return lastDate.year == today.year &&
           lastDate.month == today.month &&
           lastDate.day == today.day;
  }
}
