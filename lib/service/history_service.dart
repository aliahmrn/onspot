import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Fetch the most recent complaint
Future<Map<String, dynamic>?> fetchMostRecentComplaint() async {
  try {
    final allComplaints = await fetchComplaintHistory(); // Fetch all complaints
    if (allComplaints.isEmpty) {
      return null; // No complaints
    }
    return allComplaints.first; // Assuming the latest complaint is first
  } catch (e) {
    throw Exception('Failed to fetch recent complaint: $e');
  }
}

/// Fetch the entire complaint history
Future<List<Map<String, dynamic>>> fetchComplaintHistory() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token'); // Retrieve token

  if (token == null) {
    throw Exception('User not authenticated');
  }

  final response = await http.get(
    Uri.parse('http://10.0.2.2:8000/api/complaints-history'),
    headers: {
      'Authorization': 'Bearer $token', // Authorization header
    },
  );

  if (response.statusCode == 200) {
    // Parse and return the complaints list
    return List<Map<String, dynamic>>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to load complaints');
  }
}

/// History State
class HistoryState {
  final List<dynamic> historyData;
  final bool hasFetchedData;

  HistoryState({
    required this.historyData,
    required this.hasFetchedData,
  });

  HistoryState copyWith({
    List<dynamic>? historyData,
    bool? hasFetchedData,
  }) {
    return HistoryState(
      historyData: historyData ?? this.historyData,
      hasFetchedData: hasFetchedData ?? this.hasFetchedData,
    );
  }
}

/// History Notifier
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState(historyData: [], hasFetchedData: false));

  /// Load the complaint history
  Future<void> loadComplaintHistory() async {
    try {
      List<dynamic> data = await fetchComplaintHistory();
      state = state.copyWith(historyData: data, hasFetchedData: true);
    } catch (e) {
      state = state.copyWith(hasFetchedData: true);
    }
  }
}
