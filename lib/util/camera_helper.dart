import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';

class CameraHelper {
  static Map<String?, Object?> interpolatePoints(
    Map<String?, Object?> centerStart,
    Map<String?, Object?> centerEnd,
    double fraction,
  ) {
    List<dynamic>? startCoordinates =
        centerStart['coordinates'] as List<dynamic>?;
    List<dynamic>? endCoordinates = centerEnd['coordinates'] as List<dynamic>?;

    if (startCoordinates != null && endCoordinates != null) {
      double lat = startCoordinates[1] +
          (endCoordinates[1] - startCoordinates[1]) * fraction;
      double lng = startCoordinates[0] +
          (endCoordinates[0] - startCoordinates[0]) * fraction;

      return {
        'coordinates': [lng, lat],
      };
    } else {
      // Handle null or invalid coordinates
      return {};
    }
  }

  static Future<CameraOptions> cameraOptionsForCoordinates(MapboxMap mapboxMap,
      List<Map<String?, Object?>> coordinatesList, MbxEdgeInsets? padding) {
    final customPadding = MbxEdgeInsets(
      top: (padding?.top ?? 0) + kFeaturesCameraState.padding.top,
      left: (padding?.left ?? 0) + kFeaturesCameraState.padding.left,
      bottom:
          (padding?.bottom ?? 0) + kFeaturesCameraState.padding.bottom,
      right: (padding?.right ?? 0) + kFeaturesCameraState.padding.right,
    );
    return mapboxMap.cameraForCoordinates(
        coordinatesList, customPadding, null, null);
  }

  static Future<CameraOptions> cameraOptionsForRoute(
    MapboxMap mapboxMap,
    TrailblazeRoute route,
    MbxEdgeInsets? padding, {
    bool extraPadding = false,
  }) async {
    num topBottomPadding;
    if (extraPadding) {
      topBottomPadding = kDefaultCameraState.padding.top;
    } else {
      topBottomPadding = 0;
    }

    final customPadding = MbxEdgeInsets(
      top: (padding?.top ?? 0) +
          kRouteCameraState.padding.top +
          topBottomPadding,
      left: (padding?.left ?? 0) + kRouteCameraState.padding.left,
      bottom: (padding?.bottom ?? 0) +
          kRouteCameraState.padding.bottom +
          topBottomPadding,
      right: (padding?.right ?? 0) + kRouteCameraState.padding.right,
    );

    final cameraForRoute = await mapboxMap.cameraForGeometry(
      route.geometryJson,
      customPadding,
      null,
      null,
    );

    return CameraOptions(
      center: cameraForRoute.center,
      pitch: cameraForRoute.pitch,
      zoom: cameraForRoute.zoom,
      anchor: cameraForRoute.anchor,
      padding: cameraForRoute.padding,
      bearing: cameraForRoute.bearing,
    );
  }

  static MapBoxPlace getMapBoxPlaceFromLonLat(List<double>? coordinates) {
    return MapBoxPlace(placeName: "Camera Bounds", center: coordinates);
  }

  static List<double>? centerToCoordinatesLonLat(Map<String?, Object?> center) {
    return (center['coordinates'] is List<dynamic>)
        ? List<double>.from(center['coordinates'] as List<dynamic>)
        : null;
  }

  static Future<double> distanceFromMap(
      MapboxMap map, double screenSize) async {
    final camera = await map.getCameraState();
    final zoom = camera.zoom;
    final distance = await map.projection.getMetersPerPixelAtLatitude(
            centerToCoordinatesLonLat(camera.center)![1], zoom) *
        screenSize;
    return distance;
  }
}
