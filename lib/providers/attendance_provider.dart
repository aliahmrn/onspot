import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/attendance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/shared_preferences_manager.dart';

class AttendanceState {
  final bool showCard;
  final String? cleanerName;

  AttendanceState({required this.showCard, this.cleanerName});
}

class AttendanceNotifier extends StateNotifier<AsyncValue<AttendanceState>> {
  final AttendanceService? attendanceService;

  AttendanceNotifier(this.attendanceService)
      : super(const AsyncValue.loading()); // Start with loading state

  Future<void> checkAttendance(int cleanerId) async {
    if (attendanceService == null) {
      state = AsyncValue.error('AttendanceService is not available', StackTrace.current);
      return;
    }
    try {
      final hasSubmitted = await attendanceService!.checkTodayAttendance(cleanerId);
      final prefs = await SharedPreferences.getInstance();
      final cleanerName = prefs.getString('name') ?? 'Cleaner';

      state = AsyncValue.data(
        AttendanceState(showCard: !hasSubmitted, cleanerName: cleanerName),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> handleSubmitAttendance(String status) async {
    if (attendanceService == null) {
      state = AsyncValue.error('AttendanceService is not available', StackTrace.current);
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final cleanerId = prefs.getString('cleanerId');
      if (cleanerId == null) throw Exception('Cleaner ID is missing');

      await attendanceService!.submitAttendance(
        status: status,
        cleanerId: int.parse(cleanerId),
      );

      state = AsyncValue.data(
        AttendanceState(showCard: false, cleanerName: state.value?.cleanerName),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

// Provider for AttendanceNotifier with AsyncValue
final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AsyncValue<AttendanceState>>((ref) {
  final attendanceService = ref.watch(attendanceServiceProvider);
  return AttendanceNotifier(attendanceService);
});


// Provider for AttendanceService
final attendanceServiceProvider = Provider<AttendanceService?>((ref) {
  final token = ref.watch(authTokenProvider);

  if (token.isNotEmpty) {
    print('Creating AttendanceService with token: $token');
    return AttendanceService('http://192.168.1.105:8000/api', token);
  } else {
    print('Token is empty. AttendanceService not created.');
    return null;
  }
});


// Provider for Auth Token
final authTokenProvider = StateProvider<String>((ref) {
  // Initialize with the token from SharedPreferences
  return SharedPreferencesManager.prefs.getString('token') ?? '';
});
