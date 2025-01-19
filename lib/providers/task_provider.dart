import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/task_service.dart';
import 'package:logger/logger.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return TaskNotifier(TaskService());
});

class TaskNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final TaskService _taskService;
  final Logger logger = Logger();

  TaskNotifier(this._taskService) : super(const AsyncValue.loading());
  TaskService get taskService => _taskService;
  
  Future<void> fetchTasks(int cleanerId) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _taskService.fetchTasks(cleanerId);
      state = AsyncValue.data(tasks);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshTasks(int cleanerId) async {
    await fetchTasks(cleanerId);
  }
}
