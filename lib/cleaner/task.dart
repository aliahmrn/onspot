import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import the TTS package
import '../providers/task_provider.dart';
import 'task_details.dart';
import '../widget/cleanericons.dart';
import 'package:logger/logger.dart';

class CleanerTasksScreen extends ConsumerWidget {
  // Declare Logger at the class level
  final Logger logger = Logger();

 CleanerTasksScreen({super.key});
  

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsyncValue = ref.watch(taskProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
  

    // Initialize the FlutterTts instance
    final FlutterTts flutterTts = FlutterTts();

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
              child: tasksAsyncValue.when(
                data: (tasks) {
                  logger.i('Tasks passed to ListView.builder: $tasks');
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No assigned tasks yet.'));
                  }

                  // Wrap the ListView.builder with RefreshIndicator
                  return RefreshIndicator(
                    onRefresh: () async {
                      // Call the refresh logic for the task provider
                      await ref.read(taskProvider.notifier).refreshTasks();
                    },
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        try {
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
                                        // Use TTS to speak task details
                                        _speakTaskDetails(
                                          flutterTts,
                                          task['comp_desc'] ?? 'No Description',
                                          task['comp_location'] ?? 'No Location',
                                          task['comp_date'] ?? 'No Date',
                                        );
                                      },
                                      child: CleanerIcons.earIcon(context),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        // Mark the task as clicked
                                        ref.read(taskProvider.notifier).markTaskAsClicked(task['complaint_id']);
                                      },
                                      child: ref.read(taskProvider.notifier).isTaskClicked(task['complaint_id'])
                                          ? const SizedBox.shrink() // Hide the thumbs-up icon if clicked
                                          : CleanerIcons.thumbsUpIcon(context),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8), // Space between icons and card
                                _buildTaskCard(
                                  context,
                                  ref,
                                  task['comp_desc'] ?? 'No Description',
                                  task['comp_location'] ?? 'No Location',
                                  task['comp_date'] ?? 'No Date',
                                  task['comp_image'],
                                  task['complaint_id'],
                                  task['comp_status'] ?? 'Unknown',
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          logger.e('Error rendering task: $e');
                          return const Text('Error rendering task.');
                        }
                      },
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) {
                  return const Center(child: Text('Failed to load tasks.'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to use TTS to speak task details
  Future<void> _speakTaskDetails(
    FlutterTts flutterTts,
    String description,
    String location,
    String date,
  ) async {
    final String textToSpeak =
        "Tugas: $description. Lokasi: $location. Tarikh: $date.";
    try {
      await flutterTts.setLanguage("ms-MY");
      await flutterTts.setSpeechRate(0.3); // Adjust speech rate
      await flutterTts.awaitSpeakCompletion(true); // Ensure it waits for the speech to complete
      await flutterTts.speak(textToSpeak); // Speak the task details
    } catch (e) {
      debugPrint('Error in TTS: $e');
    }
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref, // Add WidgetRef parameter
    String title,
    String subtitle,
    String date,
    String? imageUrl,
    int complaintId,
    String status, // Pass dynamic status
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final taskProviderNotifier = ref.read(taskProvider.notifier); // Use ref.read

    // Determine the color for the status
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'pending':
          return Colors.orange;
        case 'ongoing':
          return Colors.blue;
        case 'completed':
          return Colors.green;
        default:
          return Colors.grey; // Default for unknown status
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor, // Use primary color for the card background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row for Task Description and Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Task description
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onPrimaryColor, // Text color matches the card's contrast
                  ),
                ),
              ),
              // Status badge
              if (taskProviderNotifier.isTaskClicked(complaintId))
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: getStatusColor(status)),
                  ),
                  child: Text(
                    "$status", // Dynamically display the `comp_status`
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(status),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8), // Spacing before the divider

          // Divider
          Divider(
            color: onPrimaryColor.withOpacity(0.5), // Faint line for separation
            thickness: 1,
          ),
          const SizedBox(height: 8), // Spacing after the divider

          // Task location and date with navigation arrow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Task location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
              // Navigation arrow
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          TaskDetailsPage(
                        complaintId: complaintId,
                        location: subtitle,
                        date: date,
                        imageUrl: imageUrl,
                        description: title,
                      ),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
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
        ],
      ),
    );
  }

  String _formatDate(String? rawDate) {
    logger.i('Raw date: $rawDate');
    if (rawDate == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(rawDate); // Parse raw date string
      final formattedDate =
          DateFormat('dd/MM/yyyy').format(parsedDate); // Format to DD/MM/YYYY
      logger.i('Formatted date: $formattedDate');
      return formattedDate;
    } catch (e) {
      logger.e('Date formatting error: $e');
      return 'Invalid Date';
    }
  }
}
