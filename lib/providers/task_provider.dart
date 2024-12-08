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

  TaskNotifier(this._taskService) : super(const AsyncValue.loading()) {
    fetchTasks(); // Fetch tasks on initialization
  }

  Future<void> fetchTasks() async {
    try {
      state = const AsyncValue.loading();

      // Fetch the cleaner ID dynamically from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final cleanerId = prefs.getString('cleanerId'); // Ensure 'cleanerId' is stored during login

      if (cleanerId == null) {
        _logger.e('Cleaner ID is missing in shared preferences.');
        state = AsyncValue.error('Cleaner ID not found.', StackTrace.empty);
        return;
      }

      _logger.i('Fetching tasks for Cleaner ID: $cleanerId');

      final tasks = await _taskService.getCleanerTasks(int.parse(cleanerId));

      if (tasks != null && tasks.isNotEmpty) {
        // Sort tasks by date in descending order
        tasks.sort((a, b) {
          final dateA = DateTime.tryParse(a['comp_date'] ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b['comp_date'] ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });
        state = AsyncValue.data(tasks);
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
  
}