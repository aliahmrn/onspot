import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:onspot_cleaner/service/task_service.dart'; // Import TaskService for API calls
import 'navbar.dart';
import 'task_details.dart';
import 'package:onspot_cleaner/widget/cleanericons.dart';

class CleanerTasksScreen extends StatefulWidget {
  const CleanerTasksScreen({super.key});

  @override
  CleanerTasksScreenState createState() => CleanerTasksScreenState();
}

class CleanerTasksScreenState extends State<CleanerTasksScreen> {
  final Logger logger = Logger();
  final TaskService taskService = TaskService();

  late Future<List<Map<String, dynamic>>?> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = taskService.getCleanerTasks(69); // Use cleaner's ID as per your use case
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
              child: FutureBuilder<List<Map<String, dynamic>>?>(
                future: futureTasks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    logger.e('Error fetching tasks: ${snapshot.error}');
                    return const Center(child: Text('Failed to load tasks.'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No tasks available.'));
                  }

                  final tasks = snapshot.data!;

                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                Row(
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
                                  const SizedBox(height: 8), // Space between icons and card
                                  _buildTaskCard(
                                    context,
                                    task['comp_desc'] ?? 'No Description',
                                    task['comp_location'] ?? 'No Location',
                                    task['comp_date'] ?? 'No Date',
                                    task['comp_image'],
                                    task['complaint_id'],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
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
                child: CleanerBottomNavBar(currentIndex: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
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
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskDetailsPage(
                    complaintId: complaintId,
                    location: subtitle,
                    date: date,
                    imageUrl: imageUrl,
                    description: title,
                  ),
                ),
              );
            },
            child: Icon(
              Icons.arrow_forward_ios,
              color: primaryColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
