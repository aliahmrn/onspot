import 'package:flutter/material.dart';

class CleanerNotificationsScreen extends StatelessWidget {
  const CleanerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).colorScheme.primary; // Fetch primary color

    return Scaffold(
      backgroundColor: primaryColor, // Set the same background as tasks screen
      appBar: AppBar(
        backgroundColor: primaryColor, // Use primary color for the AppBar
        elevation: 0, // Remove shadow
        automaticallyImplyLeading: false, // Ensure no back button or space
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white, // Text color for better contrast on primary color
            fontSize: screenWidth * 0.05, // Dynamic font size
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Stack(
        children: [
          // Primary background color
          Container(color: primaryColor),
          // Rounded background container
          Positioned(
            top: screenHeight * 0.01,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary, // Match the secondary color
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
              ),
              padding: EdgeInsets.all(screenWidth * 0.04), // Adjust padding based on screen width
              child: ListView(
                children: [
                  _buildNotificationCard(
                    context,
                    screenWidth,
                    screenHeight,
                    'Task Completed',
                    'Task at Location',
                    '9:41 AM',
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildNotificationCard(
                    context,
                    screenWidth,
                    screenHeight,
                    'Task Assigned',
                    'Task at Location',
                    '10:15 AM',
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  _buildNotificationCard(
                    context,
                    screenWidth,
                    screenHeight,
                    'Task Completed',
                    'Task at Location',
                    '11:00 AM',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build the notification card
  Widget _buildNotificationCard(
    BuildContext context,
    double screenWidth,
    double screenHeight,
    String title,
    String subtitle,
    String time,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04), // Dynamic padding
      decoration: BoxDecoration(
        color: primaryColor, // Use primary color for the card
        borderRadius: BorderRadius.circular(screenWidth * 0.03), // Dynamic border radius
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: screenWidth * 0.05, // Dynamic avatar size
                backgroundColor: onPrimaryColor.withOpacity(0.2), // Light contrast color
                child: Icon(
                  Icons.task_alt,
                  color: onPrimaryColor,
                  size: screenWidth * 0.05, // Dynamic icon size
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045, // Dynamic font size
                      fontWeight: FontWeight.bold,
                      color: onPrimaryColor, // Text color matches contrast
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: screenWidth * 0.035, // Slightly smaller font size
                      color: onPrimaryColor.withOpacity(0.8), // Slightly dimmer text
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: screenWidth * 0.035, // Dynamic font size
              color: onPrimaryColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
