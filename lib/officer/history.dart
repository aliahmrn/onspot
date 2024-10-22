import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting
import 'package:onspot_officer/service/history_service.dart'; // Import the service file
import 'navbar.dart'; // Import the reusable OfficerNavBar

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<dynamic> historyData = [];  // This will hold the complaint history data
  bool hasFetchedData = false;     // This will track if the data has been fetched

  @override
  void initState() {
    super.initState();
    _loadComplaintHistory();  // Call the method to load the data
  }

  // Function to load complaint history using the service
  Future<void> _loadComplaintHistory() async {
    try {
      List<dynamic> data = await fetchComplaintHistory();
      setState(() {
        historyData = data;
        hasFetchedData = true;  // Set to true once data is fetched
      });
    } catch (e) {
      setState(() {
        hasFetchedData = true;  // Also set to true if an error occurs
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints: $e')),
      );
    }
  }

  // Function to format time to AM/PM
  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '';  // Return empty if time is null or invalid
    }
    try {
      // Assuming your time is in 24-hour format (e.g., "14:30:00")
      final time = DateFormat('HH:mm:ss').parse(timeString);
      return DateFormat('hh:mm a').format(time); // Convert to 12-hour format with AM/PM
    } catch (e) {
      return '';  // Return empty if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFEF7FF), // Change AppBar color to #FEF7FF
        elevation: 0,
        automaticallyImplyLeading: false, // This removes the back button
        title: const Center(
          // Center the title text
          child: Text(
            'History',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasFetchedData
            ? (historyData.isEmpty
                ? const Center(child: Text('No complaints found')) // Show if no data after fetch
                : ListView.builder(
                    itemCount: historyData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFC3D2D7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns items on the left and right
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: 24,
                                          color: Colors.black,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Complaint sent!',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Display the complaint time in AM/PM format on the right side
                                    Text(
                                      formatTime(historyData[index]['comp_time']), // Format the time
                                      style: const TextStyle(
                                        color: Colors.black45,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  historyData[index]['comp_desc'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  historyData[index]['comp_date'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.black45,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ))
            : Container(), // Display nothing while fetching data
      ),
      bottomNavigationBar: const OfficerNavBar(currentIndex: 2),
    );
  }
}
