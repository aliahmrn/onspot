import 'package:flutter/material.dart';
import '../supervisor/homescreen.dart';
import '../supervisor/complaints.dart';
import '../supervisor/history.dart';
import '../supervisor/profile.dart';
import '../supervisor/search.dart';
import '../supervisor/navbar.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key}); // Use super.key here

  @override
  MainNavigatorState createState() => MainNavigatorState(); // Made public
}

class MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SupervisorHomeScreen(),
    const SearchPage(),
    const ComplaintPage(),
    const HistoryPage(),
    const SVProfileScreen(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update index if arguments are passed (e.g., from ComplaintPage back arrow)
    final args = ModalRoute.of(context)?.settings.arguments as int?;
    if (args != null) {
      _currentIndex = args; // Set _currentIndex to argument (0 for home)
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SupervisorBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
