import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Profile {
  late final String? _username;
  late final MemoryImage? _profilePicture;

  String? get username => _username;

  MemoryImage? get profilePicture => _profilePicture;

  Profile(dynamic userProfileJson) {
    setProfileData(userProfileJson);
  }

  void setProfileData(dynamic userProfileJson) {
    _username = userProfileJson?['username'];

    if (userProfileJson?['profile_picture'] != null) {
      Uint8List imageBytes = base64Decode(userProfileJson?['profile_picture']);
      _profilePicture = MemoryImage(imageBytes);
    } else {
      _profilePicture = null;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'username': _username,
      'profile_picture':
          _profilePicture != null ? base64Encode(_profilePicture!.bytes) : null,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(map);
  }
}
