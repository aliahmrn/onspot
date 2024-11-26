import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/profile_service.dart';
import 'package:logger/logger.dart';

/// State for the profile edit page
class ProfileEditState {
  final String? profilePic;
  final String name;
  final String username;
  final String email;
  final String phone;
  final bool isLoading;
  final String? error;

  ProfileEditState({
    required this.profilePic,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    this.isLoading = false,
    this.error,
  });

  ProfileEditState copyWith({
    String? profilePic,
    String? name,
    String? username,
    String? email,
    String? phone,
    bool? isLoading,
    String? error,
  }) {
    return ProfileEditState(
      profilePic: profilePic ?? this.profilePic,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing profile edit logic
class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final ProfileService _profileService;
  final Logger _logger = Logger(); // Logger instance for logging.

  ProfileEditNotifier(this._profileService)
      : super(ProfileEditState(
          profilePic: null,
          name: '',
          username: '',
          email: '',
          phone: '',
        ));

  /// Load profile data
  Future<void> loadProfile(String token) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      _logger.i('Loading profile data for token: $token');
      final profileData = await _profileService.fetchProfile(token);
      _logger.i('Profile data loaded successfully: $profileData');
      state = ProfileEditState(
        profilePic: profileData['profile_pic'],
        name: profileData['name'] ?? '',
        username: profileData['username'] ?? '',
        email: profileData['email'] ?? '',
        phone: profileData['phone_no'] ?? '',
        isLoading: false,
      );
    } catch (e) {
      _logger.e('Failed to load profile data: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update a specific field in the form
  void updateField(String field, String value) {
    _logger.i('Updating field $field with value $value');
    switch (field) {
      case 'name':
        state = state.copyWith(name: value);
        break;
      case 'username':
        state = state.copyWith(username: value);
        break;
      case 'email':
        state = state.copyWith(email: value);
        break;
      case 'phone':
        state = state.copyWith(phone: value);
        break;
    }
  }

  /// Handle profile picture updates
  void updateProfilePicture(String? path) {
    _logger.i('Updating profile picture with path: $path');
    state = state.copyWith(profilePic: path);
  }

  /// Submit the updated profile
  Future<void> saveProfile(String token) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final updatedData = {
        'name': state.name,
        'username': state.username,
        'email': state.email,
        'phone_no': state.phone,
      };

      // Log the data and token
      _logger.i('Prepared data for profile update: $updatedData');
      _logger.i('Calling updateProfile with token: $token');

      await _profileService.updateProfile(token, updatedData);

      // Update state to indicate success
      _logger.i('Profile updated successfully');
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      // Log the error and update the state
      _logger.e('Failed to save profile: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// Provider for managing profile edit state
final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, ProfileEditState>((ref) {
  return ProfileEditNotifier(ProfileService());
});

/// Provider for loading profile data
final profileLoaderProvider = FutureProvider.autoDispose<void>((ref) async {
  final notifier = ref.read(profileEditProvider.notifier);

  // Get the token from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception('Token not found. Please log in again.');
  }

  // Log the token being used to load the profile
  final logger = Logger();
  logger.i('Loading profile with token: $token');

  // Load the profile using the token
  await notifier.loadProfile(token);
});
