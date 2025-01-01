import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/complaints_provider.dart';
import 'history_details.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String selectedCategory = ''; // Default to no filter (all data)
  String selectedMonth = ''; // Default to no month filter

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'History',
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
                  value: selectedMonth.isEmpty ? null : selectedMonth, // Ensure value matches or is null
                  hint: Text(
                    'Select Month',
                    style: TextStyle(color: Colors.black),
                  ),
                  items: List.generate(12, (index) {
                    final month = DateFormat('MMMM').format(DateTime(0, index + 1));
                    return DropdownMenuItem(
                      value: (index + 1).toString(), // Unique value (1-12)
                      child: Text(
                        month,
                        style: TextStyle(color: Colors.black), // Ensure visibility
                      ),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      print('Selected Month: $value'); // Debug log
                      setState(() {
                        selectedMonth = value; // Update selectedMonth
                        ref.invalidate(historyProvider('$selectedCategory&month=$selectedMonth'));
                      });
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
                            height: screenHeight * 0.05, // Reduce the height of the TabBar
                            child: TabBar(
                              onTap: (index) {
                                setState(() {
                                  if (index == 0) {
                                    selectedCategory = ''; // No filter
                                  } else if (index == 1) {
                                    selectedCategory = 'ongoing';
                                  } else {
                                    selectedCategory = 'completed';
                                  }
                                  ref.invalidate(historyProvider('$selectedCategory&month=$selectedMonth'));
                                });
                              },
                              tabs: [
                                Tab(
                                  icon: Icon(
                                    Icons.list,
                                    color: selectedCategory == '' ? primaryColor : Colors.grey,
                                    size: screenWidth * 0.045, // Slightly smaller icon
                                  ),
                                  child: Text(
                                    'All',
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
                                    'Ongoing',
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
                                    'Completed',
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
                            final historyAsync = ref.watch(historyProvider('$selectedCategory&month=$selectedMonth'));

                            return RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(historyProvider('$selectedCategory&month=$selectedMonth'));
                              },
                              child: historyAsync.when(
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (error, _) => Center(child: Text('Error: $error')),
                                data: (tasks) {
                                  if (tasks.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'No complaints history available.',
                                        style: TextStyle(fontSize: 16, color: Colors.grey),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    itemCount: tasks.length,
                                    itemBuilder: (context, index) {
                                      final task = tasks[index];
                                      final compDate = task['comp_date'] ?? 'No Date';
                                      final description = task['comp_desc'] ?? 'No Description';
                                      final noOfCleaners = task['no_of_cleaners'] ?? '0';

                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              PageRouteBuilder(
                                                pageBuilder: (context, animation, secondaryAnimation) =>
                                                    TaskDetailsPage(
                                                  complaintId: task['id'].toString(),
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
                                                      'Complaint assigned',
                                                      style: TextStyle(
                                                        fontSize: screenWidth * 0.045,
                                                        fontWeight: FontWeight.bold,
                                                        color: onPrimaryColor,
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      DateFormat('dd/MM/yyyy').format(DateTime.parse(compDate)),
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
                                                      '$noOfCleaners Cleaners Assigned',
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
