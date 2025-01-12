import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fetch complaint details
final complaintDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, complaintId) async {
  return ComplaintsService().fetchAssignedTaskDetails(complaintId);
});

// Provider to track the selected number of cleaners
final selectedNumOfCleanersProvider = StateProvider<String?>((ref) => null);

// Provider to track the list of selected cleaners
final selectedCleanersProvider = StateProvider<List<String?>>((ref) => []);

// Task assignment logic
class AssignTaskNotifier extends StateNotifier<AsyncValue<void>> {
  AssignTaskNotifier() : super(const AsyncValue.data(null));

  Future<void> assignTask(
    String complaintId,
    Map<String, dynamic> body,
    List<String> cleanerIds,
  ) async {
    state = const AsyncValue.loading(); // Set loading state
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignedBy = prefs.getString('supervisorId'); // Retrieve supervisor ID

      if (assignedBy == null) {
        throw Exception('Supervisor ID is missing. Please log in again.');
      }

      await ComplaintsService().assignTaskAndNotify(complaintId, body, cleanerIds, assignedBy);
      state = const AsyncValue.data(null); // Success
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Pass error and stack trace
    }
  }
}

final assignTaskProvider = StateNotifierProvider<AssignTaskNotifier, AsyncValue<void>>((ref) {
  return AssignTaskNotifier();
});