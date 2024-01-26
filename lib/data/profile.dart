import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class Profile {
  late final String? _id;
  late final String? _username;
  late final MemoryImage? _profilePicture;

  String? get id => _id;
  String? get username => _username;
  MemoryImage? get profilePicture => _profilePicture;

  Profile.fromJson(dynamic json) {
    setProfileData(json);
  }

  void setProfileData(dynamic userProfileJson) {
    _id = userProfileJson?['id'];
    _username = userProfileJson?['username'];

    if (userProfileJson?['profile_picture'] != null) {
      Uint8List imageBytes = base64Decode(userProfileJson?['profile_picture']);
      _profilePicture = MemoryImage(imageBytes);
    } else {
      _profilePicture = null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'username': _username,
      'profile_picture':
          _profilePicture != null ? base64Encode(_profilePicture.bytes) : null,
    };
  }
}
