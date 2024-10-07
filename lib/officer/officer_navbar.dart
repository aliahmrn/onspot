// officer_navbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'officer_complaint.dart';
import 'officer_history.dart';
import 'officer_profile.dart';
import 'officer_homescreen.dart';

class OfficerNavBar extends StatelessWidget {
  final int currentIndex;

  const OfficerNavBar({
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
        _navigateToPage(context, const OfficerHomeScreen());
        break;
      case 1:
        _navigateToPage(context, const FileComplaintPage());
        break;
      case 2:
        _navigateToPage(context, const HistoryPage());
        break;
      case 3:
        _navigateToPage(context, OfficerProfileScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFFFEF7FF), // Change the BottomNavigationBar color to #FEF7FF
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.black54,
      currentIndex: currentIndex, // Highlight the current tab
      onTap: (index) => _onItemTapped(context, index),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Image.asset(
            'assets/images/home.png',
            width: 24,
            height: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/plus.svg',
            width: 24,
            height: 24,
          ),
          label: 'Complaint',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            'assets/images/history.svg',
            width: 24,
            height: 24,
          ),
          label: 'History',
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
