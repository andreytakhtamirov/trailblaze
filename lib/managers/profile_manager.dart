import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/profile.dart';
import '../requests/user_profile.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, Profile?>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<Profile?> {
  ProfileNotifier() : super(null);

  void setProfile(Profile? state) {
    this.state = state;
  }
}

class ProfileManager {
  dynamic refreshProfile(Credentials? credentials) async {
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
        return Profile(data); // Return the profile data
      },
    );
  }
}
