import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

final String mapboxAccessToken = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

const int polylinePrecision = 6;
const String routeSourceId = "route-source-id";
const String routeLayerId = "route-layer-id";
const double routeLineWidth = 4.0;
final double devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;

final CameraState defaultCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: devicePixelRatio * 50.0, left: 0.0, bottom: 0.0, right: 0.0),
    zoom: 12,
    bearing: 0,
    pitch: 0);

final CameraState routeCameraState = CameraState(
    center: Point(coordinates: Position(-80.520852, 43.463355)).toJson(),
    padding: MbxEdgeInsets(
        top: devicePixelRatio * 400,
        left: devicePixelRatio * 40,
        bottom: devicePixelRatio * 50,
        right: devicePixelRatio * 40),
    zoom: 12,
    bearing: 0,
    pitch: 0);
