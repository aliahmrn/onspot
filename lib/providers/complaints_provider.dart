import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ StateProvider for Tab Index
final tabIndexProvider = StateProvider<int>((ref) => 0);

// ✅ StateNotifier for Managing History Filters
class HistoryFilterNotifier extends StateNotifier<Map<String, dynamic>> {
  HistoryFilterNotifier()
      : super({
          'category': null,
          'month': null,
        });

  void updateCategory(String? category) {
    state = {
      ...state,
      'category': category,
    };
  }

  void updateMonth(String? month) {
    state = {
      ...state,
      'month': month,
    };
  }
}

// ✅ Provider for History Filters
final historyFilterProvider =
    StateNotifierProvider<HistoryFilterNotifier, Map<String, dynamic>>(
  (ref) => HistoryFilterNotifier(),
);

// ✅ Fetch All Complaints for Officer
final complaintsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final complaintsService = ComplaintsService();
  return complaintsService.fetchOfficerComplaints();
});

// ✅ Fetch Officer Complaints History with Filters
final historyProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final filters = ref.watch(historyFilterProvider);
  final prefs = await SharedPreferences.getInstance();
  final officerIdStr = prefs.getString('officerId');
  final officerId = officerIdStr != null ? int.tryParse(officerIdStr) : null;

  if (officerId == null) {
    throw Exception('Invalid or missing officerId.');
  }

  final complaintsService = ComplaintsService();
  return complaintsService.fetchOfficerComplaintsHistory(
    officerId: officerId,
    statusFilter: filters['category'],
    monthFilter: filters['month'],
  );
});

// ✅ Fetch Specific Complaint Details
final taskDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>(
    (ref, complaintId) async {
  final complaintsService = ComplaintsService();
  return complaintsService.fetchComplaintDetails(complaintId);
});

// ✅ Fetch Latest Complaint
final latestComplaintProvider =
    FutureProvider<Map<String, dynamic>?>((ref) async {
  final complaintsService = ComplaintsService();
  return complaintsService.fetchLatestComplaint();
});

// ✅ Complaint State for Managing the Latest Complaint
class ComplaintState {
  final Map<String, dynamic>? recentComplaint;
  final bool isLoading;
  final String? errorMessage;

  ComplaintState({
    this.recentComplaint,
    this.isLoading = false,
    this.errorMessage,
  });

  ComplaintState copyWith({
    Map<String, dynamic>? recentComplaint,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ComplaintState(
      recentComplaint: recentComplaint ?? this.recentComplaint,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ✅ Complaint Notifier for Managing Latest Complaint State
class ComplaintNotifier extends StateNotifier<ComplaintState> {
  final ComplaintsService _complaintsService;

  ComplaintNotifier(this._complaintsService) : super(ComplaintState());

  Future<void> fetchLatestComplaint() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final recentComplaint = await _complaintsService.fetchLatestComplaint();
      state = state.copyWith(
        recentComplaint: recentComplaint,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

// ✅ Provider for Managing Complaint States
final complaintNotifierProvider =
    StateNotifierProvider<ComplaintNotifier, ComplaintState>(
        (ref) => ComplaintNotifier(ComplaintsService()));
