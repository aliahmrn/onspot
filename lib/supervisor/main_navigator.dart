import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/navigation_provider.dart';
import 'homescreen.dart';
import 'complaints.dart';
import 'history.dart';
import 'profile.dart';
import 'search.dart';
import 'navbar.dart';

class MainNavigator extends ConsumerWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentIndexProvider); // Watch the current index
    final List<Widget> pages = [
      const SupervisorHomeScreen(),
      const SearchPage(),
      const ComplaintPage(),
      const HistoryPage(),
      const SVProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: const SupervisorBottomNavBar(),
    );
  }
}
