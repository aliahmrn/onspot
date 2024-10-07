import 'package:flutter/material.dart';
import 'cleaner_task.dart';
import 'cleaner_notifications.dart';
import 'cleaner_profile.dart';
import 'cleaner_navbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bell_profile_widget.dart';

const Color appBarColor = Color(0xFFFEF7FF); // Updated color for AppBar

class CleanerHomeScreen extends StatelessWidget {
  const CleanerHomeScreen({super.key});

  void _handleBellTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanerNotificationsScreen(),
      ),
    );
  }

  void _handleProfileTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanerProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: appBarColor, // Set AppBar color
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 2, // Spread radius of the shadow
                blurRadius: 5, // Blur radius of the shadow for smooth effect
                offset: const Offset(0, 3), // Offset the shadow to create depth
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300, // Light grey border color
                width: 1.0, // Thickness of the border
              ),
            ),
          ),
          child: AppBar(
            elevation: 0, // No internal elevation
            backgroundColor: Colors.transparent, // Transparent to show the container's background
            automaticallyImplyLeading: false, // Remove the back button
            title: const Text(
              'Home',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Welcome, Cleaner!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    BellProfileWidget(
                      onBellTap: () => _handleBellTap(context),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _handleProfileTap(context),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/profile.png'), // Profile image asset
                        radius: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/welcome_vacuum.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Center(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Name',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            // Handle check-in logic
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            // Handle check-out logic
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'see all',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CleanerTasksScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF92AEB9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 24, color: Colors.black),
                            const SizedBox(width: 5),
                            const Text(
                              'Floor 2',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          child: const Text(
                            '9:41 AM',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF3c6576),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Room Cleaning',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/calendar.svg',
                          height: 24,
                          color: Colors.black,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CleanerBottomNavBar(currentIndex: 0),
    );
  }
}
