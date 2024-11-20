import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_page_provider.dart';
import '../utils/string_extension.dart';
import '../supervisor/cleaner_detail.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  @override
  void initState() {
    super.initState();
    // Fetch all cleaners when the page loads
    Future.microtask(() =>
        ref.read(cleanersProvider.notifier).fetchCleaners());
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;

    final cleaners = ref.watch(cleanersProvider); // List of cleaners
    final selectedStatus = ref.watch(selectedStatusProvider); // Selected dropdown status

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Search Cleaner',
          style: TextStyle(
            color: onPrimaryColor,
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.05,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Search and filter section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        // Search bar
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 233, 233, 233),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.search, color: Colors.grey),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) {
                                      // Filter cleaners based on input and status
                                      ref.read(cleanersProvider.notifier).searchCleaners(
                                        value,
                                        status: selectedStatus,
                                      );
                                    },
                                    decoration: const InputDecoration(
                                      hintText: 'Search cleaner',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Status filter dropdown
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: const Color.fromARGB(255, 233, 233, 233),
                          ),
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            icon: const Icon(Icons.arrow_drop_down),
                            underline: const SizedBox(),
                            items: <String>['all', 'available', 'unavailable']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    value == 'all' ? 'Status' : value.capitalizeFirst(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              ref.read(selectedStatusProvider.notifier).state = newValue!;
                              // Re-filter cleaners based on the selected status
                              ref.read(cleanersProvider.notifier).searchCleaners(
                                '',
                                status: newValue,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Cleaner list section
          Positioned(
            top: 100,
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
              child: cleaners.isEmpty
                  ? Center(
                      child: Text(
                        'No cleaners found.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cleaners.length,
                      itemBuilder: (context, index) {
                        final cleaner = cleaners[index];
                        return CleanerCard(cleaner: cleaner);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// CleanerCard widget
class CleanerCard extends StatelessWidget {
  final Map<String, String> cleaner;
  const CleanerCard({super.key, required this.cleaner});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => CleanerDetailPage(
              cleanerName: cleaner['name'] ?? 'Unknown',
              cleanerStatus: cleaner['status'] ?? 'Unavailable',
              profilePic: cleaner['profile_pic'] ?? '',
              cleanerPhoneNo: cleaner['phone_no'] ?? 'N/A',
              building: cleaner['building'] ?? 'N/A',
            ),
            transitionDuration: Duration.zero, // Disable forward animation
            reverseTransitionDuration: Duration.zero, // Disable reverse animation
          ),
        );
      },
      child: Card(
        color: primaryColor, // Primary color for the card
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: secondaryColor, // Secondary color for the avatar
            child: cleaner['name'] != null && cleaner['name']!.isNotEmpty
                ? Text(
                    cleaner['name']![0].toUpperCase(), // First letter of the name
                    style: TextStyle(
                      color: primaryColor, // Primary color for the font
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: primaryColor, // Primary color for fallback icon
                  ),
          ),
          title: Text(
            cleaner['name'] ?? 'Unknown',
            style: const TextStyle(
              color: Colors.white, // White text for readability
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            cleaner['status'] ?? 'Unavailable',
            style: const TextStyle(
              color: Colors.white70, // Subtle contrast for status
            ),
          ),
        ),
      ),
    );
  }
}
