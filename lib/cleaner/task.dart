import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import the TTS package
import '../providers/task_provider.dart';
import 'task_details.dart';
import '../widget/cleanericons.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CleanerTasksScreen extends ConsumerStatefulWidget {
  final Logger logger = Logger();

  CleanerTasksScreen({super.key});

  @override
  _CleanerTasksScreenState createState() => _CleanerTasksScreenState();
}

class _CleanerTasksScreenState extends ConsumerState<CleanerTasksScreen> {
@override
void initState() {
  super.initState();

  // Fetch tasks when the widget is built
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanerId = prefs.getString('cleanerId'); // Retrieve the cleanerId from SharedPreferences

    if (cleanerId != null) {
      ref.read(taskProvider.notifier).fetchTasks(int.parse(cleanerId));
    } else {
      // Log or handle missing cleanerId
      debugPrint('Cleaner ID not found.');
    }
  });
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
          'Tugasan',
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
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: tasksAsyncValue.when(
                  data: (tasks) {
                    widget.logger.i('Tasks received by _buildTaskList: $tasks');
                    return _buildTaskList(
                      context,
                      ref,
                      tasks,
                      flutterTts,
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => const Center(
                    child: Text('Gagal memuatkan tugasan.'),
                  ),
                ),
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
  FlutterTts flutterTts,
) {
   widget.logger.i('Number of tasks in _buildTaskList: ${tasks.length}'); // Add this log
   widget.logger.i('Tasks in _buildTaskList: $tasks'); // Add this log

  if (tasks.isEmpty) {
    return const Center(child: Text('Tiada tugasan tersedia.'));
  }

  return RefreshIndicator(
    onRefresh: () async {
      final prefs = await SharedPreferences.getInstance();
      final cleanerId = prefs.getString('cleanerId');

      if (cleanerId != null) {
        await ref.read(taskProvider.notifier).refreshTasks(int.parse(cleanerId));
      } else {
        debugPrint('Cleaner ID not found.');
      }
    },
    child: ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        widget.logger.i('Building card for task: $task');

        return Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Ear Icon (Speak Task Details)
                  GestureDetector(
                    onTap: () {
                      _speakTaskDetails(
                        flutterTts,
                        task['comp_desc'] ?? 'Tiada Penerangan',
                        task['comp_location'] ?? 'Tiada Lokasi',
                        task['assigned_date'] ?? 'Tiada Tarikh',
                      );
                    },
                    child: CleanerIcons.earIcon(context),
                  ),
                  const SizedBox(width: 16), // Add spacing between icons

                  // Thumbs Up Icon
                  GestureDetector(
                    onTap: () {
                      // Handle the thumbs up action
                      _handleThumbsUp(task['complaint_id']);
                    },
                    child: CleanerIcons.thumbsUpIcon(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildTaskCard(
                context,
                ref,
                task['comp_desc'] ?? 'Tiada Penerangan',
                task['comp_location'] ?? 'Tiada Lokasi',
                task['assigned_date'] ?? 'Tiada Tarikh',
                task['comp_image'],
                task['complaint_id'],
              ),
            ],
          ),
        );
      },
    ),
  );
}

void _handleThumbsUp(int complaintId) async {
  final prefs = await SharedPreferences.getInstance();
  final cleanerId = prefs.getString('cleanerId');

  if (cleanerId == null) {
    widget.logger.w('Cleaner ID not found.');
    return;
  }

  try {
    // Use the public getter `taskService` to access the TaskService instance
    await ref.read(taskProvider.notifier).taskService.notifiedTasks(
          complaintId,
          int.parse(cleanerId),
        );

    // Refresh tasks after marking the task as completed
    await ref.read(taskProvider.notifier).refreshTasks(int.parse(cleanerId));

    // Display "Tugasan disahkan" instead of using SnackBar
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Makluman'),
          content: const Text('Tugasan disahkan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  } catch (e) {
    widget.logger.e('Error completing task: $e');
  }
}

  Future<void> _speakTaskDetails(
    FlutterTts flutterTts,
    String description,
    String location,
    String date,
  ) async {
    final String textToSpeak = "Tugas: $description. Lokasi: $location. Tarikh Ditugaskan: $date.";
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
  ) {
    widget.logger.i('Rendering task card with title: $title, subtitle: $subtitle, date: $date'); 
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

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
            ],
          ),
          const SizedBox(height: 8),

          // Divider
          Divider(color: onPrimaryColor.withOpacity(0.5), thickness: 1),
          const SizedBox(height: 8),

          // Location and Assigned Date
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
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
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
      return 'Tarikh tidak betul.';
    }
  }
}
