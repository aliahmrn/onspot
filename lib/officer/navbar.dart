import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'complaint.dart';
import 'history.dart';
import 'profile.dart';
import 'homescreen.dart';

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
          const begin = Offset(1.0, 0.0);
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
        _navigateToPage(context, const OfficerHomeScreen());
        break;
      case 1:
        _navigateToPage(context, const FileComplaintPage());
        break;
      case 2:
        _navigateToPage(context, const HistoryPage());
        break;
      case 3:
        _navigateToPage(context, const OfficerProfileScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Padding(
      padding: EdgeInsets.only(
        bottom: screenHeight * 0.02,
        left: screenWidth * 0.06,
        right: screenWidth * 0.06,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: screenHeight * 0.005,
            left: 0,
            right: 0,
            child: Container(
              height: screenHeight * 0.08,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(screenWidth * 0.06),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: screenWidth * 0.02,
                    offset: Offset(0, screenHeight * 0.005),
                  ),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(screenWidth * 0.06),
            child: Container(
              color: secondaryColor,
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
                      'assets/images/plus.svg',
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                      colorFilter: ColorFilter.mode(
                        currentIndex == 1 ? primaryColor : tertiaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'Complaint',
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      'assets/images/history.svg',
                      width: screenWidth * 0.06,
                      height: screenWidth * 0.06,
                      colorFilter: ColorFilter.mode(
                        currentIndex == 2 ? primaryColor : tertiaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: 'History',
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
