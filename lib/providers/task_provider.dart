import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../service/task_service.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return TaskNotifier(TaskService());
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final TaskService _taskService;
  final Logger _logger = Logger();

  TaskNotifier(this._taskService) : super(const AsyncValue.loading()) {
    fetchTasks(); // Fetch tasks on initialization
  }

  Future<void> fetchTasks() async {
    try {
      state = const AsyncValue.loading();
      // Replace `69` with dynamic cleaner ID as required
      final tasks = await _taskService.getCleanerTasks(69);

      if (tasks != null && tasks.isNotEmpty) {
        // Sort tasks by date in descending order
        tasks.sort((a, b) {
          final dateA = DateTime.tryParse(a['comp_date'] ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b['comp_date'] ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });
        state = AsyncValue.data(tasks);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching tasks: $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
