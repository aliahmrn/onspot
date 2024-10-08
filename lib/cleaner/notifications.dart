import 'package:flutter/material.dart';
import 'navbar.dart'; // Import reusable CleanerBottomNavBar

const Color appBarColor = Color(0xFFFEF7FF); // Set AppBar color to #fef7ff

class CleanerNotificationsScreen extends StatelessWidget {
  const CleanerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor, // Change to specified color
        elevation: 0, // Remove shadow
        automaticallyImplyLeading: false, // Ensure no back button or space
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20, // Same size as "Home" on the homescreen
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildNotificationCard('Task Completed', 'Task at Location', '9:41 AM'),
          const SizedBox(height: 8),
          _buildNotificationCard('Task Assigned', 'Task at Location', '9:41 AM'),
          const SizedBox(height: 8),
          _buildNotificationCard('Task Completed', 'Task at Location', '9:41 AM'),
        ],
      ),
      // Use the reusable CleanerBottomNavBar
      bottomNavigationBar: CleanerBottomNavBar(
        currentIndex: 2, // Set index to 2 for "Notifications"
      ),
    );
  }

  // Helper function to build the notification card
  Widget _buildNotificationCard(String title, String subtitle, String time) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF92AEB9), // Color similar to the image
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey.shade300, // Placeholder avatar color
                child: const Icon(Icons.task_alt, color: Colors.white), // Placeholder icon
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16, // Adjusted font size
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: CleanerNotificationsScreen(),
  ));
}
