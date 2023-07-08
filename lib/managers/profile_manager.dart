import 'dart:convert';
import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trailblaze/constants/storage_token_constants.dart';

import '../data/profile.dart';
import '../requests/user_profile.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile?>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<Profile?> {
  final ProfileManager _profileManager = ProfileManager();

  ProfileNotifier() : super(null);

  void setProfile(Profile? state) {
    if (state == null) {
      _profileManager.clearProfile();
    } else {
      _profileManager.updateProfile(state);
    }

    this.state = state;
  }
}

class ProfileManager {
  late final FlutterSecureStorage _storage;

  ProfileManager() {
    _storage = const FlutterSecureStorage();
  }

  dynamic refreshProfile(Credentials? credentials) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Fall back to stored profile.
      return await _loadProfileFromStorage();
    } else {
      final response = await getProfile(credentials?.idToken ?? '');
      return response.fold(
        (error) {
          // User account requires setup (first sign-in).
          if (error == 204) {
            // Return profile with null properties.
            // This signals that it requires setup.
            return Profile(null);
          } else {
            return null;
          }
        },
        (data) {
          return Profile(data);
        },
      );
    }
  }

  void updateProfile(Profile profile) {
    _storeProfileInStorage(profile);
  }

  void clearProfile() {
    _storage.delete(key: kUserProfileKey);
    log('Cleared user profile from storage');
  }

  Future<Profile?> _loadProfileFromStorage() async {
    final profileJson = await _storage.read(key: kUserProfileKey);
    if (profileJson != null) {
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return Profile.fromMap(profileMap);
    }

    return null;
  }

  void _storeProfileInStorage(Profile? profile) async {
    if (profile == null) {
      return;
    }

    _storage.write(key: kUserProfileKey, value: jsonEncode(profile.toMap()));
  }
}
