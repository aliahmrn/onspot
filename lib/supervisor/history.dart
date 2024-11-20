import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../service/complaints_service.dart';
import 'history_details.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final Logger logger = Logger();
  late Future<List<Map<String, dynamic>>> _assignedTasksHistory;

  @override
  void initState() {
    super.initState();
    _assignedTasksHistory = ComplaintsService().fetchAssignedTasksHistory();
  }

  Future<void> _refreshHistory() async {
    setState(() {
      _assignedTasksHistory = ComplaintsService().fetchAssignedTasksHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).primaryColor;
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
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: Container(
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(screenWidth * 0.06),
            topRight: Radius.circular(screenWidth * 0.06),
          ),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _assignedTasksHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Keep the empty state simple as requested
              return const Center(
                child: Text(
                  'No assigned complaints history.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final compDate = task['comp_date'] ?? 'No Date';
                final description = task['comp_desc'] ?? 'No Description';
                final noOfCleaners = task['no_of_cleaners'] ?? '0';
                final status = task['comp_status'] ?? 'Unknown';

                // Determine the color based on status
                Color statusColor;
                if (status.toLowerCase() == 'completed') {
                  statusColor = Colors.green;
                } else if (status.toLowerCase() == 'ongoing') {
                  statusColor = Colors.blue;
                } else if (status.toLowerCase() == 'pending') {
                  statusColor = Colors.orange;
                } else {
                  statusColor = Colors.red;
                }

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    onTap: () async {
                      logger.i("Selected Complaint ID: ${task['id']}");
                      final result = await Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => TaskDetailsPage(complaintId: task['id'].toString()),
                          transitionDuration: Duration.zero, // Disables the animation
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                      if (result == true) {
                        _refreshHistory();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                        border: Border.all(
                          color: statusColor.withOpacity(0.5),
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
                          // Complaint Assigned Header Row
                          Row(
                            children: [
                              Icon(Icons.access_time, color: onPrimaryColor.withOpacity(0.7), size: screenWidth * 0.05),
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
                                compDate,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: onPrimaryColor.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24),
                          SizedBox(height: screenHeight * 0.005),

                          // Complaint Description
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: onPrimaryColor.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.005),

                          // Number of Cleaners
                          Row(
                            children: [
                              Icon(Icons.people, size: screenWidth * 0.04, color: onPrimaryColor.withOpacity(0.7)),
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
                          SizedBox(height: screenHeight * 0.015),

                          // Status Badge
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.006,
                                horizontal: screenWidth * 0.04,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
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
      ),
    );
  }
}
