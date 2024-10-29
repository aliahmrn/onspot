import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../supervisor/main_navigator.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _clearTokenOnStartup(); // Clear token on startup to ensure login screen displays
  runApp(const OnspotSupervisorApp());
}

Future<void> _clearTokenOnStartup() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token'); // Clear token on each app start
}

class OnspotSupervisorApp extends StatelessWidget {
  const OnspotSupervisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      routes: {
        '/main-navigator': (context) => const MainNavigator(),
        '/login': (context) => const LoginScreen(),
      },
      home: const LoginScreen(), // Always start with LoginScreen
    );
  }
}
