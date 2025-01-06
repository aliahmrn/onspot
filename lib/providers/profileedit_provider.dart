import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/profile_service.dart';
import 'package:logger/logger.dart';
import '../providers/profile_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State for the profile edit page
class ProfileEditState {
  final String? profilePic; // Original profile picture from the server
  final String? tempProfilePic; // Temporary profile picture for local updates
  final String name;
  final String username;
  final String email;
  final String phone;
  final String tempName;
  final String tempUsername;
  final String tempEmail;
  final String tempPhone;
  final bool isLoading;    
  final String? error;
  final bool success;

  ProfileEditState({
    required this.profilePic,
    required this.tempProfilePic,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.tempName,
    required this.tempUsername,
    required this.tempEmail,
    required this.tempPhone,
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  ProfileEditState copyWith({
    String? profilePic,
    String? tempProfilePic,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? tempName,
    String? tempUsername,
    String? tempEmail,
    String? tempPhone,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return ProfileEditState(
      profilePic: profilePic ?? this.profilePic,
      tempProfilePic: tempProfilePic ?? this.tempProfilePic,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      tempName: tempName ?? this.tempName,
      tempUsername: tempUsername ?? this.tempUsername,
      tempEmail: tempEmail ?? this.tempEmail,
      tempPhone: tempPhone ?? this.tempPhone,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final ProfileService _profileService;
  final Ref ref;
  final Logger _logger = Logger(); // Logger instance for logging.
  final String defaultProfilePictureUrl =
      'http://192.168.1.105:8000/storage/profile_pic/default.webp';

  ProfileEditNotifier(this._profileService, this.ref)
      : super(ProfileEditState(
          profilePic: null,
          tempProfilePic: null,
          name: '',
          username: '',
          email: '',
          phone: '',
          tempName: '',
          tempUsername: '',
          tempEmail: '',
          tempPhone: '',
        ));

  /// Load profile data
  Future<void> loadProfile(String token) async {
    if (state.isLoading) return; // Prevent redundant calls

    state = state.copyWith(isLoading: true, error: null);
    try {
      _logger.i('Fetching profile data for Edit Screen...');
      final profileData = await _profileService.fetchProfile(token);

      _logger.i('Profile data fetched successfully: $profileData');

      state = state.copyWith(
        profilePic: profileData['profile_pic'],
        tempProfilePic: profileData['profile_pic'],
        name: profileData['name'] ?? '',
        tempName: profileData['name'] ?? '',
        username: profileData['username'] ?? '',
        tempUsername: profileData['username'] ?? '',
        email: profileData['email'] ?? '',
        tempEmail: profileData['email'] ?? '',
        phone: profileData['phone_no'] ?? '',
        tempPhone: profileData['phone_no'] ?? '',
        isLoading: false,
      );

      _logger.i('State updated for Edit Screen: $state');
    } catch (e) {
      _logger.e('Error in loadProfile: $e');
      state = state.copyWith(
        isLoading: false,
        error: _classifyError(e.toString()),
      );
    }
  }

  void retryLoadProfile(String token) {
    if (!state.isLoading) {
      loadProfile(token);
    }
  }

  void resetState() {
    state = ProfileEditState(
      profilePic: null,
      tempProfilePic: null,
      name: '',
      tempName: '',
      username: '',
      tempUsername: '',
      email: '',
      tempEmail: '',
      phone: '',
      tempPhone: '',
      isLoading: false,
      error: null,
      success: false,
    );
  }

  /// Update a specific field in the form
  void updateField(String field, String value) {
    _logger.i('Updating field $field with value $value');
    switch (field) {
      case 'name':
        state = state.copyWith(tempName: value);
        break;
      case 'username':
        state = state.copyWith(tempUsername: value);
        break;
      case 'email':
        state = state.copyWith(tempEmail: value);
        break;
      case 'phone':
        state = state.copyWith(tempPhone: value);
        break;
    }
  }

  void updateTempProfilePicture(String? path) {
    _logger.i('Updating temp profile picture with path: $path');
    state = state.copyWith(
      tempProfilePic: path ?? defaultProfilePictureUrl,
    );
    _logger.i('State after updating temp profile picture: $state');
  }

  Future<void> saveProfile(String token) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      String? uploadedProfilePicUrl = state.profilePic;

      // If tempProfilePic is default, delete the profile picture from the server
      if (state.tempProfilePic == defaultProfilePictureUrl &&
          state.tempProfilePic != state.profilePic) {
        _logger.i('🗑️ Deleting profile picture on the server...');
        uploadedProfilePicUrl = await _profileService.deleteProfilePicture(token);
        _logger.i('✅ Profile picture deleted on the server: $uploadedProfilePicUrl');
      } 
      // If there's a new profile picture (upload scenario)
      else if (state.tempProfilePic != null &&
              state.tempProfilePic != state.profilePic &&
              state.tempProfilePic != defaultProfilePictureUrl) {
        _logger.i('📤 Uploading new profile picture...');
        uploadedProfilePicUrl = await _profileService.uploadProfilePicture(
            token, state.tempProfilePic!);
        _logger.i('✅ New profile picture uploaded: $uploadedProfilePicUrl');
      }

      // Prepare updated profile data
      final updatedData = {
        'name': state.tempName,
        'username': state.tempUsername,
        'email': state.tempEmail,
        'phone_no': state.tempPhone,
        'profile_pic': uploadedProfilePicUrl,
        '_method': 'PUT',
      };

      _logger.i('📥 Sending updated profile data to the server: $updatedData');
      await _profileService.updateProfile(token, updatedData);

      ref.invalidate(profileProvider);

      state = state.copyWith(
        profilePic: uploadedProfilePicUrl,
        tempProfilePic: uploadedProfilePicUrl,
        isLoading: false,
        success: true,
      );
    } catch (e) {
      _logger.e('❌ Error during saveProfile: $e');
      state = state.copyWith(
        isLoading: false,
        error: _classifyError(e.toString()),
        success: false,
      );
    }
  }

Future<void> handleProfilePictureDeletion(String token) async {
  state = state.copyWith(
    tempProfilePic: defaultProfilePictureUrl, // Temporarily set to default locally
  );
  _logger.i('🗑️ Profile picture marked for deletion (locally updated).');
}

  String _classifyError(String error) {
    if (error.contains('Unauthorized')) return 'Unauthorized. Please log in.';
    if (error.contains('Timeout')) return 'Request timeout. Try again later.';
    return 'Unexpected error occurred.';
  }

  void cancelChanges() {
    state = state.copyWith(
      tempProfilePic: state.profilePic, // Revert to original profile picture
      tempName: state.name,
      tempUsername: state.username,
      tempEmail: state.email,
      tempPhone: state.phone,
    );
    _logger.i('✋ Changes canceled. State reverted to original values.');
  }

}

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, ProfileEditState>((ref) {
  return ProfileEditNotifier(ProfileService(), ref);
});

final profileLoaderProvider = FutureProvider.autoDispose<void>((ref) async {
  // Get the token from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  if (token == null) {
    throw Exception('Token not found. Please log in again.');
  }

  final logger = Logger();
  logger.i('Loading profile for Edit Screen with token: $token');

  // Load the profile using the token
  await ref.read(profileEditProvider.notifier).loadProfile(token);

  logger.i('Profile loaded for Edit Screen: ${ref.read(profileEditProvider)}');
});