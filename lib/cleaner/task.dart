import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:onspot_cleaner/service/task_service.dart'; // Import TaskService for API calls
import 'task_details.dart';
import 'package:onspot_cleaner/widget/cleanericons.dart';
import 'package:intl/intl.dart';

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
    futureTasks = _fetchAndSortTasks(); // Fetch and sort tasks
  }

  Future<List<Map<String, dynamic>>?> _fetchAndSortTasks() async {
    try {
      final tasks = await taskService.getCleanerTasks(69); // Replace 69 with the actual cleaner ID
      if (tasks != null) {
        // Sort tasks by date in descending order
        tasks.sort((a, b) {
          final dateA = DateTime.tryParse(a['comp_date'] ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b['comp_date'] ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA); // Newer dates first
        });
      }
      return tasks;
    } catch (e) {
      logger.e('Error fetching or sorting tasks: $e');
      return null;
    }
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
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor, // Use primary color for the card background
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
                    color: onPrimaryColor, // Text color matches the card's contrast
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: onPrimaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(date), // Format the date
                  style: TextStyle(
                    fontSize: 12,
                    color: onPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // Navigate without animation
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => TaskDetailsPage(
                    complaintId: complaintId,
                    location: subtitle,
                    date: date,
                    imageUrl: imageUrl,
                    description: title,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return child; // No animation
                  },
                ),
              );
            },
            child: Icon(
              Icons.arrow_forward_ios,
              color: onPrimaryColor, // Icon color matches text color
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to format the date
  String _formatDate(String? rawDate) {
    if (rawDate == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(rawDate); // Parse raw date string
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Format to DD/MM/YYYY
    } catch (e) {
      return 'Invalid Date'; // Fallback in case of error
    }
  }
}
