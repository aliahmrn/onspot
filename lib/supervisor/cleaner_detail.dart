import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_page_provider.dart';
import 'package:intl/intl.dart';

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
          "Butiran Pembersih",
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
            'Ralat memuatkan butiran pembersih: $error',
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
          final List<dynamic> latestComplaints =
              cleanerDetails['latest_complaints'] ?? [];

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
                          ? NetworkImage(profilePic) // Use NetworkImage for URL
                          : const AssetImage('assets/images/default-profile.png') as ImageProvider,
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
                  child: SingleChildScrollView( // Added for scrollable content
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
                                  "Nama",
                                  cleanerName,
                                  onPrimaryColor,
                                  textTheme,
                                  screenWidth,
                                ),
                                const Divider(color: Colors.white54, height: 30),
                                _buildDetailRow(
                                  Icons.phone,
                                  "Nombor Telefon",
                                  cleanerPhoneNo,
                                  onPrimaryColor,
                                  textTheme,
                                  screenWidth,
                                ),
                                const Divider(color: Colors.white54, height: 30),
                                _buildDetailRow(
                                  Icons.location_city,
                                  "Bangunan",
                                  building,
                                  onPrimaryColor,
                                  textTheme,
                                  screenWidth,
                                ),
                                const Divider(color: Colors.white54, height: 30),
                              if (latestComplaints.isNotEmpty)
                                _buildTaskCard(
                                  latestComplaints[0],
                                  primaryColor, // Use the same color as the cleaner details card
                                  textTheme,
                                  screenWidth,
                                )
                              else
                                Center(
                                  child: Text(
                                    "Tiada aduan ditugaskan.",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color iconColor,
      TextTheme textTheme, double screenWidth) {
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

Widget _buildTaskCard(
    Map<String, dynamic> complaint, Color primaryColor, TextTheme textTheme, double screenWidth) {
  // Determine badge color based on complaint status
  String translateComplaintStatus(String status) {
  switch (status.toLowerCase()) {
    case 'ongoing':
      return 'Berjalan';
    case 'completed':
      return 'Selesai';
    case 'pending':
      return 'Tertangguh';
    default:
      return 'Status Tidak Diketahui';
  }
}

// Determine badge color based on complaint status
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'ongoing':
      return const Color.fromARGB(255, 94, 155, 204);
    case 'completed':
      return Colors.green;
    case 'pending':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}
  // Format the date
  String formatDate(String? date) {
    if (date == null || date.isEmpty) return "Tidak diketahui";
    try {
      final parsedDate = DateTime.parse(date); // Parse the date string
      return DateFormat('dd/MM/yyyy').format(parsedDate); // Format to DD/MM/YYYY
    } catch (e) {
      return "Tarikh tidak sah";
    }
  }

  return SizedBox(
    width: screenWidth * 0.9, // Set width to 90% of the screen
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white, // White background for the card
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Subtle shadow color
            blurRadius: 8, // Blur radius for shadow
            offset: const Offset(0, 4), // Offset for shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Aduan Ditugaskan",
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: screenWidth * 0.040,
                    fontWeight: FontWeight.bold,
                    color: primaryColor, // Use primary color for the font
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  decoration: BoxDecoration(
                    color: getStatusColor(complaint['comp_status']),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    translateComplaintStatus(complaint['comp_status'] ?? 'unknown'),
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.white, // Text color for the badge
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Penerangan: ${complaint['comp_desc']}",
              style: textTheme.bodyMedium?.copyWith(
                color: primaryColor, // Use primary color for text
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Lokasi: ${complaint['comp_location']}",
              style: textTheme.bodyMedium?.copyWith(
                color: primaryColor.withOpacity(0.7), // Slightly lighter primary color
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ditugaskan Oleh: ${complaint['assigned_by'] ?? 'Unknown'}", // Display supervisor name
              style: textTheme.bodyMedium?.copyWith(
                color: primaryColor.withOpacity(0.7), // Slightly lighter primary color
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tarikh: ${formatDate(complaint['comp_date'])}", // Format the date
              style: textTheme.bodyMedium?.copyWith(
                color: primaryColor.withOpacity(0.7), // Slightly lighter primary color
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildStatusBadge(String status, Color statusColor, TextTheme textTheme, double screenWidth) {
    
      final translatedStatus = status.toLowerCase() == 'available'
      ? 'Sedia'
      : status.toLowerCase() == 'unavailable'
          ? 'Tidak Sedia'
          : 'Status Tidak Diketahui';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Text(
        translatedStatus, // Use translated status
        style: textTheme.titleMedium?.copyWith(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }
}
