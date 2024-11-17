import 'package:flutter/material.dart';
import 'package:onspot_officer/service/complaintdetails_service.dart'; 
import 'package:onspot_officer/widget/cleanicons.dart'; 
import 'package:onspot_officer/widget/date.dart';
import 'package:onspot_officer/widget/localhost.dart';

class ComplaintDetailsPage extends StatefulWidget {
  final int complaintId;

  const ComplaintDetailsPage({super.key, required this.complaintId});

  @override
  ComplaintDetailsPageState createState() => ComplaintDetailsPageState();
}

class ComplaintDetailsPageState extends State<ComplaintDetailsPage> {
  Map<String, dynamic>? complaintDetails;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComplaintDetails();
  }

  // Function to load complaint details
  Future<void> _loadComplaintDetails() async {
    try {
      final details = await fetchComplaintDetails(widget.complaintId);
      setState(() {
        complaintDetails = details;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load complaint details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: Material(
          elevation: 0,
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'Complaint Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show a loading indicator while fetching data
          : complaintDetails != null
              ? Stack(
                  children: [
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Image',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          //real
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Location',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    complaintDetails!['comp_location'] ?? 'Unknown',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Date',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    formatDate(complaintDetails!['comp_date']),
                                    style: const TextStyle(fontSize: 16),
                                  ),

                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 200,
                      left: 30,
                      right: 30,
                      child: Container(
                        width: 400,
                        height: 500,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF4C7D90),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 110,
                      left: 30,
                      right: 30,
                      child: Container(
                        width: 410,
                        height: 250,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: complaintDetails!['comp_image'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Image.network(
                                  resolveUrl(complaintDetails!['comp_image']), // Apply the URL replacement here
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(child: Text('Image failed to load')); // Fallback if image fails
                                  },
                                ),
                              )
                            : const Center(child: Text('No image available')), // Display text if there is no image URL
                      ),
                    ),
                    Positioned(
                      top: 380,
                      left: 30,
                      right: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Container(
                              width: 330,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(7),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4.0,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                complaintDetails!['comp_desc'] ?? 'No description available.',
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Task included',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Container(
                              width: 330,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 240, 240, 240),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: const [
                                  Column(
                                    children: [
                                      MopIcon(size: 32),
                                      SizedBox(height: 5),
                                      Text('Cleaning'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      WipeIcon(size: 32),
                                      SizedBox(height: 5),
                                      Text('Wiping'),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      WindowIcon(size: 32),
                                      SizedBox(height: 5),
                                      Text('Organizing'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : const Center(child: Text('No details available')),
    );
  }
}
