import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/complaints_provider.dart';
import 'complaintdetails.dart';

final tabIndexProvider = StateProvider<int>((ref) => 0);

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    final historyFilter = ref.watch(historyFilterProvider.notifier);
    final filters = ref.watch(historyFilterProvider);
    final tabIndex = ref.watch(tabIndexProvider); // Watch current tab index

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (filters['category'] == 'completed') {
        ref.read(tabIndexProvider.notifier).state = 2;
      } else if (filters['category'] == 'ongoing') {
        ref.read(tabIndexProvider.notifier).state = 1;
      } else {
        ref.read(tabIndexProvider.notifier).state = 0;
      }
    });

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Rekod',
          style: TextStyle(
            color: onPrimaryColor,
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Dropdown for Month Selection
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04, vertical: screenHeight * 0.02),
            child: Center(
              child: Container(
                width: screenWidth * 0.6,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  value: filters['month']?.split('-')[1],
                  hint: const Text(
                    'Pilih Bulan',
                    style: TextStyle(color: Colors.black),
                  ),
                  items: List.generate(12, (index) {
                    final monthValue = (index + 1).toString().padLeft(2, '0');
                    final monthName =
                        DateFormat('MMMM').format(DateTime(0, index + 1));
                    return DropdownMenuItem(
                      value: monthValue,
                      child: Text(
                        monthName,
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }),
                  onChanged: (value) {
                    if (value != null) {
                      final currentYear = DateTime.now().year;
                      historyFilter.updateMonth('$currentYear-$value');
                    }
                  },
                  isExpanded: true,
                  dropdownColor: Colors.grey[300],
                  underline: const SizedBox(),
                ),
              ),
            ),
          ),

          // History List with Filters
          Expanded(
            child: Stack(
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
                        const SizedBox(height: 10),
                        SizedBox(
                          height: screenHeight * 0.05,
                          child: TabBar(
                            controller: TabController(
                              length: 3,
                              vsync: Navigator.of(context),
                              initialIndex: tabIndex, // Sync with StateProvider
                            ),
                            onTap: (index) {
                              ref.read(tabIndexProvider.notifier).state =
                                  index; // Update selected tab

                              // Change filter based on selected tab
                              if (index == 1) {
                                historyFilter.updateCategory(
                                    'ongoing'); // Case 2 (Ongoing)
                              } else if (index == 2) {
                                historyFilter.updateCategory(
                                    'completed'); // Case 3 (Completed)
                              } else {
                                historyFilter
                                    .updateCategory(''); // Case 1 (All)
                              }
                            },
                            tabs: [
                              Tab(
                                icon: Icon(
                                  Icons.list,
                                  color: tabIndex == 0
                                      ? primaryColor
                                      : Colors.grey,
                                  size: screenWidth * 0.045,
                                ),
                                child: Text(
                                  'Semua',
                                  style: TextStyle(
                                    color: tabIndex == 0
                                        ? primaryColor
                                        : Colors.grey,
                                    fontSize: screenWidth * 0.039,
                                  ),
                                ),
                              ),
                              Tab(
                                icon: Icon(
                                  Icons.access_time,
                                  color: tabIndex == 1
                                      ? primaryColor
                                      : Colors.grey,
                                  size: screenWidth * 0.045,
                                ),
                                child: Text(
                                  'Berjalan',
                                  style: TextStyle(
                                    color: tabIndex == 1
                                        ? primaryColor
                                        : Colors.grey,
                                    fontSize: screenWidth * 0.039,
                                  ),
                                ),
                              ),
                              Tab(
                                icon: Icon(
                                  Icons.check_circle,
                                  color: tabIndex == 2
                                      ? primaryColor
                                      : Colors.grey,
                                  size: screenWidth * 0.045,
                                ),
                                child: Text(
                                  'Selesai',
                                  style: TextStyle(
                                    color: tabIndex == 2
                                        ? primaryColor
                                        : Colors.grey,
                                    fontSize: screenWidth * 0.039,
                                  ),
                                ),
                              ),
                            ],
                            indicatorColor: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Consumer(builder: (context, ref, _) {
                            final historyAsync = ref.watch(historyProvider);
                            return RefreshIndicator(
                              onRefresh: () async {
                                ref.invalidate(
                                    complaintsProvider); // Manually refreshes provider
                              },
                              child: historyAsync.when(
                                loading: () => const Center(
                                    child: CircularProgressIndicator()),
                                error: (error, _) =>
                                    Center(child: Text('Error: $error')),
                                data: (tasks) {
                                  // ✅ Filter tasks based on selected tab
                                  final filteredTasks = tasks.where((task) {
                                    final caseNumber = getComplaintCase(
                                        task['comp_status'] ?? 'pending');

                                    if (tabIndex == 1) {
                                      return caseNumber ==
                                          2; // ✅ Show only Case 2 (Ongoing) in Tab 2
                                    } else if (tabIndex == 2) {
                                      return caseNumber ==
                                          1; // ✅ Show only Case 1 (Completed) in Tab 3
                                    }
                                    return true; // ✅ Show all tasks in Tab 1
                                  }).toList();

                                  if (filteredTasks.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Tiada rekod tersedia.',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: filteredTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = filteredTasks[index];
                                      final assignedDate =
                                          task['comp_date'] ?? 'Tiada Tarikh';
                                      final description = task['comp_desc'] ??
                                          'Tiada Penerangan';
                                      final complaintTitle = getComplaintTitle(
                                          task['comp_status'] ?? 'pending');
                                      final compLocation =
                                          task['comp_location'] ??
                                              'Lokasi Tidak Diketahui';

                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: screenHeight * 0.01),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                              screenWidth * 0.03),
                                          onTap: () {
                                            final complaintId = task['id'];

                                            if (complaintId is int) {
                                              // Ensure it's an integer before navigating
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ComplaintDetailsPage(
                                                          complaintId:
                                                              complaintId),
                                                ),
                                              );
                                            } else {
                                              print(
                                                  'Error: complaintId is null or not an int. Received: $complaintId');
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Invalid Complaint ID')),
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      screenWidth * 0.03),
                                              border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(0.5),
                                                  width: 1.2),
                                            ),
                                            padding: EdgeInsets.all(
                                                screenWidth * 0.04),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(Icons.access_time,
                                                        color: onPrimaryColor
                                                            .withOpacity(0.7),
                                                        size:
                                                            screenWidth * 0.05),
                                                    SizedBox(
                                                        width:
                                                            screenWidth * 0.02),
                                                    Text(
                                                      complaintTitle,
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.045,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              onPrimaryColor),
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                      assignedDate !=
                                                              'Tiada Tarikh'
                                                          ? DateFormat(
                                                                  'dd/MM/yyyy')
                                                              .format(DateTime
                                                                  .parse(
                                                                      assignedDate))
                                                          : 'Tiada tarikh',
                                                      style: TextStyle(
                                                          fontSize:
                                                              screenWidth *
                                                                  0.035,
                                                          color: onPrimaryColor
                                                              .withOpacity(
                                                                  0.6)),
                                                    ),
                                                  ],
                                                ),
                                                const Divider(
                                                    color: Colors.white24),
                                                Text(
                                                  description,
                                                  style: TextStyle(
                                                      fontSize:
                                                          screenWidth * 0.04,
                                                      color: onPrimaryColor
                                                          .withOpacity(0.9)),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    Icon(Icons.location_on,
                                                        color: Colors.white70,
                                                        size: screenWidth *
                                                            0.045),
                                                    const SizedBox(width: 5),
                                                    Expanded(
                                                      child: Text(
                                                        compLocation,
                                                        style: TextStyle(
                                                            fontSize:
                                                                screenWidth *
                                                                    0.035,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white70),
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
          ),
        ],
      ),
    );
  }
}

String getComplaintTitle(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return 'Aduan selesai';
    case 'ongoing':
      return 'Aduan telah ditugaskan';
    case 'pending':
    default:
      return 'Aduan belum ditugaskan';
  }
}

int getComplaintCase(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return 1; // ✅ Case 1: Completed (Tab 3)
    case 'ongoing':
      return 2; // ✅ Case 2: Ongoing (Tab 2)
    case 'pending':
    default:
      return 3; // ✅ Case 3: Pending (Only in Tab 1)
  }
}
