import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/profile_service.dart';
import '../providers/attendance_provider.dart';

/// Provider to fetch the profile data
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final profileService = ProfileService();
  final token = ref.watch(authTokenProvider);

  if (token.isEmpty) {
    throw Exception('No token found. Please log in again.');
  }

  try {
    return await profileService.fetchProfile(token);
  } catch (e) {
    throw Exception('Failed to load profile: $e');
  }
});
