import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_page_provider.dart';
import '../utils/string_extension.dart';

class SearchPage extends ConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;
    final screenWidth = MediaQuery.of(context).size.width;

    final filteredCleaners = ref.watch(filteredCleanersProvider);
    final selectedStatus = ref.watch(selectedStatusProvider);

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back arrow button
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
                                    onChanged: (value) => ref
                                        .read(cleanersProvider.notifier)
                                        .fetchCleaners(),
                                    decoration: const InputDecoration(
                                      hintText: 'Search',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
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
              child: filteredCleaners.isEmpty
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
                      itemCount: filteredCleaners.length,
                      itemBuilder: (context, index) {
                        final cleaner = filteredCleaners[index];
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

class CleanerCard extends StatelessWidget {
  final Map<String, String> cleaner;
  const CleanerCard({super.key, required this.cleaner});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(cleaner['name'] ?? ''),
      subtitle: Text(cleaner['status'] ?? ''),
    );
  }
}
