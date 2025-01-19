import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/history_provider.dart';
import '../widget/cleanericons.dart'; // Import CleanerIcons here
import 'task_details.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CleanerHistoryScreen extends ConsumerStatefulWidget {
  final Logger logger = Logger();

  CleanerHistoryScreen({Key? key}) : super(key: key);

  @override
  _CleanerHistoryScreenState createState() => _CleanerHistoryScreenState();
}

class _CleanerHistoryScreenState extends ConsumerState<CleanerHistoryScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch history tasks when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final cleanerId = prefs.getString('cleanerId');

      if (cleanerId != null) {
        ref.read(historyProvider.notifier).fetchHistoryTasks(int.parse(cleanerId));
      } else {
        debugPrint('Cleaner ID not found.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyTasksAsyncValue = ref.watch(historyProvider);
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
        automaticallyImplyLeading: true,
        title: Text(
          'Rekod Tugasan',
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
                child: historyTasksAsyncValue.when(
                  data: (tasks) {
                    return _buildHistoryList(context, ref, tasks, flutterTts);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => const Center(
                    child: Text('Gagal memuatkan rekod tugasan.'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> tasks,
    FlutterTts flutterTts,
  ) {
    if (tasks.isEmpty) {
      return const Center(child: Text('Tiada rekod tugasan tersedia.'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        final prefs = await SharedPreferences.getInstance();
        final cleanerId = prefs.getString('cleanerId');

        if (cleanerId != null) {
          await ref.read(historyProvider.notifier).refreshHistoryTasks(int.parse(cleanerId));
        } else {
          debugPrint('Cleaner ID not found.');
        }
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
                      child: CleanerIcons.earIcon(context), // Use the CleanerIcons.earIcon
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildTaskCard(
                  context,
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

  Future<void> _speakTaskDetails(
    FlutterTts flutterTts,
    String description,
    String location,
    String date,
  ) async {
    final String textToSpeak = "Tugas: $description. Lokasi: $location. Tarikh Ditugaskan: $date.";
    try {
      await flutterTts.setLanguage("ms-MY");
      await flutterTts.setSpeechRate(0.3);
      await flutterTts.awaitSpeakCompletion(true);
      await flutterTts.speak(textToSpeak);
    } catch (e) {
      debugPrint('Error in TTS: $e');
    }
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
          Divider(color: onPrimaryColor.withOpacity(0.5), thickness: 1),
          const SizedBox(height: 8),
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
