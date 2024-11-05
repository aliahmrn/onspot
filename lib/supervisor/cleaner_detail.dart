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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine status color based on cleanerStatus
    final Color statusColor = cleanerStatus.toLowerCase() == 'available'
        ? Colors.green
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          "Cleaner’s Details",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Top blue section with CircleAvatar only
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: Container(
              color: primaryColor,
              child: Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profilePic.isNotEmpty
                      ? MemoryImage(base64Decode(profilePic))
                      : null,
                  child: profilePic.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ),
          // White rounded section for details with status badge at the top
          Positioned(
            top: 160,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  // Status badge at the top of the white section
                  _buildStatusBadge(cleanerStatus, statusColor, screenWidth),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildInfoRow('Name:', cleanerName, screenWidth),
                          const SizedBox(height: 20),
                          _buildInfoRow('Contact:', cleanerPhoneNo, screenWidth),
                          const SizedBox(height: 20),
                          _buildInfoRow('Building:', building, screenWidth),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: screenWidth * 0.04, // Matching font size
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: GoogleFonts.openSans(
              fontSize: screenWidth * 0.04, // Matching font size
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status, Color statusColor, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.openSans(
          fontSize: screenWidth * 0.04, // Matching font size
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
