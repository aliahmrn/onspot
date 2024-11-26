import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define the current index provider
final currentIndexProvider = StateProvider<int>((ref) => 0); // Default to the first tab
