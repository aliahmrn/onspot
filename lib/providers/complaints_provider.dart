import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final complaintsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ComplaintsService().fetchComplaints();
});


// Update historyProvider to properly use the category
final historyProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, filters) async {
  final prefs = await SharedPreferences.getInstance();
  final supervisorIdStr = prefs.getString('supervisorId');
  final supervisorId = supervisorIdStr != null ? int.tryParse(supervisorIdStr) : null;

  if (supervisorId == null) {
    throw Exception('Invalid or missing supervisorId.');
  }

  final ComplaintsService historyService = ComplaintsService();
  return await historyService.fetchAssignedTasksHistory(
    supervisorId: supervisorId,
    statusFilter: filters['category'],
    monthFilter: filters['month'],
  );
});

// Provider for fetching history details of a specific task
final taskDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, complaintId) async {
  final complaintsService = ComplaintsService();
  return complaintsService.fetchHistoryDetails(complaintId);
});

final latestComplaintProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final ComplaintsService complaintsService = ComplaintsService();
  return await complaintsService.fetchLatestComplaint();
});


