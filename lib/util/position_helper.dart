import 'dart:developer';

import 'package:geolocator/geolocator.dart' as geo;
import 'package:trailblaze/util/ui_helper.dart';

class PositionHelper {
  static Future<geo.Position?> getCurrentPosition(context) async {
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
        return null;
      }
    } catch (e) {
      log('Failed to check or request location permission: $e');
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
}
