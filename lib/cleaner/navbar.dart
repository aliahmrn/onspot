import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'task.dart';
import 'notifications.dart';
import 'profile.dart';
import 'homescreen.dart'; // Import your home screen

class CleanerBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CleanerBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide in from the right
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Prevent navigating to the same page

    switch (index) {
      case 0:
        _navigateToPage(context, const CleanerHomeScreen());
        break;
      case 1:
        _navigateToPage(context, const CleanerTasksScreen());
        break;
      case 2:
        _navigateToPage(context, const CleanerNotificationsScreen());
        break;
      case 3:
        _navigateToPage(context, CleanerProfileScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFFFEF7FF), // Change to the desired color
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      currentIndex: currentIndex, // Highlight the current tab
      onTap: (index) => _onItemTapped(context, index),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: ImageIcon(
            AssetImage('assets/images/home.png'),
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/calendar.svg',
            width: 24,
            height: 24,
          ),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/bell.svg',
            width: 24,
            height: 24,
          ),
          label: 'Notifications',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/user.svg',
            width: 24,
            height: 24,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
