import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final Logger logger = Logger();

  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _setupRealtimeComplaintListener(); // Setup real-time listener
  }

  void _setupRealtimeComplaintListener() {
    final supabase = Supabase.instance.client;
    supabase
        .from('complaint')
        .stream(primaryKey: ['id'])
        .listen((List<Map<String, dynamic>> event) {
      for (var complaint in event) {
        _showNotification(complaint);
      }
    });
  }

  Future<void> _showNotification(Map<String, dynamic> complaint) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'complaint_channel',
      'Complaints',
      channelDescription: 'Channel for complaint notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      'New Complaint',
      'Complaint: ${complaint['comp_desc']}',
      notificationDetails,
    );
  }
}