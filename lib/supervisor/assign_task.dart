import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/assign_task_provider.dart';
import '../providers/navigation_provider.dart'; // For navigation state
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'dart:convert';
import '../service/complaints_service.dart';

// Provider to manage the complaints list
final complaintListProvider = StateNotifierProvider<ComplaintListNotifier, List<Map<String, dynamic>>>((ref) {
  return ComplaintListNotifier();
});

// Notifier to handle complaints list
class ComplaintListNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ComplaintListNotifier() : super([]);

  final _complaintsService = ComplaintsService();

  // Method to refresh complaints list
  Future<void> refresh() async {
    try {
      final complaints = await _complaintsService.fetchComplaints();
      state = complaints;
    } catch (e) {
      // Handle errors (e.g., log them or show a message)
      state = [];
    }
  }
}

class AssignTaskPage extends ConsumerWidget {
  final String complaintId;

  const AssignTaskPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    // Listen for changes in assignTaskProvider
    ref.listen<AsyncValue<void>>(assignTaskProvider, (previous, next) {
      next.whenOrNull(
        data: (_) {
          // Show success dialog with an "OK" button
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Success'),
              content: const Text('Task assigned successfully.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    ref.read(complaintListProvider.notifier).refresh(); // Refresh complaints
                    ref.read(currentIndexProvider.notifier).state = 2; // Redirect to Complaints Page
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
        error: (error, _) {
          // Show error dialog
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to assign task: $error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Close the dialog
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      );
    });

    // Fetch complaint details using Riverpod
    final complaintDetailsAsync = ref.watch(complaintDetailsProvider(complaintId));
    final assignTaskState = ref.watch(assignTaskProvider);

    return Scaffold(
      backgroundColor: primaryColor, // Match primary background color
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Assign Complaint',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: secondaryColor, // Match the secondary color (white background)
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(screenWidth * 0.06), // Same rounded corner design
            topRight: Radius.circular(screenWidth * 0.06),
          ),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04), // Match the padding
        child: complaintDetailsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
          data: (complaintDetails) {
            final availableCleaners =
                List<Map<String, dynamic>>.from(complaintDetails['available_cleaners']);
            final formattedDate =
                DateFormat('dd/MM/yyyy').format(DateTime.parse(complaintDetails['comp_date']));
            final imageUrl = complaintDetails['comp_image_url'];

            // Button enable condition
            final bool isAssignButtonEnabled = availableCleaners.isNotEmpty;

            // UI with updated design
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Container(
                    width: double.infinity,
                    height: screenHeight * 0.25, // Dynamically adjust height
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                      image: imageUrl != null
                          ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                          : null,
                    ),
                    child: imageUrl == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                                const SizedBox(height: 10),
                                Text(
                                  'No Image Available',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                              ],
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 25),

                  // Complaint Details Section
                  _buildDetailRow(Icons.location_on, 'Location',
                      complaintDetails['comp_location'] ?? 'No Location'),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  _buildDetailRow(Icons.date_range, 'Date', formattedDate),
                  const Divider(color: Colors.grey, thickness: 0.5),
                  _buildDetailRow(Icons.description, 'Description',
                      complaintDetails['comp_desc'] ?? 'No Description'),
                  const SizedBox(height: 20),

                  // Number of Cleaners Section
                  _buildCleanersDropdownSection(
                    ref: ref,
                    availableCleaners: availableCleaners,
                    complaintId: complaintId,
                    primaryColor: primaryColor,
                    secondaryColor: secondaryColor,
                    isAssignButtonEnabled: isAssignButtonEnabled,
                  ),

                  const SizedBox(height: 30),

                  // Assign Button Section
                  Center(
                    child: ElevatedButton(
                      onPressed: isAssignButtonEnabled
                          ? () => _assignTask(ref, complaintId, availableCleaners)
                          : null, // Disable button if no cleaners are available
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                        backgroundColor: isAssignButtonEnabled ? primaryColor : Colors.grey, // Adjust color
                        foregroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: isAssignButtonEnabled ? 4 : 0, // No elevation when disabled
                        shadowColor: Colors.black.withOpacity(0.2),
                      ),
                      child: assignTaskState.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              isAssignButtonEnabled
                                  ? 'Assign Complaint' // Show default text if enabled
                                  : 'No Cleaner Available', // Show alternative text if disabled
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 16),
          Text(
            '$label: $value',
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanersDropdownSection({
    required WidgetRef ref,
    required List<Map<String, dynamic>> availableCleaners,
    required String complaintId,
    required Color primaryColor,
    required Color secondaryColor,
    required bool isAssignButtonEnabled,
  }) {
    final selectedNumOfCleaners = ref.watch(selectedNumOfCleanersProvider);
    final selectedCleaners = ref.watch(selectedCleanersProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Number of Cleaners',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 15),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedNumOfCleaners,
            hint: const Text('Select number'),
            onChanged: isAssignButtonEnabled
                ? (value) {
                    ref.read(selectedNumOfCleanersProvider.notifier).state = value;
                    int numCleaners = int.tryParse(value ?? '1') ?? 1;

                    final currentSelected = List<String?>.from(selectedCleaners);
                    if (numCleaners > currentSelected.length) {
                      currentSelected
                          .addAll(List<String?>.filled(numCleaners - currentSelected.length, null));
                    } else {
                      currentSelected.removeRange(numCleaners, currentSelected.length);
                    }
                    ref.read(selectedCleanersProvider.notifier).state = currentSelected;
                  }
                : null,
            items: List.generate(10, (index) => (index + 1).toString())
                .map((value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
          ),
          const SizedBox(height: 15),
          for (int i = 0; i < int.parse(selectedNumOfCleaners ?? '1'); i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCleaners.length > i ? selectedCleaners[i] : null,
                hint: const Text('Select cleaner'),
                onChanged: isAssignButtonEnabled
                    ? (newValue) {
                        if (newValue != 'No cleaner available for now') {
                          final currentSelected = List<String?>.from(selectedCleaners);
                          currentSelected[i] = newValue;
                          ref.read(selectedCleanersProvider.notifier).state = currentSelected;
                        }
                      }
                    : null,
                items: availableCleaners
                    .map((cleaner) => DropdownMenuItem<String>(
                          value: cleaner['cleaner_name'],
                          child: Text(cleaner['cleaner_name']),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  void _assignTask(
    WidgetRef ref,
    String complaintId,
    List<Map<String, dynamic>> availableCleaners,
  ) async {
    try {
      // Get the list of cleaner user IDs from the selected cleaners
      final cleanerIds = ref
          .read(selectedCleanersProvider.notifier)
          .state
          .where((cleanerName) => cleanerName != null)
          .map((cleanerName) {
              final cleaner = availableCleaners.firstWhere(
                  (element) => element['cleaner_name'] == cleanerName,
                  orElse: () => {},
              );
              return cleaner['cleaner_id']; // Ensure cleaner_id (user_id) is used
          })
          .where((id) => id != null)
          .toList();


      // Retrieve the supervisor ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final supervisorIdStr = prefs.getString('supervisorId'); // Retrieve as string
      final supervisorId = int.tryParse(supervisorIdStr ?? ''); // Convert to integer

      // Ensure supervisor ID exists
      if (supervisorId == null) {
        Logger().e('Supervisor ID is missing.');
        throw Exception('Supervisor ID is missing. Please log in again.');
      }

      Logger().i('Supervisor ID: $supervisorId');
      Logger().i('Complaint ID: $complaintId');
      Logger().i('Cleaner User IDs: $cleanerIds');

      // Prepare the request body
      final body = {
        'cleaner_ids': cleanerIds,
        'no_of_cleaners': int.parse(ref.read(selectedNumOfCleanersProvider.notifier).state ?? '1'),
        'assigned_by': supervisorId, // Dynamically retrieved supervisor ID
      };

      Logger().i('Assign Task Request Body: ${jsonEncode(body)}');

      // Call the provider's assignTask method
      await ref.read(assignTaskProvider.notifier).assignTask(complaintId, body);
    } catch (e) {
      // Log the error
      Logger().e('Error in _assignTask: $e');

      // Re-throw to let it propagate or handle it with a UI dialog
      rethrow;
    }
  }
}
