import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart'; // Import the logger package
import '../service/auth_service.dart'; // Import AuthService to save notification token

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final String apiBaseUrl = "http://192.168.1.105:8000/api"; // Replace with your backend URL
  final Logger _logger = Logger(); // Initialize a logger instance

  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Retrieve FCM token and store it
      await _retrieveAndStoreToken();

      // Setup notification listeners
      _setupForegroundNotificationListener();
      _setupBackgroundNotificationListener();
    }

    // Initialize local notifications for displaying messages while the app is in the foreground
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: androidSettings);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Retrieve FCM token and store it in the backend
  Future<void> _retrieveAndStoreToken() async {
    try {
      String? deviceToken = await _firebaseMessaging.getToken();
      if (deviceToken != null) {
        String deviceType = 'android'; // or 'ios' depending on the platform
        String deviceId = 'your_unique_device_id'; // Replace with an actual unique ID

        // Store the token using AuthService
        await AuthService().storeNotificationToken(deviceToken, deviceId, deviceType);
        _logger.i('FCM token stored successfully: $deviceToken');
      }
    } catch (e, stackTrace) {
      _logger.e('Error retrieving FCM token', e, stackTrace);
    }
  }

  // Fetch notifications from the backend
  Future<List<Map<String, dynamic>>> fetchNotifications(String authToken) async {
    _logger.d("Fetching notifications with auth token: $authToken"); // Debug log
    final url = Uri.parse("$apiBaseUrl/notifications");

    try {
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $authToken",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null && contentType.contains('application/json')) {
          final data = json.decode(response.body);
          if (data['success'] == true) {
            _logger.i('Notifications fetched successfully');
            return List<Map<String, dynamic>>.from(data['notifications']);
          } else {
            throw Exception("Failed to fetch notifications");
          }
        } else {
          throw Exception("Unexpected response format: ${response.body}");
        }
      } else {
        throw Exception("HTTP Request failed with status ${response.statusCode}: ${response.body}");
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching notifications', e, stackTrace);
      rethrow;
    }
  }

  void _setupForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _logger.d('Foreground notification received: ${message.messageId}');
      _showLocalNotification(message);
    });
  }

  void _setupBackgroundNotificationListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _logger.d('Notification opened from background: ${message.messageId}');
      // Add any navigation or action based on the message here
    });
  }

  void _showLocalNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'your_channel_id',
        'your_channel_name',
        channelDescription: 'your_channel_description',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
      );
    }
  }
}
