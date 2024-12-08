import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'homescreen.dart';
import 'task.dart';
import 'notifications.dart';
import 'profile.dart';
import 'navbar.dart';

// Define a provider for current navigation index
final currentIndexProvider = StateProvider<int>((ref) => 0); // Default index to Home

class MainNavigator extends ConsumerWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider); // Watch the current index

    // List of pages
    final List<Widget> pages = [
      const CleanerHomeScreen(),
            CleanerTasksScreen(),
      const CleanerNotificationsScreen(),
      const CleanerProfileScreen(),
    ];

    return Scaffold(
      // Use IndexedStack to keep the state of pages while switching
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      // Bottom navigation bar
      bottomNavigationBar: const CleanerBottomNavBar(),
    );
  }
}
