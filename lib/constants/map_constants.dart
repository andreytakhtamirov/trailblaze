import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

final String kMapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

const int kMapFlyToDuration = 100;
const int kPolylinePrecision = 6;
const String kRouteSourceId = "route-source-id";
const String kRouteLayerId = "route-layer-id";
const double kRouteLineWidth = 6.0;
const double kRouteActiveLineOpacity = 0.9;
const double kRouteInactiveLineOpacity = 1.0;
final double kDevicePixelRatio =
    WidgetsBinding.instance.window.devicePixelRatio;

final CameraState kDefaultCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: 50.0, left: 0.0, bottom: 0.0, right: 0.0),
    zoom: 12,
    bearing: 0,
    pitch: 0);

final CameraState kRouteCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: 250,
        left: 30,
        bottom: 210,
        right: 30),
    zoom: 12,
    bearing: 0,
    pitch: 0);

final CameraState kPostDetailsCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: 40,
        left: 30,
        bottom: 240,
        right: 30),
    zoom: 12,
    bearing: 0,
    pitch: 0);

const kMapStyleUriPrefix = 'mapbox://styles/mapbox';
const kMapStyleOutdoors = 'outdoors-v12';
const kMapStyleSatellite = 'satellite-streets-v12';
const kMapStyleDefaultUri = '$kMapStyleUriPrefix/$kMapStyleOutdoors';

const List<String> kMapStyleOptions = [
  kMapStyleOutdoors,
  kMapStyleSatellite,
];

final kMapTopOffset = Platform.isAndroid ? 8.0 : 0.0;
final kAndroidTopOffset = Platform.isAndroid ? 32.0 : 0.0;
const kMapUiPadding = 14.0;
const kCompassTopOffset = 32.0;
final kMapUiTopOffset =
    48.0 + kMapUiPadding + kAndroidTopOffset;
const kAttributionLeftOffset = kMapUiPadding + 80.0;
const kAttributionBottomOffset = 8.0;

final CompassSettings kDefaultCompassSettings = CompassSettings(
    position: OrnamentPosition.TOP_LEFT,
    marginTop: kMapUiTopOffset + kCompassTopOffset,
    marginBottom: 0,
    marginLeft: kMapUiPadding,
    marginRight: 0);

final CompassSettings kPostDetailsCompassSettings = CompassSettings(
    position: OrnamentPosition.TOP_LEFT,
    marginTop: kMapUiPadding + kCompassTopOffset,
    marginBottom: 0,
    marginLeft: kMapUiPadding,
    marginRight: 0);

final ScaleBarSettings kDefaultScaleBarSettings = ScaleBarSettings(
    isMetricUnits: true,
    position: OrnamentPosition.TOP_LEFT,
    marginTop: kMapUiTopOffset,
    marginBottom: 0,
    marginLeft: kMapUiPadding,
    marginRight: 0);

final ScaleBarSettings kPostDetailsScaleBarSettings = ScaleBarSettings(
    isMetricUnits: true,
    position: OrnamentPosition.TOP_LEFT,
    marginTop: kMapUiPadding,
    marginBottom: 0,
    marginLeft: kMapUiPadding,
    marginRight: 0);

final AttributionSettings kDefaultAttributionSettings = AttributionSettings(
    position: OrnamentPosition.BOTTOM_LEFT,
    marginTop: 0,
    marginBottom: kAttributionBottomOffset,
    marginLeft: kAttributionLeftOffset,
    marginRight: 0);
