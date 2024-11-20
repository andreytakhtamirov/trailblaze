import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:trailblaze/constants/pubspec.yaml.g.dart';

class DeviceInfoHelper {
  static const String kDefaultDeviceId =
      name; // Use app name if identifier unavailable.

  static Future<String> getDeviceDetails() async {
    String? identifier;
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        identifier = build.id;
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        identifier = data.identifierForVendor;
      }
    } on PlatformException {
      log('Failed to get platform version');
    }

    return identifier ?? kDefaultDeviceId;
  }
}
