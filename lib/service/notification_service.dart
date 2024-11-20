import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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

  Future<void> initialize() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Retrieve FCM token
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
        // Assuming the device type and device ID are known (for simplicity)
        String deviceType = 'android'; // or 'ios' depending on the platform
        String deviceId = 'your_unique_device_id'; // Replace with an actual unique ID

        // Store the token using AuthService
        await AuthService().storeNotificationToken(deviceToken, deviceId, deviceType);
      }
    } catch (e) {
      print('Error retrieving FCM token: $e');
    }
  }

  void _setupForegroundNotificationListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  void _setupBackgroundNotificationListener() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle notification tapped when app is in background or terminated
      print('Notification opened from background: ${message.messageId}');
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
