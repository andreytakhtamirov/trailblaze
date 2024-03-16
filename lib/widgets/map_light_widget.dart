import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:trailblaze/constants/map_constants.dart';

class MapLightWidget extends StatelessWidget {
  const MapLightWidget({
    Key? key,
    required this.onMapTapListener,
    required this.onMapCreated,
    required this.onScrollListener,
  }) : super(key: key);

  final void Function(mbm.ScreenCoordinate coordinate) onMapTapListener;
  final void Function(mbm.MapboxMap mapboxMap) onMapCreated;
  final void Function(mbm.ScreenCoordinate coordinate) onScrollListener;

  @override
  Widget build(BuildContext context) {
    return mbm.MapWidget(
      styleUri: kMapStyleDefaultUri,
      onTapListener: onMapTapListener,
      cameraOptions: mbm.CameraOptions(
          zoom: kDefaultCameraState.zoom,
          center: kDefaultCameraState.center,
          bearing: kDefaultCameraState.bearing,
          padding: kDefaultCameraState.padding,
          pitch: kDefaultCameraState.pitch),
      onMapCreated: onMapCreated,
      onScrollListener: onScrollListener,
    );
  }
}
