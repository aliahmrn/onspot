import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cleaner/main_navigator.dart'; // For currentIndexProvider
import '../widget/bell.dart';
import '../service/task_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart'; // Import the attendance provider

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
      setState(() {
        cleanerName = prefs.getString('name') ?? 'Cleaner'; // Default fallback
      });
    } catch (e) {
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
      return;
    }

    // Use the retrieved cleaner ID
    final tasks = await taskService.getCleanerTasks(int.parse(cleanerId));
    setState(() {
      latestTask = tasks != null && tasks.isNotEmpty ? tasks.first : null;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      error = 'Failed to load latest task: $e';
      isLoading = false;
    });
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
                              : latestTask != null
                                  ? _buildTaskCard(
                                      context,
                                      ref,
                                      latestTask!['comp_desc'] ?? 'No Description',
                                      latestTask!['comp_location'] ?? 'No Location',
                                      latestTask!['comp_date'] ?? 'No Date',
                                    )
                                  : Center(
                                      child: Text(
                                        'No recent tasks available.',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: onPrimaryColor,
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
                '${cleanerName ?? "Cleaner"}',
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Attendance Submitted'),
            content: Text(message),
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
      // Optionally handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit attendance: $e'),
        ),
      );
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
    String title,
    String subtitle,
    String? date, // Allow date to be nullable
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title, // Default title passed from the caller
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: onPrimaryColor, // Text color matches the card's contrast
                ),
              ),
              const SizedBox(height: 8),

              // Divider
              Divider(
                color: onPrimaryColor.withOpacity(0.5), // Faint line for separation
                thickness: 1,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                subtitle, // Default subtitle passed from the caller
                style: TextStyle(
                  fontSize: 14,
                  color: onPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),

              // Date
              Text(
                date != null ? _formatDate(date) : 'N/A', // Default to "N/A" if date is null
                style: TextStyle(
                  fontSize: 12,
                  color: onPrimaryColor,
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

