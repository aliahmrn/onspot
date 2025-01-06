import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import the TTS package
import '../providers/task_provider.dart';
import 'task_details.dart';
import '../widget/cleanericons.dart';
import 'package:logger/logger.dart';

class CleanerTasksScreen extends ConsumerStatefulWidget {
  final Logger logger = Logger();

  CleanerTasksScreen({super.key});

  @override
  _CleanerTasksScreenState createState() => _CleanerTasksScreenState();
}

class _CleanerTasksScreenState extends ConsumerState<CleanerTasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController
    _tabController = TabController(length: 2, vsync: this);

    // Fetch tasks when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskProvider.notifier).fetchTasks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // Primary background color
          Container(color: primaryColor),
          // Rounded white container
          Positioned(
            top: screenHeight * 0.01,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor, // Use secondary color for the rounded container
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
              ),
              child: Column(
                children: [
                  // TabBar
                  Container(
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.06),
                        topRight: Radius.circular(screenWidth * 0.06),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: primaryColor,
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.black45,
                      tabs: [
                        Tab(
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.circle, size: 24, color: Colors.grey), // Background circle for "Not Notified"
                              Icon(Icons.notifications_off, size: 18, color: Colors.white), // "Not Notified" icon
                            ],
                          ),
                          text: 'Not Notified',
                        ),
                        Tab(
                          icon: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.circle, size: 24, color: primaryColor), // Background circle for "Notified"
                              Icon(Icons.notifications_active, size: 18, color: Colors.white), // "Notified" icon
                            ],
                          ),
                          text: 'Notified',
                        ),
                      ],
                    ),
                  ),
                  // Content for tabs
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      child: tasksAsyncValue.when(
                        data: (tasks) {
                          final notNotifiedTasks = tasks['notNotified'] ?? [];
                          final notifiedTasks = tasks['notified'] ?? [];

                          return TabBarView(
                            controller: _tabController,
                            children: [
                              _buildTaskList(
                                context,
                                ref,
                                notNotifiedTasks,
                                flutterTts,
                                showThumbsUp: true,
                              ),
                              _buildTaskList(
                                context,
                                ref,
                                notifiedTasks,
                                flutterTts,
                                showThumbsUp: false,
                                showCompStatus: true,
                              ),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stackTrace) => const Center(
                          child: Text('Failed to load tasks.'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> tasks,
    FlutterTts flutterTts, {
    required bool showThumbsUp,
    bool showCompStatus = false, // New parameter to control comp_status display
  }) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No tasks available.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(taskProvider.notifier).refreshTasks();
      },
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
                    if (showThumbsUp)
                      GestureDetector(
                        onTap: () {
                          ref.read(taskProvider.notifier).toggleTaskNotification(task['complaint_id']);
                        },
                        child: CleanerIcons.thumbsUpIcon(context),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTaskCard(
                  context,
                  ref,
                  task['comp_desc'] ?? 'No Description',
                  task['comp_location'] ?? 'No Location',
                  task['comp_date'] ?? 'No Date',
                  task['comp_image'],
                  task['complaint_id'],
                  task['comp_status'] ?? 'Unknown',
                  compStatus: showCompStatus ? task['comp_status'] : null, // Pass comp_status for notified tab
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _speakTaskDetails(
    FlutterTts flutterTts,
    String description,
    String location,
    String date,
  ) async {
    final String textToSpeak = "Tugas: $description. Lokasi: $location. Tarikh: $date.";
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
    WidgetRef ref,
    String title,
    String subtitle,
    String date,
    String? imageUrl,
    int complaintId,
    String status,
    {String? compStatus} 
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    // Function to determine the color of the badge
    Color getStatusColor(String status) {
      switch (status.toLowerCase()) {
        case 'ongoing':
          return Colors.blue; // Blue for ongoing
        case 'completed':
          return Colors.green; // Green for completed
        default:
          return Colors.grey; // Default color for unknown statuses
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Subtitle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: onPrimaryColor,
                  ),
                ),
              ),
              // Display comp_status as a badge if provided
              if (compStatus != null)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: getStatusColor(compStatus).withOpacity(0.2), // Light background
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: getStatusColor(compStatus)),
                  ),
                  child: Text(
                    compStatus,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: getStatusColor(compStatus),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Divider
          Divider(color: onPrimaryColor.withOpacity(0.5), thickness: 1),
          const SizedBox(height: 8),

          // Location and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subtitle, style: TextStyle(fontSize: 14, color: onPrimaryColor)),
                    const SizedBox(height: 4),
                    Text(_formatDate(date), style: TextStyle(fontSize: 12, color: onPrimaryColor)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
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
                      transitionDuration: Duration.zero, // Disable transition duration
                      reverseTransitionDuration: Duration.zero, // Disable reverse transition
                    ),
                  );
                },
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: onPrimaryColor,
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
    try {
      final parsedDate = DateTime.parse(rawDate ?? '');
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }
}
