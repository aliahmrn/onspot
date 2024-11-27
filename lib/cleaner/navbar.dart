import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_navigator.dart'; // Use currentIndexProvider from the MainNavigator

class CleanerBottomNavBar extends ConsumerWidget {
  const CleanerBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider); // Watch the current index
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
                onTap: (index) {
                  print('Navigating to tab index: $index');
                  ref.read(currentIndexProvider.notifier).state = index; // Update index via Riverpod
                },
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      context,
                      currentIndex == 0,
                      'assets/images/home.png',
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      context,
                      currentIndex == 1,
                      'assets/images/calendar.svg',
                      isSvg: true,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      context,
                      currentIndex == 2,
                      'assets/images/bell.svg',
                      isSvg: true,
                    ),
                    label: 'Notifications',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildIcon(
                      context,
                      currentIndex == 3,
                      'assets/images/user.svg',
                      isSvg: true,
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

  Widget _buildIcon(BuildContext context, bool isSelected, String assetPath, {bool isSvg = false}) {
    final primaryColor = Theme.of(context).primaryColor;
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        isSelected ? primaryColor : Colors.grey,
        BlendMode.srcIn,
      ),
      child: isSvg
          ? SvgPicture.asset(
              assetPath,
              width: 24,
              height: 24,
            )
          : Image.asset(
              assetPath,
              width: 24,
              height: 24,
            ),
    );
  }
}
