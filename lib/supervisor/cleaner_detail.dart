import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package

class CleanerDetailPage extends StatelessWidget {
  final String cleanerName; // Cleaner name to display
  final String cleanerStatus; // Status of the cleaner
  final String profilePic; // Profile picture in base64
  final String cleanerPhoneNo; // Phone number of the cleaner
  final String building; // Building information


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
      body: Center( // Center the body content
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
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              children: [
                // Cleaner Profile Picture
                CircleAvatar(
                  radius: 50, // Avatar size
                  backgroundColor: Colors.grey[300], // Background color for placeholder
                  backgroundImage: profilePic.isNotEmpty
                      ? MemoryImage(base64Decode(profilePic))
                      : null,
                  child: profilePic.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white) // Default icon
                      : null,
                ),
                const SizedBox(height: 20),
                // Cleaner Name
                Text(
                  cleanerName,
                  style: GoogleFonts.lato( // Use Lato font for the cleaner name
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 10),
                // Cleaner Status
                Text(
                  'Status: $cleanerStatus',
                  style: GoogleFonts.openSans( // Use Open Sans font for status
                    fontSize: 16, 
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 20),
                // Cleaner Phone Number
                Text(
                  'Contact: $cleanerPhoneNo',
                  style: GoogleFonts.openSans( // Use Open Sans font for contact info
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center, // Center the text
                ),
                const SizedBox(height: 20),
                // Cleaner Building
                Text(
                  'Building: $building',
                  style: GoogleFonts.openSans( // Use Open Sans font for building info
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center, // Center the text
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
