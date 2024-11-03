import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'task.dart';
import 'notifications.dart';
import 'profile.dart';
import 'homescreen.dart';

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

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
    if (index == currentIndex) return;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: screenHeight * 0.02, // 2% of screen height
        left: screenWidth * 0.06, // 6% of screen width
        right: screenWidth * 0.06, // 6% of screen width
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shadow Container with Rounded Corners
          Positioned(
            bottom: screenHeight * 0, // Place shadow closer to the navbar
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.08, // Responsive height for shadow
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(screenWidth * 0.06), // Rounded corners for shadow
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 134, 134, 134).withOpacity(0.15),
                    blurRadius: screenWidth * 0.02, // Subtle blur for shadow
                    offset: Offset(0, screenHeight * 0.002), // Minimal offset for closeness
                  ),
                ],
              ),
            ),
          ),
          // Main Navigation Bar Container
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
            child: Container(
              color: secondaryColor, // Background color for navbar
              child: BottomNavigationBar(
                backgroundColor: secondaryColor,
                selectedItemColor: primaryColor,
                unselectedItemColor: tertiaryColor,
                currentIndex: currentIndex,
                onTap: (index) => _onItemTapped(context, index),
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: ImageIcon(
                      AssetImage('assets/images/home.png'),
                      color: currentIndex == 0 ? primaryColor : tertiaryColor,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/calendar.svg',
                      width: screenWidth * 0.06, // Responsive icon size
                      height: screenWidth * 0.06,
                      colorFilter: ColorFilter.mode(
                        currentIndex == 1 ? primaryColor : tertiaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/bell.svg',
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                      colorFilter: ColorFilter.mode(
                        currentIndex == 2 ? primaryColor : tertiaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Notifications',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/user.svg',
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                      colorFilter: ColorFilter.mode(
                        currentIndex == 3 ? primaryColor : tertiaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Profile',
                  ),
                ],
                type: BottomNavigationBarType.fixed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
