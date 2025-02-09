import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart'; // Ensure this is correct
import 'package:shared_preferences/shared_preferences.dart';

// Fetch complaints where assigned_by is null and status is pending (from Laravel)
final complaintsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ComplaintsService().fetchComplaints(); // Use Laravel API
});

// Fetch the latest pending complaint (from Laravel)
final latestComplaintProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final ComplaintsService complaintService = ComplaintsService();
  return await complaintService.fetchLatestComplaint();
});

// Fetch assigned task history for supervisors
final historyProvider = FutureProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, filters) async {
  final prefs = await SharedPreferences.getInstance();
  final bearerToken = prefs.getString('token');

  if (bearerToken == null) {
    throw Exception('Bearer token is missing. Please log in again.');
  }

  final ComplaintsService historyService = ComplaintsService();
  return await historyService.fetchAssignedTasksHistory(
    bearerToken: bearerToken,
    statusFilter: filters['category'],
    monthFilter: filters['month'],
  );
});

// Fetch details of a specific complaint
final taskDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, complaintId) async {
  final prefs = await SharedPreferences.getInstance();
  final bearerToken = prefs.getString('token');

  if (bearerToken == null) {
    throw Exception('Bearer token is missing. Please log in again.');
  }

  final ComplaintsService complaintService = ComplaintsService();
  return complaintService.fetchHistoryDetails(complaintId, bearerToken); // ✅ Pass bearerToken
});

