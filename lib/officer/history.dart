import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../service/history_service.dart';
import 'navbar.dart';
import 'complaintdetails.dart';
import 'package:onspot_officer/widget/date.dart';

// State for history
class HistoryState {
  final List<dynamic> historyData;
  final bool hasFetchedData;

  HistoryState({
    required this.historyData,
    required this.hasFetchedData,
  });

  HistoryState copyWith({
    List<dynamic>? historyData,
    bool? hasFetchedData,
  }) {
    return HistoryState(
      historyData: historyData ?? this.historyData,
      hasFetchedData: hasFetchedData ?? this.hasFetchedData,
    );
  }
}

// StateNotifier to manage history data
class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(HistoryState(historyData: [], hasFetchedData: false));

  Future<void> loadComplaintHistory() async {
    try {
      List<dynamic> data = await fetchComplaintHistory();
      state = state.copyWith(historyData: data, hasFetchedData: true);
    } catch (e) {
      state = state.copyWith(hasFetchedData: true);
    }
  }
}

// Provider for history state
final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) => HistoryNotifier());

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final historyNotifier = ref.read(historyProvider.notifier);

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    // Load data when the widget is first built
    if (!historyState.hasFetchedData) {
      Future.microtask(() => historyNotifier.loadComplaintHistory());
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'History',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(screenWidth * 0.06),
            topRight: Radius.circular(screenWidth * 0.06),
          ),
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: historyState.hasFetchedData
            ? (historyState.historyData.isEmpty
                ? const Center(child: Text('No complaints found'))
                : ListView.builder(
                    itemCount: historyState.historyData.length,
                    itemBuilder: (context, index) {
                      final complaint = historyState.historyData[index];
                      final complaintId = complaint['id'];

                      return Padding(
                        padding: EdgeInsets.only(bottom: screenHeight * 0.015),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: screenWidth * 0.005,
                                    blurRadius: screenWidth * 0.03,
                                    offset: Offset(0, screenHeight * 0.005),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(screenWidth * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.history,
                                            color: onPrimaryColor.withOpacity(0.7),
                                            size: screenWidth * 0.05,
                                          ),
                                          SizedBox(width: screenWidth * 0.025),
                                          Text(
                                            getStatusText(complaint['comp_status'] ?? 'unknown'),
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.045,
                                              fontWeight: FontWeight.bold,
                                              color: onPrimaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        formatTime(complaint['comp_time']),
                                        style: TextStyle(
                                          color: onPrimaryColor.withOpacity(0.7),
                                          fontSize: screenWidth * 0.035,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    complaint['comp_desc'] ?? '',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: onPrimaryColor,
                                    ),
                                  ),
                                  SizedBox(height: screenHeight * 0.005),
                                  Text(
                                    formatDate(complaint['comp_date']),
                                    style: TextStyle(
                                      color: onPrimaryColor.withOpacity(0.7),
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: screenHeight * 0.01,
                              right: screenWidth * 0.02,
                              child: IconButton(
                                icon: Icon(Icons.arrow_forward, color: onPrimaryColor),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ComplaintDetailsPage(complaintId: complaintId),
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
      bottomNavigationBar: const OfficerNavBar(),
    );
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

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Complaint sent!';
      case 'ongoing':
        return 'Complaint in progress...';
      case 'completed':
        return 'Complaint resolved!';
      default:
        return 'Unknown status';
    }
  }
}
