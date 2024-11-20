import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

// Logger instance
final logger = Logger();

// Selected status provider
final selectedStatusProvider = StateProvider<String>((ref) => 'all');

// Cleaners provider
final cleanersProvider = StateNotifierProvider<CleanersNotifier, List<Map<String, String>>>(
  (ref) => CleanersNotifier(ref),
);

class CleanersNotifier extends StateNotifier<List<Map<String, String>>> {
  final Ref ref;
  CleanersNotifier(this.ref) : super([]);

  Future<void> fetchCleaners({String? status}) async {
    const url = 'http://192.168.1.105:8000/api/supervisor/cleaners';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(Uri.parse('$url?status=$status'), headers: headers);
      logger.i('Response status: ${response.statusCode}');
      logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> cleaners = data['data'];
        state = cleaners.map((cleaner) {
          return {
            'name': cleaner['cleaner_name'] as String? ?? 'Unknown',
            'status': cleaner['status'] as String? ?? 'Unavailable',
            'profile_pic': cleaner['profile_pic'] as String? ?? '',
            'phone_no': cleaner['cleaner_phoneNo'] as String? ?? '',
            'building': cleaner['building'] as String? ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load cleaners');
      }
    } catch (e) {
      logger.e('Error fetching cleaners: $e');
      state = [];
    }
  }
}

// Filtered cleaners provider
final filteredCleanersProvider = Provider<List<Map<String, String>>>((ref) {
  final cleaners = ref.watch(cleanersProvider);
  final selectedStatus = ref.watch(selectedStatusProvider);

  if (selectedStatus == 'all') {
    return cleaners;
  }
  return cleaners.where((cleaner) => cleaner['status'] == selectedStatus).toList();
});
