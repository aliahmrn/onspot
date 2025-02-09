import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/complaints_provider.dart';
import 'history_details.dart';
import 'package:logger/logger.dart'; 

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String selectedCategory = ''; // Default to no filter (all data)
  String selectedMonth = ''; // Default to no month filter
  final Logger logger = Logger();

  String _formatAssignedDate(String? assignedDate) {
  if (assignedDate == null || assignedDate.isEmpty || assignedDate == 'Tiada Tarikh') {
    return 'Tiada tarikh';
  }

  try {
    logger.i('Parsing assigned_date: $assignedDate'); // Debug log
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(assignedDate);
    return DateFormat('dd/MM/yyyy').format(parsedDate);
   } catch (e) {
    logger.e('Error parsing assigned_date: $e');
    return 'Tarikh tidak sah'; // Return fallback text if parsing fails
   }
 }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    final filters = {
      'category': selectedCategory.isEmpty ? null : selectedCategory, // Use null if no category selected
      'month': selectedMonth.isEmpty ? null : selectedMonth,         // Use null if no month selected
    };

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Rekod',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            color: primaryColor,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
            child: Center(
              child: Container(
                width: screenWidth * 0.6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  value: selectedMonth.isNotEmpty ? selectedMonth.split('-')[1] : null, // Only use the month part (e.g., "01")
                  hint: Text(
                    'Pilih Bulan',
                    style: TextStyle(color: Colors.black),
                  ),
                  items: List.generate(12, (index) {
                    final monthValue = (index + 1).toString().padLeft(2, '0'); // Ensures "01", "02", etc.
                    final monthName = DateFormat('MMMM').format(DateTime(0, index + 1));
                    return DropdownMenuItem(
                      value: monthValue, // Set value to "01", "02", etc.
                      child: Text(
                        monthName,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      final currentYear = DateTime.now().year; // Dynamically fetch the year
                      setState(() {
                        selectedMonth = '$currentYear-$value'; // Store as "YYYY-MM"
                      });

                      // Invalidate the provider with updated filters
                      ref.invalidate(historyProvider({
                        'category': selectedCategory.isEmpty ? null : selectedCategory,
                        'month': selectedMonth,
                      }));
                    }
                  },
                  isExpanded: true,
                  dropdownColor: Colors.grey[300],
                  style: TextStyle(color: Colors.black),
                  underline: SizedBox(),
                  itemHeight: 50.0, // Set default height
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
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
                      children: [
                        const SizedBox(height: 10),
                        DefaultTabController(
                          length: 3,
                          initialIndex: selectedCategory == ''
                              ? 0
                              : (selectedCategory == 'ongoing' ? 1 : 2),
                          child: SizedBox(
                            height: screenHeight * 0.05,
                            child: TabBar(
                              onTap: (index) {
                                String newCategory = '';
                                if (index == 1) {
                                  newCategory = 'ongoing';
                                } else if (index == 2) {
                                  newCategory = 'completed';
                                }

                                if (newCategory != selectedCategory) {
                                  setState(() {
                                    selectedCategory = newCategory;
                                  });
                                  // Invalidate the provider with updated filters
                                  ref.invalidate(historyProvider({
                                    'category': selectedCategory.isEmpty ? null : selectedCategory,
                                    'month': selectedMonth.isEmpty ? null : selectedMonth,
                                  }));
                                }
                              },
                              tabs: [
                                Tab(
                                  icon: Icon(
                                    Icons.list,
                                    color: selectedCategory == '' ? primaryColor : Colors.grey,
                                    size: screenWidth * 0.045, // Slightly smaller icon
                                  ),
                                  child: Text(
                                    'Semua',
                                    style: TextStyle(
                                      color: selectedCategory == '' ? primaryColor : Colors.grey,
                                      fontSize: screenWidth * 0.039, // Smaller font size
                                    ),
                                  ),
                                ),
                                Tab(
                                  icon: Icon(
                                    Icons.access_time,
                                    color: selectedCategory == 'ongoing' ? primaryColor : Colors.grey,
                                    size: screenWidth * 0.045, // Slightly smaller icon
                                  ),
                                  child: Text(
                                    'Berjalan',
                                    style: TextStyle(
                                      color: selectedCategory == 'ongoing' ? primaryColor : Colors.grey,
                                      fontSize: screenWidth * 0.039, // Smaller font size
                                    ),
                                  ),
                                ),
                                Tab(
                                  icon: Icon(
                                    Icons.check_circle,
                                    color: selectedCategory == 'completed' ? primaryColor : Colors.grey,
                                    size: screenWidth * 0.045, // Slightly smaller icon
                                  ),
                                  child: Text(
                                    'Selesai',
                                    style: TextStyle(
                                      color: selectedCategory == 'completed' ? primaryColor : Colors.grey,
                                      fontSize: screenWidth * 0.039, // Smaller font size
                                    ),
                                  ),
                                ),
                              ],
                              indicatorColor: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Consumer(builder: (context, ref, _) {
                          logger.i('Rebuilding Consumer widget...');
                          final historyAsync = ref.watch(historyProvider(filters));
                            return RefreshIndicator(
                              onRefresh: () async {
                                try {
                                  logger.i('Refreshing history with filters: $filters');
                                  final refreshedHistory = await ref.refresh(historyProvider(filters).future);
                                  logger.i('Refreshed history data: $refreshedHistory');
                                } catch (e) {
                                  logger.i('Error refreshing history: $e');
                                }
                              },
                              child: historyAsync.when(
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (error, _) => Center(child: Text('Error: $error')),
                                data: (tasks) {
                                  logger.i('History data in UI: $tasks'); // Debug log
                                  if (tasks.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Tiada rekod tersedia.',
                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                      ),
                                    );
                                  }

                                     // Debug each task
                                      for (var task in tasks) {
                                        logger.i('Rendering task: $task');
                                      }

                                  return ListView.builder(
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = tasks[index];
                                      logger.i('Rendering task: $task'); // Debug log

                                      // Access `comp_date` and `comp_desc` directly from the JSON
                                      final assignedDate = task['assigned_date'] ?? 'Tiada Tarikh'; // Extract comp_date
                                      final description = task['comp_desc'] ?? 'Tiada Penerangan'; // Extract comp_desc
                                      final noOfCleaners = task['no_of_cleaners'] ?? '0';


                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                          onTap: () {
                                            final complaintId = task['id'].toString(); // ✅ Ensure it's 'id', NOT 'complaint_id'
                                            logger.i('Navigating with complaint ID: $complaintId');
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) =>
                                                    TaskDetailsPage(
                                                    complaintId: complaintId.toString(),
                                                ),
                                                transitionDuration: Duration.zero,
                                                reverseTransitionDuration: Duration.zero,
                                              ),
                                            );
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                              border: Border.all(
                                                color: Colors.grey.withOpacity(0.5),
                                                width: 1.2,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  spreadRadius: screenWidth * 0.003,
                                                  blurRadius: screenWidth * 0.02,
                                                  offset: Offset(0, screenHeight * 0.003),
                                                ),
                                              ],
                                            ),
                                            padding: EdgeInsets.all(screenWidth * 0.04),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.access_time,
                                                      color: onPrimaryColor.withOpacity(0.7),
                                                      size: screenWidth * 0.05,
                                                    ),
                                                    SizedBox(width: screenWidth * 0.02),
                                                    Text(
                                                      'Aduan telah ditugaskan',
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.045,
                                                        fontWeight: FontWeight.bold,
                                                        color: onPrimaryColor,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      _formatAssignedDate(assignedDate), // ✅ Use formatted function
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.035,
                                                        color: onPrimaryColor.withOpacity(0.6),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(color: Colors.white24),
                                                SizedBox(height: screenHeight * 0.005),

                                                Text(
                                                  description,
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.04,
                                                    color: onPrimaryColor.withOpacity(0.9),
                                                  ),
                                                ),
                                                SizedBox(height: screenHeight * 0.005),

                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.people,
                                                      size: screenWidth * 0.04,
                                                      color: onPrimaryColor.withOpacity(0.7),
                                                    ),
                                                    SizedBox(width: screenWidth * 0.02),
                                                    Text(
                                                      '$noOfCleaners pembersih ditugaskan',
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.035,
                                                        color: onPrimaryColor.withOpacity(0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
