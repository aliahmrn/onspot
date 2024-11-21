import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart';

// Fetch complaint details
final complaintDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, complaintId) async {
  return ComplaintsService().getComplaintDetails(complaintId);
});

// Provider to track the selected number of cleaners
final selectedNumOfCleanersProvider = StateProvider<String?>((ref) => null);

// Provider to track the list of selected cleaners
final selectedCleanersProvider = StateProvider<List<String?>>((ref) => []);


// Task assignment logic
class AssignTaskNotifier extends StateNotifier<AsyncValue<void>> {
  AssignTaskNotifier() : super(const AsyncValue.data(null));

  Future<void> assignTask(String complaintId, Map<String, dynamic> body) async {
    state = const AsyncValue.loading(); // Set loading state
    try {
      await ComplaintsService().assignTask(complaintId, body);
      state = const AsyncValue.data(null); // Success
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Pass error and stack trace
    }
  }
}

final assignTaskProvider = StateNotifierProvider<AssignTaskNotifier, AsyncValue<void>>((ref) {
  return AssignTaskNotifier();
});
