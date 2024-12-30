import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../service/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<Map<String, List<Map<String, dynamic>>>>>((ref) {
  return TaskNotifier(TaskService());
});

class TaskNotifier extends StateNotifier<AsyncValue<Map<String, List<Map<String, dynamic>>>>> {
  final TaskService _taskService;
  final Logger _logger = Logger();
  final Set<int> clickedTasks = {}; // Tracks clicked tasks locally

  TaskNotifier(this._taskService)
      : super(const AsyncValue.loading()) {
    fetchTasks(); // Initialize by fetching tasks
  }

  // Fetch tasks for both notified and not-notified categories
  Future<void> fetchTasks() async {
    try {
      state = const AsyncValue.loading(); // Set loading state

      final prefs = await SharedPreferences.getInstance();
      final cleanerId = prefs.getString('cleanerId');

      if (cleanerId == null) {
        _logger.e('Cleaner ID is missing in shared preferences.');
        state = AsyncValue.error('Cleaner ID not found.', StackTrace.empty);
        return;
      }

      _logger.i('Fetching tasks for Cleaner ID: $cleanerId');

      // Fetch tasks for both notified and not-notified categories
      final notifiedTasks = await _taskService.getCleanerTasks(
        int.parse(cleanerId),
        isNotified: true,
      );

      final notNotifiedTasks = await _taskService.getCleanerTasks(
        int.parse(cleanerId),
        isNotified: false,
      );

      // Update state with tasks split into categories
      state = AsyncValue.data({
        'notified': notifiedTasks ?? [],
        'notNotified': notNotifiedTasks ?? [],
      });
    } catch (e, stackTrace) {
      _logger.e('Error fetching tasks: $e', error: e, stackTrace: stackTrace);
      state = AsyncValue.error(e, stackTrace); // Handle error state
    }
  }

  // Refresh tasks
  Future<void> refreshTasks() async {
    await fetchTasks();
  }

  // Mark a task as clicked
  void markTaskAsClicked(int taskId) {
    clickedTasks.add(taskId);

    // Get current tasks
    final currentState = state.value ?? {'notified': [], 'notNotified': []};
    final notifiedTasks = currentState['notified'] ?? [];
    final notNotifiedTasks = currentState['notNotified'] ?? [];

    // Find and reorder the clicked task
    final clickedTaskIndex = notNotifiedTasks.indexWhere((task) => task['complaint_id'] == taskId);
    if (clickedTaskIndex != -1) {
      final clickedTask = notNotifiedTasks[clickedTaskIndex];

      // Reorder: move the clicked task to the top
      notNotifiedTasks.removeAt(clickedTaskIndex);
      notNotifiedTasks.insert(0, clickedTask);

      // Update the state
      state = AsyncValue.data({
        'notified': notifiedTasks,
        'notNotified': notNotifiedTasks,
      });

      _logger.i('Marked task ID: $taskId as clicked and moved to the top.');
    } else {
      _logger.w('Task ID: $taskId not found in not-notified tasks.');
    }
  }

  // Check if a task is clicked
  bool isTaskClicked(int taskId) {
    return clickedTasks.contains(taskId);
  }

  // Toggle the is_notified status of a task
  Future<void> toggleTaskNotification(int complaintId) async {
    try {
      final success = await _taskService.toggleNotification(complaintId);

      if (success) {
        final currentTasks = state.value ?? {'notified': [], 'notNotified': []};
        final notifiedTasks = currentTasks['notified'] ?? [];
        final notNotifiedTasks = currentTasks['notNotified'] ?? [];

        // Find and update the toggled task
        Map<String, dynamic>? toggledTask;
        bool movedToNotified = false;

        // Search in 'notNotified' first
        toggledTask = notNotifiedTasks.firstWhere(
          (task) => task['complaint_id'] == complaintId,
          orElse: () => {},
        );

        if (toggledTask.isNotEmpty) {
          toggledTask['is_notified'] = true;
          notNotifiedTasks.remove(toggledTask);
          notifiedTasks.add(toggledTask);
          movedToNotified = true;
        }

        // If not found, search in 'notified'
        if (!movedToNotified) {
          toggledTask = notifiedTasks.firstWhere(
            (task) => task['complaint_id'] == complaintId,
            orElse: () => {},
          );

          if (toggledTask.isNotEmpty) {
            toggledTask['is_notified'] = false;
            notifiedTasks.remove(toggledTask);
            notNotifiedTasks.add(toggledTask);
          }
        }

        // Update the state with modified lists
        state = AsyncValue.data({
          'notified': notifiedTasks,
          'notNotified': notNotifiedTasks,
        });

        _logger.i('Successfully toggled notification for task ID: $complaintId');
      } else {
        _logger.w('Failed to toggle notification for task ID: $complaintId');
      }
    } catch (e, stackTrace) {
      _logger.e('Error toggling task notification: $e', error: e, stackTrace: stackTrace);
    }
  }
}
