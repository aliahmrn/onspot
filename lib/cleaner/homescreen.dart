import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cleaner/main_navigator.dart'; // For currentIndexProvider
import '../widget/bell.dart';
import '../service/task_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart'; // Import the attendance provider
import 'package:logger/logger.dart';

class CleanerHomeScreen extends ConsumerStatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  CleanerHomeScreenState createState() => CleanerHomeScreenState();
}

class CleanerHomeScreenState extends ConsumerState<CleanerHomeScreen> {
  bool isChecked = false;
  Map<String, dynamic>? latestTask;
  String? error;
  bool isLoading = true; // Loading state
  final TaskService taskService = TaskService();
  String? cleanerName; // Cleaner name
  final _logger = Logger();

  @override
  void initState() {
    super.initState();
    _fetchCleanerName(); // Fetch cleaner name
    _fetchLatestTask(); // Fetch latest task
    _checkAttendanceState(); // Check attendance state
  }

  Future<void> _fetchCleanerName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return; // Guard against using BuildContext when unmounted
      setState(() {
        cleanerName = prefs.getString('name') ?? 'Cleaner'; // Default fallback
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cleanerName = 'Cleaner'; // Fallback in case of error
      });
    }
  }


Future<void> _fetchLatestTask() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cleanerId = prefs.getString('cleanerId'); // Retrieve cleanerId from SharedPreferences

    if (cleanerId == null) {
      setState(() {
        error = 'Cleaner ID is missing.';
        isLoading = false;
      });
      _logger.e('Error: Cleaner ID is missing.');
      return;
    }

    // Fetch all tasks assigned to the cleaner
    final tasks = await taskService.getCleanerTasks(int.parse(cleanerId));
    _logger.i('Fetched tasks: $tasks');

    if (tasks != null && tasks.isNotEmpty) {
      // Sort tasks by `comp_date` in descending order
      tasks.sort((a, b) {
        final dateA = DateTime.parse(a['comp_date']);
        final dateB = DateTime.parse(b['comp_date']);
        return dateB.compareTo(dateA); // Most recent first
      });

      setState(() {
        latestTask = tasks.first; // Take the most recent task
        isLoading = false;
      });

      _logger.i('Latest task (sorted by date): $latestTask');
    } else {
      setState(() {
        latestTask = null; // No tasks available
        isLoading = false;
      });
      _logger.i('No tasks found.');
    }
  } catch (e) {
    setState(() {
      error = 'Failed to load latest task: $e';
      isLoading = false;
    });
    _logger.e('Error fetching tasks: $e');
  }
}

Future<void> _checkAttendanceState() async {
  if (isChecked) return; // Avoid multiple calls
  final prefs = await SharedPreferences.getInstance();
  final cleanerId = prefs.getString('cleanerId');
  if (cleanerId != null) {
    await ref.read(attendanceProvider.notifier).checkAttendance(int.parse(cleanerId));
  }
  setState(() {
    isChecked = true;
  });
}

  // Update index to Notifications (2)
  void _handleBellTap(WidgetRef ref) {
    ref.read(currentIndexProvider.notifier).state = 2;
  }

  // Update index to Profile (3)
  void _handleProfileTap(WidgetRef ref) {
    ref.read(currentIndexProvider.notifier).state = 3;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final onSecondaryColor = Theme.of(context).colorScheme.onSecondary;

    // Watch the asynchronous state of attendanceProvider
    final attendanceStateAsync = ref.watch(attendanceProvider);

     // Declare status variables here
    final String status = attendanceStateAsync.maybeWhen(
      data: (attendanceState) => attendanceState.status ?? 'Unavailable',
      orElse: () => 'Unavailable',
    );
    final Color statusColor = status.toLowerCase() == 'available'
        ? Colors.green
        : Colors.red;

    return attendanceStateAsync.when(
      data: (attendanceState) {
        // Render the UI when data is available
        return Scaffold(
          backgroundColor: primaryColor,
          appBar: AppBar(
            backgroundColor: primaryColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Text(
              'Home',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome and Bell Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Welcome, ${attendanceState.cleanerName ?? "Cleaner"}',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: onSecondaryColor,
                            ),
                          ),
                          Row(
                            children: [
                              BellProfileWidget(
                                onBellTap: () => _handleBellTap(ref),
                              ),
                              SizedBox(width: screenWidth * 0.025),
                              GestureDetector(
                                onTap: () => _handleProfileTap(ref),
                                child: CircleAvatar(
                                  radius: screenWidth * 0.04,
                                  child: Icon(Icons.person, size: screenWidth * 0.05),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),

                        // Cleaner Status Section
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.02), // Slight left padding
                          child: _buildStatusBadge(
                            status, // Cleaner status
                            statusColor, // Color based on the status
                            Theme.of(context).textTheme, // Use the text theme for consistent styling
                            screenWidth, // Provide screen width for responsive design
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                      // Welcome Icon
                      Center(
                        child: SvgPicture.asset(
                          'assets/images/welcome.svg',
                          height: screenHeight * 0.25,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // Attendance Card (conditionally displayed)
                      if (attendanceState.showCard)
                        _buildAttendanceCard(
                          screenWidth,
                          screenHeight,
                          primaryColor,
                          onPrimaryColor,
                          secondaryColor,
                          ref,
                        ),

                      SizedBox(height: screenHeight * 0.02),

                      // Task Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Task',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: onSecondaryColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(currentIndexProvider.notifier).state = 1; // Task Page index
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenHeight * 0.008,
                              ),
                              decoration: BoxDecoration(
                                color: onSecondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'See All',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w500,
                                      color: onSecondaryColor,
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: screenWidth * 0.035, color: onSecondaryColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),

                      // Task Section
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : error != null
                              ? Center(child: Text(error!))
                              : _buildTaskCard(
                                  context,
                                  ref,
                                  latestTask?['comp_desc'], // Nullable description
                                  latestTask?['comp_location'], // Nullable location
                                  latestTask?['comp_date'], // Nullable date
                                )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () {
        return Scaffold(
          backgroundColor: Colors.white, // White background
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor), // Primary color indicator
            ),
          ),
        );
      },
      error: (err, stack) {
        return Scaffold(
          backgroundColor: primaryColor,
          body: Center(
            child: Text(
              'Error: $err',
              style: TextStyle(
                color: Colors.red,
                fontSize: screenWidth * 0.05,
              ),
            ),
          ),
        );
      },
    );
  }

Widget _buildStatusBadge(String status, Color statusColor, TextTheme textTheme, double screenWidth) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
    decoration: BoxDecoration(
      color: statusColor.withOpacity(0.2),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: statusColor, width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          status.toLowerCase() == 'available' ? Icons.check_circle : Icons.warning,
          color: statusColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          status,
          style: textTheme.titleMedium?.copyWith(
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.bold,
            color: statusColor,
          ),
        ),
      ],
    ),
  );
}


  Widget _buildAttendanceCard(
    double screenWidth,
    double screenHeight,
    Color primaryColor,
    Color onPrimaryColor,
    Color secondaryColor,
    WidgetRef ref,
  ) {
    // Get the current date in DD/MM format
    final String currentDate = DateFormat('dd/MM').format(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Combine "Attendance" and the date
        Text(
          'Attendance ($currentDate)', // Combine Attendance and date
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Text color for contrast
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cleanerName ?? "Cleaner",
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  fontWeight: FontWeight.bold,
                  color: onPrimaryColor,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await _submitAttendanceWithPopup(
                        context,
                        ref,
                        'present',
                        'Your attendance has been marked as Present.',
                      );
                    },
                    child: _buildAttendanceIcon(Icons.check, Colors.green, secondaryColor, screenWidth),
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  GestureDetector(
                    onTap: () async {
                      await _submitAttendanceWithPopup(
                        context,
                        ref,
                        'absent',
                        'Your attendance has been marked as Absent.',
                      );
                    },
                    child: _buildAttendanceIcon(Icons.close, Colors.red, secondaryColor, screenWidth),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }


Future<void> _submitAttendanceWithPopup(
  BuildContext context,
  WidgetRef ref,
  String status,
  String message,
) async {
  try {
    await ref.read(attendanceProvider.notifier).handleSubmitAttendance(status);

    // Check if the widget is still mounted before showing the dialog
    if (mounted) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('Attendance Submitted'),
              content: Text(message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  } catch (e) {
    // Check mounted before using the context
    if (mounted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit attendance: $e'),
          ),
        );
      }
    }
  }
}

  Widget _buildAttendanceIcon(IconData icon, Color iconColor, Color backgroundColor, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.02),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: screenWidth * 0.05),
    );
  }
}

Widget _buildTaskCard(
  BuildContext context,
  WidgetRef ref,
  String? title,
  String? subtitle,
  String? date, // Allow date to be nullable
) {
  final primaryColor = Theme.of(context).colorScheme.primary;
  final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
  final screenWidth = MediaQuery.of(context).size.width;

  // Default values if no task details are provided
  final displayTitle = title?.isNotEmpty == true ? title! : 'No assigned tasks yet.';
  final displaySubtitle = subtitle?.isNotEmpty == true ? subtitle! : '';
  final displayDate = date?.isNotEmpty == true ? _formatDate(date!) : '';

  final bool isFallback = title?.isEmpty != false; // True if title is null or empty

  return GestureDetector(
    onTap: () {
      // Update the index to the Tasks page (1)
      ref.read(currentIndexProvider.notifier).state = 1;
    },
    child: SizedBox(
      width: screenWidth, // Ensure the card takes full width
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor, // Use primary color for the card background
          borderRadius: BorderRadius.circular(12),
        ),
        child: isFallback
            ? Center(
                child: Text(
                  displayTitle, // Fallback message
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for fallback
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    displayTitle, // Default title or fallback message
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: onPrimaryColor, // Normal onPrimaryColor for title
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (displaySubtitle.isNotEmpty) ...[
                    // Divider
                    Divider(
                      color: onPrimaryColor.withOpacity(0.5), // Faint line for separation
                      thickness: 1,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      displaySubtitle, // Default subtitle or empty
                      style: TextStyle(
                        fontSize: 14,
                        color: onPrimaryColor, // Normal onPrimaryColor for subtitle
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Date
                  Text(
                    displayDate, // Formatted date or empty
                    style: TextStyle(
                      fontSize: 12,
                      color: onPrimaryColor, // Normal onPrimaryColor for date
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}

  // Helper function to format date
  String _formatDate(String? rawDate) {
    if (rawDate == null) return 'N/A';
    try {
      final parsedDate = DateTime.parse(rawDate); // Parse raw date string
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Format to DD/MM/YYYY
    } catch (e) {
      return 'Invalid Date'; // Fallback in case of error
    }
  }

