import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupervisorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SupervisorBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

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
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          // Main Navigation Bar Container
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              color: Colors.white,
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                currentIndex: currentIndex,
                onTap: onTap, // Use the passed onTap function to handle navigation
                type: BottomNavigationBarType.fixed,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/images/home.png',
                      width: 24,
                      height: 24,
                      color: currentIndex == 0 ? Colors.black : Colors.grey,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/search.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 1 ? Colors.black : Colors.grey,
                    ),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/plus.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 2 ? Colors.black : Colors.grey,
                    ),
                    label: 'Complaints',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/history.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 3 ? Colors.black : Colors.grey,
                    ),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/user.svg',
                      width: 24,
                      height: 24,
                      color: currentIndex == 4 ? Colors.black : Colors.grey,
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
