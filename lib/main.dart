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

/// Define the AttendanceService provider
final attendanceServiceProvider = FutureProvider<AttendanceService?>((ref) async {
  final baseUrl = 'http://192.168.1.105:8000/api';
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

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize SharedPreferences
  await SharedPreferencesManager.init();

  // Clear the previous token
  SharedPreferencesManager.prefs.remove('token');

  // Subscribe to cleaner notifications topic
  FirebaseMessaging.instance.subscribeToTopic('cleaners');

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
