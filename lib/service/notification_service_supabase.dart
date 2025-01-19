import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger logger = Logger();
  DateTime? _lastProcessedTimestamp; // Keeps track of the last processed task's timestamp

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: androidSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _setupRealtimeTaskListener(); // Setup real-time listener
  }

  void _setupRealtimeTaskListener() {
    final supabase = Supabase.instance.client;

    // Listen to changes in the complaint_cleaner table
    supabase
        .from('complaint_cleaner') // Table to listen to
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false) // Order by latest entries
        .listen((List<Map<String, dynamic>> event) async {
      for (var task in event) {
        final DateTime taskCreatedAt = DateTime.parse(task['created_at']);

        // Skip tasks that were already processed
        if (_lastProcessedTimestamp != null && taskCreatedAt.isBefore(_lastProcessedTimestamp!)) {
          logger.i('Task created at $taskCreatedAt already processed. Skipping.');
          continue;
        }

        final complaintId = task['complaint_id'];

        // Fetch the related complaint data
        final complaint = await _fetchComplaintDetails(complaintId);

        if (complaint != null) {
          _lastProcessedTimestamp = taskCreatedAt; // Update the last processed timestamp
          _showNotification(task, complaint['comp_desc']);
        }
      }
    });
  }

  Future<Map<String, dynamic>?> _fetchComplaintDetails(int complaintId) async {
    try {
      // Fetch complaint details from Supabase
      final response = await Supabase.instance.client
          .from('complaint')
          .select()
          .eq('id', complaintId)
          .single();

      return response as Map<String, dynamic>;
    } catch (e) {
      logger.e('Error fetching complaint details: $e');
      return null;
    }
  }

  Future<void> _showNotification(Map<String, dynamic> task, String compDesc) async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInCleanerId = prefs.getString('cleanerId');

    // Ensure the task's cleaner ID matches the logged-in cleaner ID
    if (task['cleaner_id'].toString() == loggedInCleanerId) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'task_channel',
        'Cleaner Tasks',
        channelDescription: 'Channel for cleaner task notifications',
        importance: Importance.max,
        priority: Priority.high,
      );
      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      await _flutterLocalNotificationsPlugin.show(
        task['complaint_id'].hashCode, // Unique notification ID
        'Tugas Baru',
        'Aduan: $compDesc',
        notificationDetails,
      );
    }
  }
}
