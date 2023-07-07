import 'dart:convert';
import 'dart:typed_data';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';

class Profile {
  late Credentials? credentials;
  late final String? _username;
  late final MemoryImage? _profilePicture;

  String? get username => _username;

  MemoryImage? get profilePicture => _profilePicture;

  Profile(this.credentials, dynamic userProfileJson) {
    setProfileData(userProfileJson);
  }

  void setProfileData(dynamic userProfileJson) {
    _username = userProfileJson?['username'];

    if (userProfileJson?['profile_picture'] != null) {
      Uint8List imageBytes = base64Decode(userProfileJson?['profile_picture']);
      _profilePicture = MemoryImage(imageBytes);
    }
  }
}
