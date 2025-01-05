import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class CleanersState {
  final bool isLoading;
  final String? errorMessage;
  final List<Map<String, String>> cleaners;

  CleanersState({
    this.isLoading = false,
    this.errorMessage,
    this.cleaners = const [],
  });
}
// Logger instance
final logger = Logger();

// Selected status provider
final selectedStatusProvider = StateProvider<String>((ref) => 'all');

// Cleaners provider
final cleanersProvider = StateNotifierProvider<CleanersNotifier, CleanersState>(
  (ref) => CleanersNotifier(ref),
);


class CleanersNotifier extends StateNotifier<CleanersState> {
  final Ref ref;

  CleanersNotifier(this.ref) : super(CleanersState());

  List<Map<String, String>> _allCleaners = []; // Store all cleaners for filtering

  Future<void> fetchCleaners({String? status = 'all'}) async {
    state = CleanersState(isLoading: true); // Set loading state

    const url = 'http://192.168.1.105:8000/api/supervisor/cleaners';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token is null. Please log in again.');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(Uri.parse('$url?status=$status'), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (!data['success']) {
          throw Exception('API returned an error: ${data['message']}');
        }

        final List<dynamic> cleaners = data['data'];
        _allCleaners = cleaners.map((cleaner) {
          return {
            'id': cleaner['user_id']?.toString() ?? '',
            'name': cleaner['cleaner_name']?.toString() ?? 'Unknown',
            'status': cleaner['status']?.toString() ?? 'Unavailable',
            'profile_pic': cleaner['profile_pic']?.toString() ?? '',
            'phone_no': cleaner['cleaner_phoneNo']?.toString() ?? 'N/A',
            'building': cleaner['building']?.toString() ?? 'N/A',
          };
        }).toList();

        state = CleanersState(cleaners: _allCleaners); // Update the state with the fetched cleaners
      } else {
        throw Exception('Failed to load cleaners: ${response.body}');
      }
    } catch (e) {
      state = CleanersState(errorMessage: e.toString()); // Set error state
    }
  }

  void searchCleaners(String query, {String? status = 'all'}) {
    if (query.isEmpty) {
      state = CleanersState(
        cleaners: status == 'all'
            ? _allCleaners
            : _allCleaners.where((cleaner) => cleaner['status'] == status).toList(),
      );
    } else {
      state = CleanersState(
        cleaners: _allCleaners
            .where((cleaner) =>
                cleaner['name']!.toLowerCase().contains(query.toLowerCase()) &&
                (status == 'all' || cleaner['status'] == status))
            .toList(),
      );
    }
  }
}

final cleanerDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, cleanerId) async {
  final url = 'http://192.168.1.105:8000/api/supervisor/cleaner/$cleanerId';

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

    logger.i('Fetching cleaner details for ID: $cleanerId');
    final response = await http.get(Uri.parse(url), headers: headers);

    logger.i('Response status: ${response.statusCode}');
    logger.i('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Ensure 'data' key exists
      if (data['data'] == null) {
        throw Exception('Data not found in API response.');
      }

      final cleanerDetails = data['data'];

      // Parse latest_complaints and include assigned_by (supervisor name)
      final List<dynamic> latestComplaints =
          cleanerDetails['latest_complaints'] ?? [];

      // Map the complaints to include supervisor details
      final complaintsWithSupervisor = latestComplaints.map((complaint) {
        return {
          'complaint_id': complaint['complaint_id']?.toString(),
          'comp_date': complaint['comp_date'],
          'comp_time': complaint['comp_time'],
          'comp_desc': complaint['comp_desc'],
          'comp_location': complaint['comp_location'],
          'comp_image': complaint['comp_image'],
          'comp_status': complaint['comp_status'],
          'assigned_date': complaint['assigned_date'],
          'assigned_by': complaint['assigned_by'] ?? 'Unknown', // Supervisor name
        };
      }).toList();

      // Format data for UI
      return {
        'user_id': cleanerDetails['user_id'],
        'cleaner_name': cleanerDetails['cleaner_name'],
        'cleaner_phoneNo': cleanerDetails['cleaner_phoneNo'],
        'profile_pic': cleanerDetails['profile_pic'],
        'cleaner_username': cleanerDetails['cleaner_username'],
        'status': cleanerDetails['status'],
        'created_at': cleanerDetails['created_at'],
        'updated_at': cleanerDetails['updated_at'],
        'building': cleanerDetails['building'],
        'latest_complaints': complaintsWithSupervisor,
      };
    } else {
      throw Exception('Failed to load cleaner details: ${response.body}');
    }
  } catch (e) {
    logger.e('Error fetching cleaner details: $e');
    throw Exception('Error fetching cleaner details: $e');
  }
});

