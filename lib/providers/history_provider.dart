import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/task_service.dart';
import 'package:logger/logger.dart';

final historyProvider = StateNotifierProvider<HistoryTaskNotifier, AsyncValue<List<Map<String, dynamic>>>>((ref) {
  return HistoryTaskNotifier(TaskService());
});

class HistoryTaskNotifier extends StateNotifier<AsyncValue<List<Map<String, dynamic>>>> {
  final TaskService _taskService;
  final Logger logger = Logger();

  HistoryTaskNotifier(this._taskService) : super(const AsyncValue.loading());


  Future<void> fetchHistoryTasks(int cleanerId) async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _taskService.fetchHistoryTasks(cleanerId);

      // Sort the tasks by `assigned_date` in descending order (latest to oldest)
      tasks.sort((a, b) {
        final dateA = DateTime.parse(a['assigned_date']);
        final dateB = DateTime.parse(b['assigned_date']);
        return dateB.compareTo(dateA); // Descending order
      });

      state = AsyncValue.data(tasks);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshHistoryTasks(int cleanerId) async {
    await fetchHistoryTasks(cleanerId);
  }
}
