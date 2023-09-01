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
const double kRouteInactiveLineOpacity = 0.6;
final double kDevicePixelRatio =
    WidgetsBinding.instance.window.devicePixelRatio;

final CameraState kDefaultCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: kDevicePixelRatio * 50.0, left: 0.0, bottom: 0.0, right: 0.0),
    zoom: 12,
    bearing: 0,
    pitch: 0);

final CameraState kRouteCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: kDevicePixelRatio * 240,
        left: kDevicePixelRatio * 40,
        bottom: kDevicePixelRatio * 220,
        right: kDevicePixelRatio * 40),
    zoom: 12,
    bearing: 0,
    pitch: 0);

final CameraState kPostDetailsCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: kDevicePixelRatio * 0,
        left: kDevicePixelRatio * 40,
        bottom: kDevicePixelRatio * 150,
        right: kDevicePixelRatio * 40),
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

final kAndroidTopOffset = Platform.isAndroid ? 80 : 0;
final kMapUiPadding = kDevicePixelRatio * 6;
final kMapUiPaddingRight = kDevicePixelRatio * 70;
final kMapUiTopOffset =
    kDevicePixelRatio * 60 + kMapUiPadding + kAndroidTopOffset;

final CompassSettings kDefaultCompassSettings = CompassSettings(
    position: OrnamentPosition.TOP_RIGHT,
    marginTop: kMapUiTopOffset,
    marginBottom: 0,
    marginLeft: 0,
    marginRight: kMapUiPaddingRight);

final CompassSettings kPostDetailsCompassSettings = CompassSettings(
    position: OrnamentPosition.TOP_RIGHT,
    marginTop: 0,
    marginBottom: 0,
    marginLeft: 0,
    marginRight: kMapUiPaddingRight);

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
    marginTop: 0,
    marginBottom: 0,
    marginLeft: kMapUiPadding,
    marginRight: 0);

final AttributionSettings kDefaultAttributionSettings = AttributionSettings(
    position: OrnamentPosition.BOTTOM_LEFT,
    marginTop: 0,
    marginBottom: kMapUiPadding,
    marginLeft: kDevicePixelRatio * 90 + kMapUiPadding,
    marginRight: 0);
