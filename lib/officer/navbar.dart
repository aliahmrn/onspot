import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:onspot_officer/officer/complaint.dart';
import 'package:onspot_officer/officer/history.dart';
import 'package:onspot_officer/officer/homescreen.dart';
import 'package:onspot_officer/officer/profile.dart';

// Provider to manage the current selected index in the BottomNavigationBar
final currentIndexProvider = StateProvider<int>((ref) => 0);

class OfficerNavBar extends ConsumerWidget {
  const OfficerNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    // Screens array including the FileComplaintPage
    final List<Widget> screens = [
      const OfficerHomeScreen(),
      const FileComplaintPage(), // Complaint page stays within the tabs
      const HistoryPage(),
      Center(child: Text('Profile Placeholder')),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: currentIndex == 1 // Hide the navbar for complaint page
          ? null
          : _buildBottomNavigationBar(ref),
    );
  }

  Widget _buildBottomNavigationBar(WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);
    final theme = Theme.of(ref.context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 24, right: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          backgroundColor: theme.colorScheme.secondary,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: Colors.grey,
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(currentIndexProvider.notifier).state = index;
          },
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: [
            _buildNavbarItem(
              ref,
              index: 0,
              iconPath: 'assets/images/home.svg',
              label: 'Home',
            ),
            _buildNavbarItem(
              ref,
              index: 1,
              iconPath: 'assets/images/plus.svg',
              label: 'Complaint',
            ),
            _buildNavbarItem(
              ref,
              index: 2,
              iconPath: 'assets/images/history.svg',
              label: 'History',
            ),
            _buildNavbarItem(
              ref,
              index: 3,
              iconPath: 'assets/images/user.svg',
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavbarItem(
    WidgetRef ref, {
    required int index,
    required String iconPath,
    required String label,
  }) {
    final currentIndex = ref.watch(currentIndexProvider);

    return BottomNavigationBarItem(
      icon: SvgPicture.asset(
        iconPath,
        height: 24.0,
        width: 24.0,
        colorFilter: ColorFilter.mode(
          currentIndex == index
              ? Theme.of(ref.context).colorScheme.primary // Active color
              : Colors.grey, // Inactive color
          BlendMode.srcIn,
        ),
      ),
      label: label,
    );
  }
}