import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Providers for form inputs
final formKeyProvider = Provider((ref) => GlobalKey<FormState>());
final descriptionControllerProvider =
    Provider((ref) => TextEditingController());
final selectedLocationProvider = StateProvider<String?>((ref) => null);
final selectedDateProvider = StateProvider<DateTime?>((ref) => null);
final selectedTimeProvider = StateProvider<TimeOfDay?>((ref) => null);
final imagePathProvider = StateProvider<String?>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => false);
