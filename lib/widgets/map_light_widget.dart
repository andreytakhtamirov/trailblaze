import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:trailblaze/constants/map_constants.dart';

class MapLightWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
                  ? const mbm.FollowPuckViewportStateBearingHeading()
                  : const mbm.FollowPuckViewportStateBearingCourse(),
            )
          : const mbm.CameraViewportState(),
    );
  }
}
