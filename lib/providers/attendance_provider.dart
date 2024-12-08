import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onspot_cleaner/login.dart';
import '../service/attendance_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/shared_preferences_manager.dart';
import 'package:logger/logger.dart';

class AttendanceState {
  final bool showCard;
  final String? cleanerName;
  final String? status; 
  final Logger logger = Logger();

  AttendanceState({required this.showCard, this.cleanerName, this.status,});
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
      // Call the service to get the attendance and status
      final response = await attendanceService!.checkTodayAttendance(cleanerId);

      // Extract data from the response
      final hasSubmitted = response['attended'] ?? false; // Default to false if 'attended' is missing
      final status = response['status'] ?? 'Unavailable'; // Default to "Unavailable"
      
      // Get cleaner name from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final cleanerName = prefs.getString('name') ?? 'Cleaner';

      // Update state with the data
      state = AsyncValue.data(
        AttendanceState(
          showCard: !hasSubmitted, // Show card only if not submitted
          cleanerName: cleanerName,
          status: status,
        ),
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

      // Submit attendance using the service
      await attendanceService!.submitAttendance(
        status: status,
        cleanerId: int.parse(cleanerId),
      );

      // Update state after submission
      state = AsyncValue.data(
        AttendanceState(
          showCard: false, // Do not show the card after submission
          cleanerName: state.value?.cleanerName,
          status: status == 'present' ? 'Available' : 'Unavailable', // Update status
        ),
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
    logger.i('Creating AttendanceService with token: $token');
    return AttendanceService('http://192.168.1.105:8000/api', token);
  } else {
    logger.i('Token is empty. AttendanceService not created.');
    return null;
  }
});


// Provider for Auth Token
final authTokenProvider = StateProvider<String>((ref) {
  // Initialize with the token from SharedPreferences
  return SharedPreferencesManager.prefs.getString('token') ?? '';
});
