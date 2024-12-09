import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart';

final complaintsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ComplaintsService().fetchComplaints();
});

// Update historyProvider to properly use the category
final historyProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, category) async {
  final ComplaintsService complaintsService = ComplaintsService();
  return complaintsService.fetchAssignedTasksHistory(category);
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
    return null;
  }

  complaints.sort((a, b) {
    DateTime dateA = DateTime.parse(a['comp_date']);
    DateTime dateB = DateTime.parse(b['comp_date']);
    return dateB.compareTo(dateA);
  });

  return complaints.first;
});
