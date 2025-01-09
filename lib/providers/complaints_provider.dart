import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart';

final complaintsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ComplaintsService().fetchComplaints();
});

// Update historyProvider to properly use the category
final historyProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, category) async {
  try {
    final ComplaintsService complaintsService = ComplaintsService();
    return await complaintsService.fetchComplaints();
  } catch (e) {
    print('Error in historyProvider: $e');
    throw Exception('Failed to load history');
  }
});

// Provider for fetching details of a specific task
final taskDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, complaintId) async {
  return ComplaintsService().fetchAssignedTaskDetails(complaintId);
});

final latestComplaintProvider = Provider<Map<String, dynamic>?>((ref) {
  final complaints = ref.watch(complaintsProvider).maybeWhen(
    data: (data) => data,
    orElse: () => [],
  );

  if (complaints.isEmpty) {
    print("g");
    return null;
  }

  return complaints.first;
});