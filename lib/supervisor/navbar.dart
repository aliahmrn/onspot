import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SupervisorBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SupervisorBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final shadowColor = Colors.black.withOpacity(0.15);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shadow Container for Rounded Effect
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
                    color: shadowColor,
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
              color: secondaryColor,
              child: BottomNavigationBar(
                backgroundColor: secondaryColor,
                selectedItemColor: primaryColor,
                unselectedItemColor: Colors.grey,
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        currentIndex == 0 ? primaryColor : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        'assets/images/home.png',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        currentIndex == 1 ? primaryColor : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/search.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    label: 'Search',
                  ),
                  BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        currentIndex == 2 ? primaryColor : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/plus.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    label: 'Complaints',
                  ),
                  BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        currentIndex == 3 ? primaryColor : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/history.svg',
                        width: 24,
                        height: 24,
                      ),
                    ),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        currentIndex == 4 ? primaryColor : Colors.grey,
                        BlendMode.srcIn,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/user.svg',
                        width: 24,
                        height: 24,
                      ),
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
