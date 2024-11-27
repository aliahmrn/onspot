import 'package:flutter/material.dart';
import 'notifications.dart';
import 'profile.dart';
import 'package:onspot_cleaner/widget/cleanericons.dart';

class DesignPage extends StatelessWidget {
  const DesignPage({super.key});

  void handleBellTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanerNotificationsScreen(),
      ),
    );
  }

  void handleProfileTap(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CleanerProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Tasks',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(color: primaryColor),
          Positioned(
            top: screenHeight * 0.01,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: 5, // Number of items in the list
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 32.0), // Space between each card set
                          child: Row(
  children: [
    GestureDetector(
      onTap: () {
        // Action for ear icon
      },
      child: CleanerIcons.earIcon(context),
    ),
    const SizedBox(width: 8),
    GestureDetector(
      onTap: () {
        // Action for thumbs-up icon
      },
      child: CleanerIcons.thumbsUpIcon(context),
    ),
  ],
),

                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                color: secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskCard(
    BuildContext context,
    String title,
    String subtitle,
    String date,
    String? imageUrl,
    int complaintId,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final tertiaryColor = Theme.of(context).colorScheme.tertiary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tertiaryColor, // Set background to tertiary color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor, // Primary color for title
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor, // Primary color for subtitle
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor, // Primary color for date
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Arrow icon inside the card on the right
          Icon(
            Icons.arrow_forward_ios,
            color: primaryColor,
            size: 24,
          ),
        ],
      ),
    );
  }
}
