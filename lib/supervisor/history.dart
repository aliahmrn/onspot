import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/complaints_provider.dart';
import 'history_details.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  String selectedCategory = 'ongoing'; // Default category for filtering

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'History',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Container(color: primaryColor),
          Positioned(
            top: screenHeight * 0.01,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(screenWidth * 0.06),
                  topRight: Radius.circular(screenWidth * 0.06),
                ),
              ),
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                children: [
                    DefaultTabController(
                      length: 2,
                      initialIndex: selectedCategory == 'ongoing' ? 0 : 1,
                      child: SizedBox( // Added SizedBox to reduce height
                        height: screenHeight * 0.07, // Adjust this height as needed
                        child: TabBar(
                          onTap: (index) {
                            setState(() {
                              selectedCategory = index == 0 ? 'ongoing' : 'completed';
                              ref.invalidate(historyProvider(selectedCategory));
                            });
                          },
                          tabs: [
                            Tab(
                              icon: Icon(
                                Icons.access_time,
                                color: selectedCategory == 'ongoing' ? primaryColor : Colors.grey,
                              ),
                              child: Text(
                                'Ongoing',
                                style: TextStyle(
                                  color: selectedCategory == 'ongoing' ? primaryColor : Colors.grey,
                                  fontSize: screenWidth * 0.035, // Adjust font size for better fit
                                ),
                              ),
                            ),
                            Tab(
                              icon: Icon(
                                Icons.check_circle,
                                color: selectedCategory == 'completed' ? primaryColor : Colors.grey,
                              ),
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                  color: selectedCategory == 'completed' ? primaryColor : Colors.grey,
                                  fontSize: screenWidth * 0.035, // Adjust font size for better fit
                                ),
                              ),
                            ),
                          ],
                          indicatorColor: primaryColor,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Consumer(builder: (context, ref, _) {
                      final historyAsync = ref.watch(historyProvider(selectedCategory));

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(historyProvider(selectedCategory));
                        },
                        child: historyAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, _) => Center(child: Text('Error: $error')),
                          data: (tasks) {
                            if (tasks.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No assigned complaints history.',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                final compDate = task['comp_date'] ?? 'No Date';
                                final description = task['comp_desc'] ?? 'No Description';
                                final noOfCleaners = task['no_of_cleaners'] ?? '0';

                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              TaskDetailsPage(
                                            complaintId: task['id'].toString(),
                                          ),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration: Duration.zero,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.5),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: screenWidth * 0.003,
                                            blurRadius: screenWidth * 0.02,
                                            offset: Offset(0, screenHeight * 0.003),
                                          ),
                                        ],
                                      ),
                                      padding: EdgeInsets.all(screenWidth * 0.04),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.access_time,
                                                color: onPrimaryColor.withOpacity(0.7),
                                                size: screenWidth * 0.05,
                                              ),
                                              SizedBox(width: screenWidth * 0.02),
                                              Text(
                                                'Complaint assigned',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.045,
                                                  fontWeight: FontWeight.bold,
                                                  color: onPrimaryColor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                DateFormat('dd/MM/yyyy').format(DateTime.parse(compDate)),
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.035,
                                                  color: onPrimaryColor.withOpacity(0.6),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(color: Colors.white24),
                                          SizedBox(height: screenHeight * 0.005),

                                          Text(
                                            description,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.04,
                                              color: onPrimaryColor.withOpacity(0.9),
                                            ),
                                          ),
                                          SizedBox(height: screenHeight * 0.005),

                                          Row(
                                            children: [
                                              Icon(
                                                Icons.people,
                                                size: screenWidth * 0.04,
                                                color: onPrimaryColor.withOpacity(0.7),
                                              ),
                                              SizedBox(width: screenWidth * 0.02),
                                              Text(
                                                '$noOfCleaners Cleaners Assigned',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.035,
                                                  color: onPrimaryColor.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }
}
