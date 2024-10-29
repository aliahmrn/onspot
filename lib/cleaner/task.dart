import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:onspot_cleaner/service/task_service.dart'; // Import TaskService for API calls
import 'navbar.dart'; // Import the reusable navbar
import 'task_details.dart'; // Import TaskDetailsPage for navigation
import 'package:onspot_cleaner/widget/cleanericons.dart'; // Import CleanerIcons for icons

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tasks',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
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

          return Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: CleanerIcons.earIcon(),
                          onPressed: () {
                            logger.i('Ear icon tapped for complaint ID: ${task['complaint_id']}');
                            // Add action for ear button here
                          },
                        ),
                        IconButton(
                          icon: CleanerIcons.thumbsUpIcon(),
                          onPressed: () {
                            logger.i('Thumbs up icon tapped for complaint ID: ${task['complaint_id']}');
                            // Add action for thumbs up button here
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8), // Space between buttons and card
                    _buildTaskCard(
                      context,
                      task['comp_desc'] ?? 'No Description',
                      task['comp_location'] ?? 'No Location',
                      task['comp_date'] ?? 'No Date',
                      task['comp_image'] ?? null,
                      task['complaint_id'],
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: CleanerBottomNavBar(
        currentIndex: 1,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF92AEB9),
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
                  style: const TextStyle(
                    fontSize: 16,
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
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.black54),
            onPressed: () {
              logger.i('Navigating to TaskDetailsPage for complaint ID: $complaintId');
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
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: const CleanerTasksScreen(),
  ));
}
