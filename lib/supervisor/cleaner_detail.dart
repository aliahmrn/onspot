import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

class CleanerDetailPage extends StatelessWidget {
  final String cleanerName;
  final String cleanerStatus;
  final String profilePic;
  final String cleanerPhoneNo;
  final String building;

  const CleanerDetailPage({
    super.key,
    required this.cleanerName,
    required this.cleanerStatus,
    required this.profilePic,
    required this.cleanerPhoneNo,
    required this.building,
  });

  static const Color pastelColor = Color(0xFF92AEB9);

  @override
  Widget build(BuildContext context) {
    // Determine status color based on cleanerStatus
    final Color statusColor = cleanerStatus.toLowerCase() == 'available'
        ? Colors.green
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cleaner’s Details",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold, 
          ),
        ),
        backgroundColor: const Color(0xFFFEF7FF),
      ),
      body: Center(
        child: Card(
          color: const Color.fromARGB(255, 224, 233, 236),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 500,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profilePic.isNotEmpty
                      ? MemoryImage(base64Decode(profilePic))
                      : null,
                  child: profilePic.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  cleanerName,
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Status Badge for cleaner's status
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2), // Light background color
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    cleanerStatus,
                    style: GoogleFonts.openSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor, // Text color based on status
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Contact: $cleanerPhoneNo',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Building: $building',
                  style: GoogleFonts.openSans(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
