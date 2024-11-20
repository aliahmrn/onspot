import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:onspot_officer/officer/history.dart';
import 'package:onspot_officer/officer/profile.dart';
import 'login.dart';
import 'officer/homescreen.dart';
import 'officer/complaint.dart';
import 'officer/complaintdetails.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

// Define a global navigator key provider
final navigatorKeyProvider = Provider((ref) => GlobalKey<NavigatorState>());

// Define the theme provider to manage the theme state
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
    textTheme: GoogleFonts.robotoTextTheme(),
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
      initialRoute: '/', // Default route
      theme: themeData,
      routes: {
          '/': (context) => const LoginScreen(),
          '/officer-home': (context) => const OfficerHomeScreen(),
          '/file-complaint': (context) => FileComplaintPage(),
          '/history': (context) => const HistoryPage(),
          '/profile': (context) => const OfficerProfileScreen(),
      },
      onGenerateRoute: (settings) {
        final logger = Logger();
        logger.i("Navigating to route: ${settings.name}");

        switch (settings.name) {
          case '/complaint-details':
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
