import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'assign_task.dart';
import '../service/complaints_service.dart'; // Import the service

class ComplaintPage extends StatelessWidget {
  final ComplaintsService complaintsService = ComplaintsService(); // Create an instance of ComplaintsService

  ComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complaints',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Set the font weight to bold
            fontSize: 18, // Set the font size to 18
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: complaintsService.fetchComplaints(), // Fetch complaints
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While loading, show a loading spinner
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // If there's an error, display it
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If no data, display a message
            return Center(child: Text('No complaints found.'));
          }

          // Data is available; render the list of complaints
          final complaints = snapshot.data!;
          return ListView.builder(
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final complaint = complaints[index];

              // Parse the time string and format it
              final timeString = complaint['comp_time']!;
              final DateTime time = DateTime.parse('1970-01-01 $timeString'); // Use a fixed date to parse the time
              final String formattedTime = DateFormat('HH:mm').format(time); // Format to "HH:mm"

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
                        // New section for Complaint title and time
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
                            // Display formatted time on the right side of the complaint title
                            Text(
                              formattedTime, // Display the formatted time
                              style: const TextStyle(
                                fontSize: 14, // Change font size to 12
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Description of the complaint
                        Text(
                          complaint['comp_desc']!, // Updated to match your API response
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Date below the description
                        Text(
                          'Date: ${complaint['comp_date']!}', // Updated to match your API response
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // "Assign Task" button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AssignTaskPage(complaintId: complaint['id'].toString()),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Assign Task'),
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
