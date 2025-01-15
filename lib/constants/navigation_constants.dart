import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

final LocationSettings kNavigationLocationSettings =
    (defaultTargetPlatform == TargetPlatform.android)
        ? AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
          )
        : (defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS)
            ? AppleSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                activityType: ActivityType.fitness,
                distanceFilter: 0,
                allowBackgroundLocationUpdates: false,
                pauseLocationUpdatesAutomatically: true,
                showBackgroundLocationIndicator: false,
              )
            : const LocationSettings(
                accuracy: LocationAccuracy.bestForNavigation,
                distanceFilter: 0,
              );
