import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../cleaner/main_navigator.dart'; // For currentIndexProvider
import '../service/task_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart'; // Import the attendance provider
import 'package:logger/logger.dart';
import '../providers/profile_provider.dart';

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
        cleanerName = prefs.getString('name') ?? 'Pembersih'; // Default fallback
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        cleanerName = 'Pembersih'; // Fallback in case of error
      });
    }
  }


Future<void> _fetchLatestTask() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cleanerId = prefs.getString('cleanerId');

    if (cleanerId == null) {
      setState(() {
        error = 'Cleaner ID is missing.';
        isLoading = false;
      });
      _logger.e('Error: Cleaner ID is missing.');
      return;
    }

    final task = await taskService.getLatestTask(int.parse(cleanerId));

    final bool isAcknowledged = task?['is_notified'] == 1 || task?['is_notified'] == true;

    setState(() {
      latestTask = task;
      isLoading = false;

      // ✅ Add 'isAcknowledged' flag to latestTask
      if (latestTask != null) {
        latestTask!['isAcknowledged'] = isAcknowledged;
      }
    });
  } catch (e) {
    setState(() {
      error = 'Failed to load the latest task: $e';
      isLoading = false;
    });
    _logger.e('Error fetching the latest task: $e');
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

Future<void> _refresh() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final cleanerId = prefs.getString('cleanerId');

    if (cleanerId != null) {
      await Future.wait<void>([
        _fetchLatestTask(), 
        _fetchCleanerName(),
        ref.refresh(profileProvider.future),
        ref.read(attendanceProvider.notifier).checkAttendance(int.parse(cleanerId)), // ✅ Refresh cleaner status
      ]);
    } else {
      _logger.e("Cleaner ID is null, cannot refresh data.");
    }
  } catch (e) {
    _logger.e("Error during refresh: $e");
  }
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
      data: (attendanceState) => attendanceState.status?.toLowerCase() ?? 'unavailable', // Lowercase fallback
      orElse: () => 'unavailable',
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
            toolbarHeight: 70,
            title: Text(
              'Laman Utama',
              style: TextStyle(
                color: onPrimaryColor,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: _refresh,
            child: Stack( // ✅ Wrap everything inside a Stack
              children: [
                Container(color: primaryColor), // ✅ Background color
                Positioned(
                  top: screenHeight * 0.012,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: screenHeight * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(screenWidth * 0.06),
                        topRight: Radius.circular(screenWidth * 0.06),
                      ),
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    child: ListView( // ✅ Replace Column with ListView
                      physics: const AlwaysScrollableScrollPhysics(), 
                      children: [
                      // Welcome and Bell Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Selamat Datang, ',
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.normal, // Normal font weight for "Welcome, "
                                color: onSecondaryColor,
                              ),
                              children: [
                                TextSpan(
                                  text: attendanceState.cleanerName ?? 'Cleaner', // Cleaner name
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Bold font weight for the name
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              SizedBox(width: screenWidth * 0.025),
                              GestureDetector(
                                onTap: () => _handleProfileTap(ref),
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final profileAsyncValue = ref.watch(profileProvider);

                                    return profileAsyncValue.when(
                                      data: (cleanerInfo) => CircleAvatar(
                                        radius: screenWidth * 0.05,
                                        backgroundColor: Colors.white,
                                        backgroundImage: cleanerInfo['profile_pic'] != null
                                            ? NetworkImage(cleanerInfo['profile_pic'])
                                            : null,
                                        child: cleanerInfo['profile_pic'] == null
                                            ? Icon(
                                                Icons.person,
                                                size: screenWidth * 0.06,
                                                color: Colors.grey[600],
                                              )
                                            : null,
                                      ),
                                      loading: () => CircleAvatar(
                                        radius: screenWidth * 0.05,
                                        backgroundColor: Colors.grey,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(primaryColor),
                                        ),
                                      ),
                                      error: (error, stackTrace) => CircleAvatar(
                                        radius: screenWidth * 0.05,
                                        backgroundColor: Colors.grey[300],
                                        child: Icon(
                                          Icons.error,
                                          size: screenWidth * 0.06,
                                          color: Colors.red,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.01),

                        // Cleaner Status Section
                        Align(
                          alignment: Alignment.centerLeft, // ✅ Moves it to the left
                          child: IntrinsicWidth( // ✅ Keeps it compact
                            child: _buildStatusBadge(
                              status, 
                              statusColor, 
                              Theme.of(context).textTheme, 
                              screenWidth,
                            ),
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
                          status
                        ),

                      SizedBox(height: screenHeight * 0.02),

                      // Task Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tugasan',
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
                                    'Lihat Semua',
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
                      error != null
                          ? Center(child: Text(error!))
                          : latestTask != null && latestTask!.isNotEmpty
                              ? _buildTaskCard(
                                  context,
                                  ref,
                                  latestTask?['comp_desc'],
                                  latestTask?['comp_location'],
                                  latestTask?['assigned_date'],
                                  latestTask?['isAcknowledged'] ?? false,
                                )
                              : Center(
                                  child: Text(
                                    'Tiada tugasan terkini.', // ✅ Show message when no task exists
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    child: Text(
      status == 'available' ? 'Sedia' : 'Tidak Sedia', // Translate status to Malay
      style: textTheme.titleMedium?.copyWith(
        fontSize: screenWidth * 0.04,
        fontWeight: FontWeight.bold,
        color: statusColor,
      ),
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
  String status
) {
  // Get the current date in DD/MM format
  final String currentDate = DateFormat('dd/MM').format(DateTime.now());

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Combine "Attendance" and the date
      Text(
        'Kehadiran ($currentDate)', // Combine Attendance and date
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cleanerName ?? "Pembersih",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: onPrimaryColor,
                  ),
                ),
                Text(
                  status == 'available' ? 'Sedia' : 'Tidak Sedia', // Translated status
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.normal,
                    color: onPrimaryColor,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await _submitAttendanceWithPopup(
                      context,
                      ref,
                      'present',
                      'Kehadiran anda telah direkodkan sebagai Hadir.',
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
                      'Kehadiran anda telah direkodkan sebagai Tidak Hadir.',
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
              title: const Text('Kehadiran Berjaya Direkodkan.'),
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
            content: Text('Gagal Rekod Kehadiran: $e'),
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
  String? date,
  bool isAcknowledged, // ✅ New parameter to track acknowledgment status
) {
  final primaryColor = Theme.of(context).colorScheme.primary;
  final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
  final screenWidth = MediaQuery.of(context).size.width;

  // Default values if no task details are provided
  final displayTitle = title?.isNotEmpty == true ? title! : 'Tiada tugasan terkini.';
  final displaySubtitle = subtitle?.isNotEmpty == true ? subtitle! : '';
  final displayDate = date?.isNotEmpty == true ? _formatDate(date!) : '';

  final bool isFallback = title?.isEmpty != false; // True if title is null or empty

  return GestureDetector(
    onTap: () {
      ref.read(currentIndexProvider.notifier).state = 1; // ✅ Navigate to Task Page
    },
    child: SizedBox(
      width: screenWidth, // Ensure the card takes full width
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor, // ✅ Use primary color for the card background
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
                  // ✅ Title and "Sedang Dijalankan" aligned on the same row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          displayTitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: onPrimaryColor,
                          ),
                        ),
                      ),
                      if (isAcknowledged) // ✅ Show "Sedang Dijalankan" if acknowledged
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2), // Light green background
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Sedang Dijalankan",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange, // Green text
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (displaySubtitle.isNotEmpty) ...[
                    // Divider
                    Divider(
                      color: onPrimaryColor.withOpacity(0.5), // ✅ Faint line for separation
                      thickness: 1,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      displaySubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: onPrimaryColor, // Normal onPrimaryColor for subtitle
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Date
                  Text(
                    displayDate,
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
      return 'Tarikh Tidak Betul'; // Fallback in case of error
    }
  }

