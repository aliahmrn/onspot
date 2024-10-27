import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:onspot_officer/service/history_service.dart';
import 'navbar.dart';
import 'complaintdetails.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  HistoryPageState createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  List<dynamic> historyData = [];
  bool hasFetchedData = false;

  @override
  void initState() {
    super.initState();
    _loadComplaintHistory();
  }

  Future<void> _loadComplaintHistory() async {
    try {
      List<dynamic> data = await fetchComplaintHistory();
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        historyData = data;
        hasFetchedData = true;
      });
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        hasFetchedData = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaints: $e')),
      );
    }
  }

  String formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return '';
    }
    try {
      final time = DateFormat('HH:mm:ss').parse(timeString);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Center(
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
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: hasFetchedData
                  ? (historyData.isEmpty
                      ? const Center(child: Text('No complaints found'))
                      : ListView.builder(
                          itemCount: historyData.length,
                          itemBuilder: (context, index) {
                            final complaint = historyData[index];
                            final complaintId = complaint['id'];  // Extracting complaint ID

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Stack(
                                children: [
                                  Container(
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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                              Text(
                                                formatTime(complaint['comp_time']),
                                                style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            complaint['comp_desc'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            complaint['comp_date'] ?? '',
                                            style: const TextStyle(
                                              color: Colors.black45,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.arrow_forward, color: Colors.black),
                                      onPressed: () {
                                        // Pass the complaint ID to ComplaintDetailsPage
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ComplaintDetailsPage(complaintId: complaintId),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ))
                  : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const OfficerNavBar(currentIndex: 2),
    );
  }
}
