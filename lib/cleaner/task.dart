import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'navbar.dart'; // Import the reusable navbar
import 'task_details.dart'; // Import TaskDetailsPage for navigation

class CleanerTasksScreen extends StatelessWidget {
  const CleanerTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF), // Change AppBar color to #FEF7FF
        elevation: 0, // Remove shadow
        automaticallyImplyLeading: false,
        title: const Text(
          'Tasks',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20, // Same size as "Home" on the homescreen
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Container(
        color: const Color(0xFFFEF7FF), // Keep the body background color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First task
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Two icons (ear, thumbs up)
                Row(
                  children: [
                    _buildSvgIconButton('assets/images/ear.svg'), // Use SVG for ear icon
                    const SizedBox(width: 8),
                    _buildSvgIconButton('assets/images/thumbs_up.svg'), // Use SVG for thumbs-up
                  ],
                ),
                const SizedBox(width: 16), // Space between icons and task card
              ],
            ),
            const SizedBox(height: 8),
            // Task Card 1
            _buildTaskCard(context, 'Room Cleaning', 'Floor 2'),
            const SizedBox(height: 16),

            // Second task
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Two icons (ear, thumbs up)
                Row(
                  children: [
                    _buildSvgIconButton('assets/images/ear.svg'), // Use SVG for ear icon
                    const SizedBox(width: 8),
                    _buildSvgIconButton('assets/images/thumbs_up.svg'), // Use SVG for thumbs-up
                  ],
                ),
                const SizedBox(width: 16), // Space between icons and task card
              ],
            ),

            const SizedBox(height: 8),
            // Task Card 2
            _buildTaskCard(context, 'Window Cleaning', 'Floor 4'),
          ],
        ),
      ),
      // Reusable Cleaner Bottom NavBar with slide transition
      bottomNavigationBar: CleanerBottomNavBar(
        currentIndex: 1, // Set the index to 1 for "Tasks" as selected
      ),
    );
  }

  // Updated helper function to include navigation to TaskDetailsPage
  Widget _buildTaskCard(BuildContext context, String title, String subtitle) {
    return InkWell(
      onTap: () {
        // Navigate to TaskDetailsPage when the task is tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TaskDetailsPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF92AEB9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
            const Icon(Icons.arrow_forward, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  // Helper function to build icon button with SVG
  Widget _buildSvgIconButton(String svgPath) {
    return Container(
      width: 40, // Fixed width for the icon button
      height: 40, // Fixed height for the icon button
      decoration: BoxDecoration(
        color: const Color(0xFFC4C3CB),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: SvgPicture.asset(svgPath), // Add SVG asset here
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const CleanerTasksScreen(), // Use the CleanerTasksScreen class here
  ));
}
