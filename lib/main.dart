import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'cleaner/main_navigator.dart'; // Import the main navigator
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'service/attendance_service.dart'; // Import your attendance service
import 'utils/shared_preferences_manager.dart'; // Import SharedPreferencesManager
import 'package:logger/logger.dart';
import 'service/notification_service_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// Define the AttendanceService provider
final attendanceServiceProvider = FutureProvider<AttendanceService?>((ref) async {
  final baseUrl = 'http://192.168.124.145:8000/api';
  final authToken = ref.watch(authTokenProvider); // Access the token directly
  final logger = Logger();

  if (authToken.isNotEmpty) {
   logger.i('Creating AttendanceService with token: $authToken'); // Debug log
    return AttendanceService(baseUrl, authToken);
  } else {
    logger.i('Token is empty. Returning null for AttendanceService'); // Debug log
    return null;
  }
});


final authTokenProvider = StateProvider<String>((ref) {
  return SharedPreferencesManager.prefs.getString('token') ?? ''; // Default to an empty string
});


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request permission for notifications
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // Initialization for Android
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // Initialization settings for both platforms
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

   await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      debugPrint('Notification clicked with payload: ${response.payload}');
    },
  );

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://ghfcpddpywmathkhmkff.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdoZmNwZGRweXdtYXRoa2hta2ZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzMTk5NTcsImV4cCI6MjA0OTg5NTk1N30.pD09VuhLHIjww0hIbCbltJL9IvFyxZZp0ipfcswUIy0',
  );

  // Initialize the Notification Service (for push notifications)
  await NotificationService().initialize(); // Initialize Notification Service

  // Subscribe to cleaner notifications topic
  FirebaseMessaging.instance.subscribeToTopic('cleaners');

  // Initialize SharedPreferences
  await SharedPreferencesManager.init();

    // Firebase Messaging Setup
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final loggedInCleanerId = prefs.getString('cleanerId');
    final payloadCleanerId = message.data['cleaner_id'];

    if (payloadCleanerId == loggedInCleanerId) {
      // Show notification if it matches the current cleaner
      final notification = message.notification;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'task_channel',
              'Cleaner Tasks',
              channelDescription: 'Notifications for tasks assigned to cleaners',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      }
    }
  });

  // Clear the previous token
  SharedPreferencesManager.prefs.remove('token');

  // Wrap the app with ProviderScope and run it
  runApp(
    const ProviderScope(
      child: OnspotCleanerApp(),
    ),
  );
}

class OnspotCleanerApp extends StatelessWidget {
  const OnspotCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final token = SharedPreferencesManager.prefs.getString('token') ?? '';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: token.isNotEmpty ? '/cleaner-home' : '/', // Redirect to login if token is cleared
      routes: {
        '/': (context) => const LoginScreen(),
        '/cleaner-home': (context) => const MainNavigator(), // Protected main navigation
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Background color
        primaryColor: const Color(0xFF2E5675), // Primary color (AppBar, Buttons, etc.)
        colorScheme: const ColorScheme(
          primary: Color(0xFF2E5675), // Card and button backgrounds
          secondary: Colors.white, // AppBar, Navbar background
          tertiary: Color.fromARGB(255, 183, 211, 233), // Accent color for less prominent elements
          surface: Color(0xFFE0E0E0), // Surface color for cards, dialogs, etc.
          error: Color(0xFFB00020), // Color for error messages and indicators
          onPrimary: Colors.white, // Text/icon color on top of primary color (e.g., AppBar text)
          onSecondary: Colors.black, // Text/icon color on top of secondary color (AppBar buttons)
          onTertiary: Color(0xFF000000), // Text/icon color on top of tertiary color
          onSurface: Color(0xFF000000), // Text/icon color on top of surface color
          onError: Color(0xFFFFFFFF), // Text/icon color on top of error color
          outline: Color(0xFF737373), // Color for outlines or borders (e.g., input fields)
          shadow: Color(0x29000000), // Shadow color for elevation effects
          brightness: Brightness.light, // Light mode theme
        ),
        textTheme: GoogleFonts.robotoTextTheme(), // Apply Roboto font
      ),
    );
  }
}
