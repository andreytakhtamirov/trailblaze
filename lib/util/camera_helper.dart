import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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
      List<Map<String?, Object?>> coordinatesList, CameraOptions camera) {
    final padding = MbxEdgeInsets(
      top: (camera.padding?.top ?? 0) + kFeaturesCameraState.padding.top,
      left: (camera.padding?.left ?? 0) + kFeaturesCameraState.padding.left,
      bottom: (camera.padding?.bottom ?? 0) + kFeaturesCameraState.padding.bottom,
      right: (camera.padding?.right ?? 0) + kFeaturesCameraState.padding.right,
    );
    return mapboxMap.cameraForCoordinates(
        coordinatesList, padding, camera.bearing, camera.pitch);
  }

  static Future<CameraOptions> cameraOptionsForRoute(
      MapboxMap mapboxMap, TrailblazeRoute route, CameraOptions camera) {
    final padding = MbxEdgeInsets(
      top: (camera.padding?.top ?? 0) + kRouteCameraState.padding.top,
      left: (camera.padding?.left ?? 0) + kRouteCameraState.padding.left,
      bottom: (camera.padding?.bottom ?? 0) + kRouteCameraState.padding.bottom,
      right: (camera.padding?.right ?? 0) + kRouteCameraState.padding.right,
    );
    return mapboxMap.cameraForGeometry(
        route.geometryJson, padding, camera.bearing, camera.pitch);
  }
}
