import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart';

final complaintsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ComplaintsService().fetchComplaints();
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
