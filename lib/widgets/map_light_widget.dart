import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/managers/navigation_state_notifier.dart';

class MapLightWidget extends ConsumerWidget {
  const MapLightWidget({
    Key? key,
    required this.onMapTapListener,
    required this.onMapCreated,
    required this.onScrollListener,
    this.onCameraChangeListener,
    this.isFollowingLocation = false,
  }) : super(key: key);

  final void Function(mbm.MapContentGestureContext context) onMapTapListener;
  final void Function(mbm.MapboxMap mapboxMap) onMapCreated;
  final void Function(mbm.MapContentGestureContext context) onScrollListener;
  final void Function(mbm.CameraChangedEventData data)? onCameraChangeListener;
  final bool isFollowingLocation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double? heading;
    if (Platform.isAndroid) {
      // Android isn't compatible with FollowPuckViewportStateBearingCourse,
      // so use manual heading value.
      heading = ref.watch(navigationStateProvider).userPosition?.heading;
    }
    return mbm.MapWidget(
      styleUri: kMapStyleDefaultUri,
      onTapListener: onMapTapListener,
      onCameraChangeListener: onCameraChangeListener,
      cameraOptions: mbm.CameraOptions(
          zoom: kDefaultCameraState.zoom,
          center: kDefaultCameraState.center,
          bearing: kDefaultCameraState.bearing,
          padding: kDefaultCameraState.padding,
          pitch: kDefaultCameraState.pitch),
      onMapCreated: onMapCreated,
      onScrollListener: onScrollListener,
      viewport: isFollowingLocation
          ? mbm.FollowPuckViewportState(
              pitch: null,
              bearing: defaultTargetPlatform == TargetPlatform.android
                  ? heading != null
                      ? mbm.FollowPuckViewportStateBearingConstant(heading)
                      : const mbm.FollowPuckViewportStateBearingHeading()
                  : const mbm.FollowPuckViewportStateBearingCourse(),
            )
          : const mbm.CameraViewportState(),
    );
  }
}
