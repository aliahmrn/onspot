import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'assign_task.dart';
import '../service/complaints_service.dart';
import 'main_navigator.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  ComplaintPageState createState() => ComplaintPageState(); // Made public
}

class ComplaintPageState extends State<ComplaintPage> {
  final ComplaintsService complaintsService = ComplaintsService();

  Future<void> _refreshComplaints() async {
    setState(() {}); // Trigger a rebuild to fetch updated complaints
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const MainNavigator(),
                settings: RouteSettings(arguments: 0), // Indicate the home tab
              ),
              (route) => false,
            );
          },
        ),
        centerTitle: true,
        title: const Text(
          'Complaints',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: complaintsService.fetchComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No complaints yet.'));
          }

          final complaints = snapshot.data!;
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];
              final timeString = complaint['comp_time']!;
              final DateTime time = DateTime.parse('1970-01-01 $timeString');
              final String formattedTime = DateFormat('HH:mm').format(time);

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  color: const Color(0xFF92AEB9),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Complaint',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complaint['comp_desc']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Date: ${complaint['comp_date']!}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AssignTaskPage(complaintId: complaint['id'].toString()),
                                  ),
                                );
                                _refreshComplaints(); // Refresh the list after task assignment
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: const Text(
                                'Assign Complaint',
                                style: TextStyle(fontSize: 14),
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
  }
}
