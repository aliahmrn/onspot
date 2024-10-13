import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceService {
  final String baseUrl;

  AttendanceService(this.baseUrl);

  Future<void> markAttendance(String status, String cleanerId) async {
    try {
      print('Sending request with status: $status and cleanerId: $cleanerId');
      
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/attendance'), 
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': status,
          'id': cleanerId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to mark attendance: ${response.body}');
      }
    } catch (e) {
      print('Error occurred: $e');
      throw Exception('Failed to mark attendance due to network error: $e');
    }
  }
}
