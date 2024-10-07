import 'package:flutter/material.dart';
import 'officer_navbar.dart'; // Import the new navigation bar widget
import 'officer_history.dart';
import 'officer_profile.dart';
import '../bell_profile_widget.dart';
import 'officer_complaint.dart';

class OfficerHomeScreen extends StatelessWidget {
  const OfficerHomeScreen({super.key});

  void _handleBellTap(BuildContext context) {
    // Navigate to history page or any other page on bell tap
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
  }

  void _handleProfileTap(BuildContext context) {
    // Navigate to profile page on profile picture tap
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OfficerProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.0), // Set preferred height for AppBar
        child: Material(
          elevation: 4.0, // Add shadow to AppBar
          child: AppBar(
            elevation: 0, // Remove default elevation
            backgroundColor: const Color(0xFFFEF7FF), // Change AppBar color to #FEF7FF
            title: const Center(
              child: Text(
                'Home',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            automaticallyImplyLeading: false, // Remove back button
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Row with Bell and Profile Picture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Welcome, Officer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    BellProfileWidget(
                      onBellTap: () =>
                          _handleBellTap(context), // Handle bell tap
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _handleProfileTap(
                          context), // Handle profile picture tap
                      child: CircleAvatar(
                        backgroundImage:
                            const AssetImage('assets/images/profile.png'),
                        radius: 15, // Profile picture size
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Welcome Banner
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: const DecorationImage(
                  image: AssetImage('assets/images/welcome_vacuum.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // File Complaint Section
            GestureDetector(
              onTap: () {
                // Navigate to file complaint page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FileComplaintPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Image(
                      image: AssetImage('assets/images/messy.png'),
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Noticed a mess?',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text('We\'re on it - File a complaint now!'),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 20, color: Colors.black),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // History Section with "See All" option
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to history page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HistoryPage()),
                    );
                  },
                  child: const Text(
                    'see all',
                    style: TextStyle(
                      color: Color.fromARGB(255, 165, 165, 165),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Recent History Item
            GestureDetector(
              onTap: () {
                // Navigate to history page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF92AEB9), // Background color
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 24, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          'Floor 2',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Room Cleaning',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      '1 week ago',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          const OfficerNavBar(currentIndex: 0), // OfficerNavBar at bottom
    );
  }
}
