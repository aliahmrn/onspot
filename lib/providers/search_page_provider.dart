import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    const url = 'http://192.168.184.146:8000/api/supervisor/cleaners';

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
      logger.i('Fetching cleaners with status: $status');
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
    String apiStatus = status == 'sedia'
        ? 'available'
        : status == 'tidak sedia'
            ? 'unavailable'
            : 'all';

    state = CleanersState(
      cleaners: _allCleaners
          .where((cleaner) =>
              cleaner['name']!.toLowerCase().contains(query.toLowerCase()) &&
              (apiStatus == 'all' || cleaner['status'] == apiStatus))
          .toList(),
    );
  }
}

final cleanerDetailProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, String cleanerId) async {
  const supabaseUrl = 'https://ghfcpddpywmathkhmkff.supabase.co';
  const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdoZmNwZGRweXdtYXRoa2hta2ZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzMTk5NTcsImV4cCI6MjA0OTg5NTk1N30.pD09VuhLHIjww0hIbCbltJL9IvFyxZZp0ipfcswUIy0';
  final supabaseClient = SupabaseClient(supabaseUrl, supabaseKey);

  final mysqlUserNamesUrl = 'http://192.168.184.146:8000/api/user-names';
  final mysqlCleanerDetailsUrl = 'http://192.168.184.146:8000/api/supervisor/cleaner/$cleanerId';

  try {
    // Step 1: Fetch cleaner details from MySQL
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('Token is null. Please log in again.');

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final mysqlResponse = await http.get(Uri.parse(mysqlCleanerDetailsUrl), headers: headers);

    if (mysqlResponse.statusCode != 200) {
      throw Exception('Failed to load cleaner details: ${mysqlResponse.body}');
    }

    final Map<String, dynamic> cleanerDetails =
        jsonDecode(mysqlResponse.body)['data'] as Map<String, dynamic>;

    if (cleanerDetails.isEmpty || !cleanerDetails.containsKey('user_id')) {
      throw Exception('Cleaner details are invalid or incomplete.');
    }

    // Step 2: Fetch complaints from Supabase
    final supabaseResponse = await supabaseClient
        .from('complaint_cleaner')
        .select('''
          complaint_id,
          assigned_date,
          assigned_by,
          cleaner_id,
          complaint (
            id,
            comp_date,
            comp_time,
            comp_desc,
            comp_location,
            comp_image,
            comp_status
          )
        ''')
        .eq('cleaner_id', cleanerId) // Filter by cleaner ID
        .order('assigned_date', ascending: false) // Sort by assigned_date
        .limit(1) // Retrieve the latest complaint
        .maybeSingle(); // Fetch a single result or null

    // Handle case where no complaints exist
    if (supabaseResponse == null) {
      return {
        ...cleanerDetails,
        'latest_complaints': [], // Empty list for complaints
      };
    }

    // Extract `assigned_by` IDs
    final assignedById = supabaseResponse['assigned_by'] as int?;

    // Step 3: Fetch supervisor name(s) from MySQL
    String? supervisorName;
    if (assignedById != null) {
      final mysqlUserResponse = await http.post(
        Uri.parse(mysqlUserNamesUrl),
        headers: headers,
        body: jsonEncode({'user_ids': [assignedById]}), // Send `assigned_by` IDs
      );

      if (mysqlUserResponse.statusCode != 200) {
        throw Exception('Failed to fetch supervisor names: ${mysqlUserResponse.body}');
      }

      final List<dynamic> userNames = jsonDecode(mysqlUserResponse.body);
      if (userNames.isNotEmpty) {
        supervisorName = userNames.firstWhere(
          (user) => user['id'] == assignedById,
          orElse: () => {'name': 'Unknown'},
        )['name'] as String?;
      }
    }

    // Combine data into a single response
    return {
      ...cleanerDetails,
      'latest_complaints': [
        {
          'complaint_id': supabaseResponse['complaint']['id'],
          'comp_date': supabaseResponse['complaint']['comp_date'],
          'comp_time': supabaseResponse['complaint']['comp_time'],
          'comp_desc': supabaseResponse['complaint']['comp_desc'],
          'comp_location': supabaseResponse['complaint']['comp_location'],
          'comp_image': supabaseResponse['complaint']['comp_image'],
          'comp_status': supabaseResponse['complaint']['comp_status'],
          'assigned_date': supabaseResponse['assigned_date'],
          'assigned_by': supervisorName ?? 'Unknown', // Add supervisor name
        }
      ],
    };
  } catch (e) {
    logger.e('Error fetching combined cleaner details: $e');
    throw Exception('Error fetching combined cleaner details: $e');
  }
});

