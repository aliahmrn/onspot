import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider to fetch the profile data
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final profileService = ProfileService();

  // Get token from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception('No token found. Please log in again.');
  }

  // Fetch profile using ProfileService
  return await profileService.fetchProfile(token);
});
