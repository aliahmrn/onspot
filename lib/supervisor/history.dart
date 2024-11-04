import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../service/complaints_service.dart';
import 'history_details.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Logger logger = Logger(); // Initialize Logger

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ComplaintsService().fetchAssignedTasksHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No assigned tasks history.'));
          }

          final tasks = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
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
                  statusColor = Colors.red; // Default color for unknown statuses
                }

                return InkWell(
                  onTap: () {
                    logger.i("Selected Complaint ID: ${task['id']}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailsPage(complaintId: task['id'].toString()),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: Colors.grey[100],
                      elevation: 4,
                      shadowColor: Colors.black26,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.black54, size: 18),
                                const SizedBox(width: 10),
                                const Text(
                                  'Complaint assigned',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  compDate,
                                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$noOfCleaners Cleaners Assigned',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.2), // Dynamic color for badge background
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: statusColor, // Dynamic color for text
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
