import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'login.dart';
import 'supervisor/homescreen.dart';
import 'supervisor/main_navigator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // Add this import
import 'service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize the Notification Service (for push notifications)
  await NotificationService().initialize(); // Initialize Notification Service

  // Clear the token on app startup to ensure the login screen displays
  await _clearTokenOnStartup();

  // Subscribe to supervisor notifications topic
  FirebaseMessaging.instance.subscribeToTopic('supervisors'); // Add this line

  // Wrap the app with ProviderScope and run it
  runApp(
    ProviderScope( // Add ProviderScope here
      child: const OnspotSupervisorApp(),
    ),
  );
}

// Clear token on app startup to ensure login screen displays
Future<void> _clearTokenOnStartup() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}

class OnspotSupervisorApp extends StatelessWidget {
  const OnspotSupervisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/supervisor-home': (context) => const SupervisorHomeScreen(),
        '/main-navigator': (context) => const MainNavigator(), // Supervisor home screen
      },
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white, // Background color
        primaryColor: const Color(0xFF2E5675), // Primary color
        colorScheme: const ColorScheme(
          primary: Color(0xFF2E5675), // Card and button color
          secondary: Colors.white, // AppBar and NavBar background
          tertiary: Color.fromARGB(255, 183, 211, 233), // Additional accent color
          surface: Color(0xFFE0E0E0), // Surface color for cards, dialogs, etc.
          error: Color(0xFFB00020), // Color for error messages and indicators
          onPrimary: Colors.white, // Text/icon color on top of primary color
          onSecondary: Colors.black, // Text/icon color on top of secondary color
          onTertiary: Color(0xFF000000), // Text/icon color on top of tertiary color
          onSurface: Color(0xFF000000), // Text/icon color on top of the surface color
          onError: Color(0xFFFFFFFF), // Text/icon color on top of the error color
          outline: Color(0xFF737373), // Outline or border color
          shadow: Color(0x29000000), // Shadow color for elevation effects
          brightness: Brightness.light, // Light mode
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
    );
  }
}
