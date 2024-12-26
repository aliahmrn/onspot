import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Provider to fetch the profile data
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final profileService = ProfileService();
  final Logger logger = Logger();

  try {
    // Get token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      throw Exception('No token found. Please log in again.');
    }

    logger.i('Fetching profile with token: $token');

    // Fetch profile using ProfileService
    final profileData = await profileService.fetchProfile(token);

    logger.i('Profile data fetched successfully: $profileData');
    return profileData;
  } catch (e) {
    logger.e('Error in profileProvider: $e');
    rethrow;
  }
});
