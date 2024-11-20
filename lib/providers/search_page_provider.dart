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

  List<Map<String, String>> _allCleaners = []; // Store all cleaners for filtering

Future<void> fetchCleaners({String? status = 'all'}) async {
  const url = 'http://192.168.1.105:8000/api/supervisor/cleaners';

  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    logger.i('Token: $token');

    if (token == null) {
      throw Exception('Token is null. Please log in again.');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    logger.i('Fetching cleaners with status: $status'); // Log request
    final response = await http.get(Uri.parse('$url?status=$status'), headers: headers);
    logger.i('Response status: ${response.statusCode}');
    logger.i('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (!data['success']) {
        throw Exception('API returned an error: ${data['message']}');
      }

      final List<dynamic> cleaners = data['data'];
      logger.i('Number of cleaners fetched: ${cleaners.length}'); // Log cleaner count

      _allCleaners = cleaners.map((cleaner) {
        return {
          'name': cleaner['cleaner_name'] as String? ?? 'Unknown',
          'status': cleaner['status'] as String? ?? 'Unavailable',
          'profile_pic': cleaner['profile_pic'] as String? ?? '',
          'phone_no': cleaner['cleaner_phoneNo'] as String? ?? '',
          'building': cleaner['building'] as String? ?? '',
        };
      }).toList();

      state = _allCleaners; // Update the state with the fetched cleaners
      logger.i('State updated with cleaners: $state');
    } else {
      throw Exception('Failed to load cleaners: ${response.body}');
    }
  } catch (e) {
    logger.e('Error fetching cleaners: $e');
    _allCleaners = [];
    state = []; // Clear the state if an error occurs
  }
}


  void searchCleaners(String query, {String? status = 'all'}) {
    if (query.isEmpty) {
      // Apply only status filter if the query is empty
      state = status == 'all'
          ? _allCleaners
          : _allCleaners.where((cleaner) => cleaner['status'] == status).toList();
    } else {
      // Apply both query and status filters
      state = _allCleaners
          .where((cleaner) =>
              cleaner['name']!.toLowerCase().contains(query.toLowerCase()) &&
              (status == 'all' || cleaner['status'] == status))
          .toList();
    }
  }
}
