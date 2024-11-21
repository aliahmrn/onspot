import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:onspot_officer/login.dart';
import 'package:onspot_officer/officer/navbar.dart';
import 'package:onspot_officer/officer/complaintdetails.dart';

final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());
final themeProvider = StateProvider<ThemeData>((ref) {
  return ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: const Color(0xFF2E5675),
    colorScheme: const ColorScheme(
      primary: Color(0xFF2E5675),
      secondary: Colors.white,
      tertiary: Color.fromARGB(255, 183, 211, 233),
      surface: Color(0xFFE0E0E0),
      error: Color(0xFFB00020),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onTertiary: Color(0xFF000000),
      onSurface: Color(0xFF000000),
      onError: Color(0xFFFFFFFF),
      outline: Color(0xFF737373),
      shadow: Color(0x29000000),
      brightness: Brightness.light,
    ),
  );
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: OnspotOfficerApp()));
}

class OnspotOfficerApp extends ConsumerWidget {
  const OnspotOfficerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = ref.watch(themeProvider);
    final navigatorKey = ref.watch(navigatorKeyProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/', // Default route is login
      theme: themeData,
      routes: {
        '/': (context) => const LoginScreen(), // Login page
        '/officer-home': (context) => const OfficerNavBar(), // Main app with navbar
      },
      onGenerateRoute: (settings) {
        final logger = Logger();
        logger.i("Navigating to route: ${settings.name}");

        switch (settings.name) {
          case '/complaint-details': // Dynamic route for complaint details
            final args = settings.arguments as Map<String, dynamic>;
            final complaintId = args['complaintId'];
            return MaterialPageRoute(
              builder: (context) => ComplaintDetailsPage(complaintId: complaintId),
            );
          default:
            logger.w("Unknown route: ${settings.name}. Redirecting to login.");
            return MaterialPageRoute(builder: (context) => const LoginScreen());
        }
      },
      onUnknownRoute: (settings) {
        final logger = Logger();
        logger.w("Unknown route: ${settings.name}. Redirecting to login.");
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      },
    );
  }
}
