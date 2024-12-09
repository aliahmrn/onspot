import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../providers/search_page_provider.dart';

class CleanerDetailPage extends ConsumerWidget {
  final String cleanerId; // Cleaner ID to fetch details

  const CleanerDetailPage({
    super.key,
    required this.cleanerId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Fetch cleaner details using Riverpod
    final cleanerDetailAsync = ref.watch(cleanerDetailProvider(cleanerId));

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Cleaner’s Details",
          style: textTheme.titleLarge?.copyWith(
            fontSize: screenWidth * 0.05,
            color: onPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: cleanerDetailAsync.when(
        loading: () => Stack(
          children: [
            // Top blue section
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 180,
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
            ),
            // Bottom white section
            Positioned(
              top: 160,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(), // Loading spinner
                ),
              ),
            ),
          ],
        ),

        error: (error, _) => Center(
          child: Text(
            'Error loading cleaner details: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (cleanerDetails) {
          // Extract cleaner details dynamically
          final String cleanerName = cleanerDetails['cleaner_name'] ?? 'Unknown';
          final String cleanerStatus = cleanerDetails['status'] ?? 'Unavailable';
          final String profilePic = cleanerDetails['profile_pic'] ?? '';
          final String cleanerPhoneNo = cleanerDetails['cleaner_phoneNo'] ?? 'N/A';
          final String building = cleanerDetails['building'] ?? 'N/A';

          // Determine status color based on cleaner status
          final Color statusColor = cleanerStatus.toLowerCase() == 'available'
              ? Colors.green
              : Colors.red;

          return Stack(
            children: [
              // Top section with CircleAvatar and rounded corners
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 180,
                child: Container(
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
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
              // Main content section
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
                    children: [
                      const SizedBox(height: 10),
                      // Status badge
                      _buildStatusBadge(cleanerStatus, statusColor, textTheme, screenWidth),
                      const SizedBox(height: 20),
                      // Cleaner details card
                      Card(
                        color: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(
                                Icons.person,
                                "Name",
                                cleanerName,
                                onPrimaryColor,
                                textTheme,
                                screenWidth,
                              ),
                              const Divider(color: Colors.white54, height: 30),
                              _buildDetailRow(
                                Icons.phone,
                                "Contact",
                                cleanerPhoneNo,
                                onPrimaryColor,
                                textTheme,
                                screenWidth,
                              ),
                              const Divider(color: Colors.white54, height: 30),
                              _buildDetailRow(
                                Icons.location_city,
                                "Building",
                                building,
                                onPrimaryColor,
                                textTheme,
                                screenWidth,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor, TextTheme textTheme, double screenWidth) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.titleMedium?.copyWith(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildStatusBadge(String status, Color statusColor, TextTheme textTheme, double screenWidth) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        status,
        style: textTheme.titleMedium?.copyWith(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }
}
