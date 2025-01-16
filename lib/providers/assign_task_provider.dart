import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/complaints_service.dart';

// Fetch complaint details
final complaintDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, complaintId) async {
  final complaintsService = ComplaintsService();

  // Add timeout logic here
  final data = await complaintsService.fetchComplaintDetails(complaintId).timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      throw Exception('Request timeout while fetching complaint details.');
    },
  );
    return data;
  });


// Provider to track the selected number of cleaners
final selectedNumOfCleanersProvider = StateProvider<String?>((ref) => null);

// Provider to track the list of selected cleaners
final selectedCleanersProvider = StateProvider<List<String?>>((ref) => []);

// Task assignment logic
class AssignTaskNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ComplaintsService _service;

  AssignTaskNotifier(this._service) : super(const AsyncValue.data({}));

Future<void> assignTask({
  required String complaintId,
  required List<int> cleanerIds,
  required int noOfCleaners,
  required int assignedBy,
}) async {
  state = const AsyncValue.loading(); // Set loading state
  try {
    final response = await _service.assignTask(
      complaintId: complaintId,
      cleanerIds: cleanerIds,
      noOfCleaners: noOfCleaners,
      assignedBy: assignedBy,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw Exception('Request timeout while assigning the task.');
      },
    );
    state = AsyncValue.data(response); // Success
    print('AssignTaskNotifier: Task assignment successful');
  } catch (e, stackTrace) {
    print('AssignTaskNotifier: Error occurred - $e');
    state = AsyncValue.error(e, stackTrace); // Error
  }
}
}

final assignTaskProvider = StateNotifierProvider<AssignTaskNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final service = ComplaintsService();
  return AssignTaskNotifier(service);
});