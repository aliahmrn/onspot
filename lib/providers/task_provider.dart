import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../service/task_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return TaskNotifier(TaskService());
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final TaskService _taskService;
  final Logger _logger = Logger();
 final Set<int> clickedTasks = {};

  TaskNotifier(this._taskService) : super(const AsyncValue.loading()) {
    fetchTasks(); // Fetch tasks on initialization
  }

  Future<void> fetchTasks() async {
    try {
      state = const AsyncValue.loading();

      final prefs = await SharedPreferences.getInstance();
      final cleanerId = prefs.getString('cleanerId');

      if (cleanerId == null) {
        _logger.e('Cleaner ID is missing in shared preferences.');
        state = AsyncValue.error('Cleaner ID not found.', StackTrace.empty);
        return;
      }

      _logger.i('Fetching tasks for Cleaner ID: $cleanerId');

      final tasks = await _taskService.getCleanerTasks(int.parse(cleanerId));

      if (tasks != null && tasks.isNotEmpty) {
        // Filter for ongoing tasks only
        final ongoingTasks = tasks.where((task) => task['comp_status']?.toLowerCase() == 'ongoing').toList();

        // Sort ongoing tasks by date
        ongoingTasks.sort((a, b) {
          final dateA = DateTime.tryParse(a['comp_date'] ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b['comp_date'] ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });

        state = AsyncValue.data(ongoingTasks);
      } else {
        _logger.i('No tasks found for Cleaner ID: $cleanerId');
        state = const AsyncValue.data([]);
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching tasks: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refreshTasks() async {
    await fetchTasks();
  }

  void markTaskAsClicked(int taskId) {
    clickedTasks.add(taskId);

    final currentTasks = state.value ?? [];
    final clickedTaskIndex = currentTasks.indexWhere((task) => task['complaint_id'] == taskId);

    if (clickedTaskIndex != -1) {
      final clickedTask = currentTasks[clickedTaskIndex];

      // Remove the clicked task from the list and reinsert it at the beginning
      final reorderedTasks = [
        clickedTask,
        ...currentTasks.where((task) => task['complaint_id'] != taskId),
      ];

      state = AsyncValue.data(reorderedTasks); // Refresh state to trigger UI updates
    }
  }


  bool isTaskClicked(int taskId) {
    return clickedTasks.contains(taskId);
  }
  
}