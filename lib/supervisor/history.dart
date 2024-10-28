import 'package:flutter/material.dart';
import '../service/complaints_service.dart';
import 'history_details.dart'; // Import the TaskDetailsPage

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Changed AppBar color
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold, // Make "History" bold
          ),
        ),
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: ComplaintsService().fetchAssignedTasksHistory(), // Fetch history data
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No assigned tasks history.'));
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

                return InkWell(
                  onTap: () {
                    print("Selected Complaint ID: ${task['id']}");
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
                        borderRadius: BorderRadius.circular(10),
                      ),
                      color: const Color(0xFF92AEB9),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, color: Colors.black),
                                const SizedBox(width: 10),
                                const Text(
                                  'Complaint assigned',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  compDate,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '$noOfCleaners Cleaners',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Status: $status', // Display the complaint status
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
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
