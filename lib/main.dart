import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login.dart';
import 'officer/main_navigator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'service/notification_service.dart';
import 'service/notification_service_supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdoZmNwZGRweXdtYXRoa2hta2ZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQzMTk5NTcsImV4cCI6MjA0OTg5NTk1N30.pD09VuhLHIjww0hIbCbltJL9IvFyxZZp0ipfcswUIy0',
  );

  // Initialize the Notification Service (for push notifications)
  await NotificationService().initialize(); // Initialize Notification Service

  // Subscribe to supervisor notifications topic
  FirebaseMessaging.instance.subscribeToTopic('supervisors');

  // Wrap the app with ProviderScope and run it
  runApp(
    const ProviderScope(
      child: OnspotOfficerApp(),
    ),
  );
}

class OnspotOfficerApp extends StatelessWidget {
  const OnspotOfficerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Set initial route
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main-navigator': (context) =>
            const MainNavigator(), // Register the MainNavigator route
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Background color
        primaryColor: const Color(0xFF2E5675), // Primary color
        colorScheme: const ColorScheme(
          primary: Color(0xFF2E5675), // Card and button color
          secondary: Colors.white, // AppBar and NavBar background
          tertiary:
              Color.fromARGB(255, 183, 211, 233), // Additional accent color
          surface: Color(0xFFE0E0E0), // Surface color for cards, dialogs, etc.
          error: Color(0xFFB00020), // Color for error messages and indicators
          onPrimary: Colors.white, // Text/icon color on top of primary color
          onSecondary:
              Colors.black, // Text/icon color on top of secondary color
          onTertiary:
              Color(0xFF000000), // Text/icon color on top of tertiary color
          onSurface:
              Color(0xFF000000), // Text/icon color on top of the surface color
          onError:
              Color(0xFFFFFFFF), // Text/icon color on top of the error color
          outline: Color(0xFF737373), // Outline or border color
          shadow: Color(0x29000000), // Shadow color for elevation effects
          brightness: Brightness.light, // Light mode
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
    );
  }
}
