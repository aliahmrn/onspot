import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/assign_task_provider.dart';
import '../providers/navigation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../service/complaints_service.dart';

final complaintListProvider = StateNotifierProvider<ComplaintListNotifier, List<Map<String, dynamic>>>((ref) {
  return ComplaintListNotifier();
});

class ComplaintListNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ComplaintListNotifier() : super([]);

  final _complaintsService = ComplaintsService();
  final Logger logger = Logger();

  Future<void> refresh() async {
    try {
      logger.i('Fetching complaints...');
      final complaints = await _complaintsService
          .fetchComplaints()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Timeout while fetching complaints.');
      });
      logger.i('Complaints fetched: $complaints');
      state = complaints;
    } catch (e) {
      logger.i('Error fetching complaints: $e');
      state = []; // Ensure the state resets to avoid UI freezes
    }
  }
}

class AssignTaskPage extends ConsumerWidget {
  final String complaintId;
    final Logger logger = Logger();

  AssignTaskPage({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

ref.listen<AsyncValue<Map<String, dynamic>>>(assignTaskProvider, (previous, next) {
  if (next is AsyncLoading) return; // Ignore loading state here

  next.when(
    data: (_) {
      if (previous is AsyncLoading) {
        // Prevent redundant refresh calls
        Future.delayed(const Duration(milliseconds: 200), () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Berjaya'),
              content: const Text('Aduan berjaya ditugaskan.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    ref.read(currentIndexProvider.notifier).state = 2;
                    ref.read(complaintListProvider.notifier).refresh();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    },
    error: (error, _) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text('Aduan tidak berjaya ditugaskan: $error'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    },
    loading: () => {}, // Ignore loading state
  );
});

    final complaintDetailsAsync = ref.watch(complaintDetailsProvider(complaintId));
    logger.i('Fetching complaint details for complaintId: $complaintId');
    final assignTaskState = ref.watch(assignTaskProvider);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Tugaskan Aduan',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor, // White background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(screenWidth * 0.06), // Rounded corners
                    topRight: Radius.circular(screenWidth * 0.06),
                  ),
                ),
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: complaintDetailsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(child: Text('Error: $error')),
                  data: (complaintDetails) {
                    if (complaintDetails.isEmpty) {
                      return const Center(child: Text('No complaint details available.'));
                    }
                    final availableCleaners = List<Map<String, dynamic>>.from(
                      complaintDetails['available_cleaners'] ?? [],
                    );
                    final formattedDate = DateFormat('dd/MM/yyyy').format(
                      DateTime.parse(complaintDetails['comp_date']),
                    );
                    final imageUrl = complaintDetails['comp_image_url'];
                    final isAssignButtonEnabled = availableCleaners.isNotEmpty;

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Section
                          Container(
                            width: double.infinity,
                            height: screenHeight * 0.3,
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
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover, // Ensures the image covers the entire container
                                    )
                                  : null,
                            ),
                            child: imageUrl == null
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image_not_supported,
                                            size: screenWidth * 0.1, color: Colors.grey[400]),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Gambar Tidak Tersedia',
                                          style: TextStyle(
                                              color: Colors.grey[600], fontSize: screenWidth * 0.04),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // Complaint Details Section
                          _buildMultilineDetailRow(
                            Icons.location_on,
                            'Lokasi',
                            complaintDetails['comp_location'] ?? 'Tiada Lokasi',
                            screenWidth,
                          ),
                          const Divider(color: Colors.grey, thickness: 0.5),
                          _buildMultilineDetailRow(
                            Icons.date_range,
                            'Tarikh',
                            formattedDate,
                            screenWidth,
                          ),
                          const Divider(color: Colors.grey, thickness: 0.5),
                          _buildMultilineDetailRow(
                            Icons.description,
                            'Penerangan',
                            complaintDetails['comp_desc'] ?? 'Tiada Penerangan',
                            screenWidth,
                          ),
                          const Divider(color: Colors.grey, thickness: 0.5),

                          _buildMultilineDetailRow(
                            Icons.person, // Use person icon for officer name
                            'Aduan Oleh',
                            complaintDetails['officer_name'] ?? 'Tidak Diketahui',
                            screenWidth,
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // Number of Cleaners Section
                          _buildCleanersDropdownSection(
                            ref: ref,
                            availableCleaners: availableCleaners,
                            complaintId: complaintId,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            isAssignButtonEnabled: isAssignButtonEnabled,
                            screenWidth: screenWidth,
                            screenHeight: screenHeight,
                          ),

                          SizedBox(height: screenHeight * 0.04),

                          // Assign Button Section
                          Center(
                            child: ElevatedButton(
                              onPressed: isAssignButtonEnabled
                                  ? () => _assignTask(ref, complaintId, availableCleaners)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.2, vertical: screenHeight * 0.02),
                                backgroundColor: isAssignButtonEnabled ? primaryColor : Colors.grey,
                                foregroundColor: secondaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: assignTaskState.isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      isAssignButtonEnabled ? 'Tugaskan Aduan' : 'Tiada Pembersih Tersedia',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.045,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultilineDetailRow(IconData icon, String label, String value, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.black, size: screenWidth * 0.05),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label:', // Bold label
                  style: TextStyle(fontSize: screenWidth * 0.04, fontWeight: FontWeight.bold),
                ),
                Text(
                  value, // Normal context
                  style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.black),
                ),
              ],
            ),
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
    required double screenWidth,
    required double screenHeight,
  }) {
    final selectedNumOfCleaners = ref.watch(selectedNumOfCleanersProvider);
    final selectedCleaners = ref.watch(selectedCleanersProvider);

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
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
          Text(
            'Bilangan Pembersih Diperlukan',
            style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: screenHeight * 0.015),
          DropdownButton<String>(
            isExpanded: true,
            value: selectedNumOfCleaners,
            hint: Text('Pilih Bilangan', style: TextStyle(fontSize: screenWidth * 0.04)),
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
                      child: Text(value, style: TextStyle(fontSize: screenWidth * 0.04)),
                    ))
                .toList(),
          ),
          SizedBox(height: screenHeight * 0.015),
          for (int i = 0; i < int.parse(selectedNumOfCleaners ?? '1'); i++)
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedCleaners.length > i && availableCleaners.any(
                        (cleaner) => cleaner['cleaner_name'] == selectedCleaners[i])
                    ? selectedCleaners[i]
                    : null, // Ensure value is valid
                hint: Text('Pilih Pembersih', style: TextStyle(fontSize: screenWidth * 0.04)),
                onChanged: isAssignButtonEnabled
                    ? (newValue) {
                        if (newValue != null) {
                          final currentSelected = List<String?>.from(selectedCleaners);
                          currentSelected[i] = newValue;
                          ref.read(selectedCleanersProvider.notifier).state = currentSelected;
                        }
                      }
                    : null,
                items: availableCleaners
                    .map((cleaner) => DropdownMenuItem<String>(
                          value: cleaner['cleaner_name'],
                          child: Text(cleaner['cleaner_name'], style: TextStyle(fontSize: screenWidth * 0.04)),
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
      final cleanerIds = ref
          .read(selectedCleanersProvider.notifier)
          .state
          .where((cleanerName) => cleanerName != null)
          .map((cleanerName) {
            final cleaner = availableCleaners.firstWhere(
              (element) => element['cleaner_name'] == cleanerName,
              orElse: () {
                ('Cleaner not found for name: $cleanerName');
                return {};
              },
            );
            return cleaner['cleaner_id']?.toString();
          })
          .where((id) => id != null)
          .cast<String>()
          .toList();

      final prefs = await SharedPreferences.getInstance();
      final supervisorIdStr = prefs.getString('supervisorId');
      final supervisorId = int.tryParse(supervisorIdStr ?? '');

      if (supervisorId == null) {
        throw Exception('Supervisor ID is missing. Please log in again.');
      }

      final body = {
        'cleaner_ids': cleanerIds,
        'no_of_cleaners': int.parse(ref.read(selectedNumOfCleanersProvider.notifier).state ?? '1'),
        'assigned_by': supervisorId,
      };

      logger.i('Assigning task with body: $body'); // Log the body
      await ref.read(assignTaskProvider.notifier).assignTask(
        complaintId: complaintId,
        cleanerIds: cleanerIds.map(int.parse).toList(), // Ensure cleaner IDs are integers
        noOfCleaners: int.parse(ref.read(selectedNumOfCleanersProvider)!),
        assignedBy: supervisorId,
      );

      // Reset dropdown state after assignment
      ref.read(selectedNumOfCleanersProvider.notifier).state = null;
      ref.read(selectedCleanersProvider.notifier).state = [];

      logger.i('Task assignment complete'); // Confirm completion
    } catch (e) {
      Logger().e('Error in _assignTask: $e');
      rethrow;
    }
  }
}
