import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'cleaner_task.dart';
import 'cleaner_notifications.dart';
import 'cleaner_profile.dart';
import 'cleaner_homescreen.dart'; // Import your home screen

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shadow Container with Rounded Corners
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius:
                    BorderRadius.circular(24), // Rounded corners for shadow
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset:
                        Offset(0, 6), // Position the shadow below the container
                  ),
                ],
              ),
            ),
          ),
          // Main Navigation Bar Container
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              color: Colors.white, // White background color
              child: BottomNavigationBar(
                backgroundColor: Colors.white, // Solid white color for the bar
                selectedItemColor: Colors.black, // Black for selected icons
                unselectedItemColor: Colors.grey, // Grey for unselected icons
                currentIndex: currentIndex, // Highlight the current tab
                onTap: (index) => _onItemTapped(context, index),
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage('assets/images/home.png'),
                      color: currentIndex == 0 ? Colors.black : Colors.grey,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/calendar.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 1 ? Colors.black : Colors.grey,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/bell.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 2 ? Colors.black : Colors.grey,
                    ),
                    label: 'Notifications',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/user.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 3 ? Colors.black : Colors.grey,
                    ),
                    label: 'Profile',
                  ),
                ],
                type: BottomNavigationBarType
                    .fixed, // Ensures all icons are visible
              ),
            ),
          ),
        ],
      ),
    );
  }
}
