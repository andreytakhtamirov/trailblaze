import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';

class CameraHelper {
  static Position interpolatePoints(
    Position centerStart,
    Position centerEnd,
    double fraction,
  ) {
    double lat = centerStart.lat + (centerEnd.lat - centerStart.lat) * fraction;
    double lng = centerStart.lng + (centerEnd.lng - centerStart.lng) * fraction;

    return Position(lng, lat);
  }

  static Future<CameraOptions> cameraOptionsForCoordinates(
    MapboxMap mapboxMap,
    List<Point> points,
    MbxEdgeInsets? padding,
    double maxHeight,
    double maxWidth,
  ) {
    final customPadding = MbxEdgeInsets(
      top: (padding?.top ?? 0) + kFeaturesCameraState.padding.top,
      left: (padding?.left ?? 0) + kFeaturesCameraState.padding.left,
      bottom: (padding?.bottom ?? 0) + kFeaturesCameraState.padding.bottom,
      right: (padding?.right ?? 0) + kFeaturesCameraState.padding.right,
    );

    // For small screen devices where padding might be larger than the screen.
    if (customPadding.top + customPadding.bottom >= maxHeight) {
      final ratio =
          maxHeight / (customPadding.top + customPadding.bottom + 100);
      customPadding.top *= ratio;
      customPadding.bottom *= ratio;
    }
    if (customPadding.right + customPadding.left >= maxWidth) {
      customPadding.right -= kFeaturesCameraState.padding.right;
      customPadding.left -= kFeaturesCameraState.padding.left;
    }

    return mapboxMap.cameraForCoordinatesPadding(
        points, CameraOptions(), customPadding, null, null);
  }

  static Future<CameraOptions> cameraOptionsForRoute(
    MapboxMap mapboxMap,
    TrailblazeRoute route,
    MbxEdgeInsets? padding,
    double maxHeight,
    double maxWidth,
  ) async {
    return cameraOptionsForGeometry(
        mapboxMap, route.geometryJson, padding, maxHeight, maxWidth);
  }

  static Future<CameraOptions> cameraOptionsForGeometry(
    MapboxMap mapboxMap,
    Map<String?, Object?> geometryJson,
    MbxEdgeInsets? padding,
    double maxHeight,
    double maxWidth,
  ) async {
    final customPadding = MbxEdgeInsets(
      top: (padding?.top ?? 0) +
          kRouteCameraState.padding.top,
      left: (padding?.left ?? 0) + kRouteCameraState.padding.left,
      bottom: (padding?.bottom ?? 0) +
          kRouteCameraState.padding.bottom,
      right: (padding?.right ?? 0) + kRouteCameraState.padding.right,
    );

    // For small screen devices where padding might be larger than the screen.
    if (customPadding.top + customPadding.bottom >= maxHeight) {
      final ratio =
          maxHeight / (customPadding.top + customPadding.bottom + 100);
      customPadding.top *= ratio;
      customPadding.bottom *= ratio;
    }
    if (customPadding.right + customPadding.left >= maxWidth) {
      customPadding.right -= kRouteCameraState.padding.right;
      customPadding.left -= kRouteCameraState.padding.left;
    }

    final cameraForRoute = await mapboxMap.cameraForGeometry(
      geometryJson,
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

  static MapBoxPlace getMapBoxPlaceFromLonLat(
      List<double>? coordinates, String placeName) {
    return MapBoxPlace(placeName: placeName, center: coordinates);
  }

  static Future<double> distanceFromMap(
      MapboxMap map, double screenSize) async {
    final camera = await map.getCameraState();
    final zoom = camera.zoom;
    final distance = await map.projection.getMetersPerPixelAtLatitude(
            camera.center.coordinates.lat.toDouble(), zoom) *
        screenSize;
    return distance;
  }
}
