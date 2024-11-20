import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'homescreen.dart';
import 'complaint.dart';
import 'history.dart';
import 'profile.dart';

// Provider to manage the current selected index in the BottomNavigationBar
final currentIndexProvider = StateProvider<int>((ref) => 0);

class OfficerNavBar extends ConsumerWidget {
  const OfficerNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(currentIndexProvider);

    return BottomNavigationBar(
      backgroundColor: theme.colorScheme.secondary,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.tertiary,
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(currentIndexProvider.notifier).state = index;
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Complaint',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'History',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      type: BottomNavigationBarType.fixed,
    );
  }
}

class OfficerAppWithNavBar extends ConsumerWidget {
  const OfficerAppWithNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider);

    // Define all screens in an IndexedStack
    final pages = [
      const OfficerHomeScreen(),
      const FileComplaintPage(),
      const HistoryPage(),
      const OfficerProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: const OfficerNavBar(),
    );
  }
}
