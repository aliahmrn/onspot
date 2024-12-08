import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

class AttendanceService {
  final String baseUrl;
  final String token; // Token for authorization
  final Logger logger = Logger();


  AttendanceService(this.baseUrl, this.token);

  // Submit Attendance
  Future<void> submitAttendance({
    required String status,
    required int cleanerId,
  }) async {
    final url = Uri.parse('$baseUrl/attendance');

    try {
      final Map<String, dynamic> attendanceData = {
        'id': cleanerId,
        'status': status,
      };

      logger.i('Submitting attendance with payload: $attendanceData');
      logger.i('Authorization Token: $token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(attendanceData),
      );

      if (response.statusCode == 201) {
        logger.i('Attendance submitted successfully: ${response.body}');
      } else {
        throw Exception('Failed to submit attendance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error while submitting attendance: $e');
    }
  }

  // Check Today's Attendance
  Future<Map<String, dynamic>> checkTodayAttendance(int cleanerId) async {
    final url = Uri.parse('$baseUrl/attendance/check');
    try {
      final requestPayload = {'id': cleanerId};
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestPayload),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'attended': data['attended'] ?? false,
          'status': data['status'] ?? 'Unavailable', // Include status in the response
        };
      } else {
        throw Exception('Failed to check attendance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error during attendance check: $e');
    }
  }

}
