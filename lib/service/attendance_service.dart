import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceService {
  final String baseUrl;
  final String token; // Token for authorization

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

      print('Submitting attendance with payload: $attendanceData');
      print('Authorization Token: $token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(attendanceData),
      );

      if (response.statusCode == 201) {
        print('Attendance submitted successfully: ${response.body}');
      } else {
        throw Exception('Failed to submit attendance: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error while submitting attendance: $e');
    }
  }

  // Check Today's Attendance
  Future<bool> checkTodayAttendance(int cleanerId) async {
    final url = Uri.parse('$baseUrl/attendance/check');
    try {
      final requestPayload = {'id': cleanerId};
      print('Making attendance check request: $requestPayload');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestPayload),
      );
      print('Attendance check response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['attended'] ?? false;
      } else {
        throw Exception('Failed to check attendance: ${response.body}');
      }
    } catch (e) {
      print('Error during attendance check: $e');
      rethrow;
    }
  }

}
