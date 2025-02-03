import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:trailblaze/util/ui_helper.dart';

class PositionHelper {
  static Future<geo.Position?> getCurrentPosition(context) async {
    if (!await hasLocationPermission(context)) {
      return null;
    }

    geo.Position? position;
    try {
      position = await geo.Geolocator.getLastKnownPosition() ??
          await geo.Geolocator.getCurrentPosition();
    } catch (e) {
      log('Failed to fetch user location: $e');
      return null;
    }

    return position;
  }

  static Future<bool> hasLocationPermission(BuildContext context,
      {bool needPrecise = false}) async {
    geo.LocationPermission permission;
    try {
      permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.deniedForever) {
        if (context.mounted) {
          UiHelper.showSnackBar(
            context,
            'Location permissions are needed to show routes.',
          );
        }
        return false;
      } else if (needPrecise &&
          await geo.Geolocator.getLocationAccuracy() !=
              geo.LocationAccuracyStatus.precise) {
        final status = await geo.Geolocator.requestTemporaryFullAccuracy(
            purposeKey: "Precise location is needed for navigation");
        if (status == geo.LocationAccuracyStatus.reduced) {
          if (context.mounted) {
            UiHelper.showSnackBar(
              context,
              'Precise location permissions are needed for navigation.',
            );
          }
          return false;
        }
      }
    } catch (e) {
      log('Failed to check or request location permission: $e');
      return false;
    }

    return true;
  }
}
