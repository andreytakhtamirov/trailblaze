import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

final String kMapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

const int kPolylinePrecision = 6;
const String kRouteSourceId = "route-source-id";
const String kRouteLayerId = "route-layer-id";
const double kRouteLineWidth = 6.0;
const double kRouteActiveLineOpacity = 1.0;
const double kRouteInactiveLineOpacity = 0.8;
final double kDevicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;

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
        top: kDevicePixelRatio * 300,
        left: kDevicePixelRatio * 40,
        bottom: kDevicePixelRatio * 200,
        right: kDevicePixelRatio * 40),
    zoom: 12,
    bearing: 0,
    pitch: 0);

final CameraState kPostDetailsCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: kDevicePixelRatio * 0,
        left: kDevicePixelRatio * 40,
        bottom: kDevicePixelRatio * 50,
        right: kDevicePixelRatio * 40),
    zoom: 12,
    bearing: 0,
    pitch: 0);

final kAndroidTopOffset = Platform.isAndroid ? 80 : 0;
final kMapUiPadding = kDevicePixelRatio * 6;
final kMapUiTopOffset = kDevicePixelRatio * 60 + kMapUiPadding + kAndroidTopOffset;

final CompassSettings kDefaultCompassSettings = CompassSettings(
    position: OrnamentPosition.TOP_RIGHT,
    marginTop: kMapUiTopOffset,
    marginBottom: 0,
    marginLeft: 0,
    marginRight: kMapUiPadding);

final ScaleBarSettings defaultScaleBarSettings = ScaleBarSettings(
    isMetricUnits: true,
    position: OrnamentPosition.TOP_LEFT,
    marginTop: kMapUiTopOffset,
    marginBottom: 0,
    marginLeft: kMapUiPadding,
    marginRight: 0);

final AttributionSettings defaultAttributionSettings = AttributionSettings(
    position: OrnamentPosition.BOTTOM_LEFT,
    marginTop: 0,
    marginBottom: kMapUiPadding,
    marginLeft: kDevicePixelRatio * 90 + kMapUiPadding,
    marginRight: 0);
