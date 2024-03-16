import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/feature.dart' as tb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:trailblaze/data/trailblaze_route.dart';
import 'dart:math' as math;
import 'package:turf/turf.dart' as turf;

class AnnotationHelper {
  final mbm.PointAnnotationManager _annotationManager;
  final mbm.CircleAnnotationManager _circleAnnotationManager;
  final List<mbm.PointAnnotationOptions> pointAnnotations = [];
  final List<mbm.CircleAnnotation> circleAnnotations = [];
  mbm.CircleAnnotation? selectOriginAnnotation;

  AnnotationHelper(this._annotationManager, this._circleAnnotationManager);

  static Future<tb.Feature?> getFeatureByClickProximity(
      List<tb.Feature> features,
      num touchLon,
      num touchLat,
      double currentZoom) async {
    tb.Feature? closestFeature;
    num? closestDistance;

    final touchCoordinates = mbm.Point(
      coordinates: mbm.Position(touchLon, touchLat),
    );

    for (tb.Feature feature in features) {
      final featureCoordinates = mbm.Point(
        coordinates: mbm.Position(feature.center['lon'], feature.center['lat']),
      );

      final distance = turf.distance(
          featureCoordinates, touchCoordinates, turf.Unit.kilometers);
      if (distance < _getCurrentThreshold(currentZoom)) {
        if (closestDistance == null || distance < closestDistance) {
          closestDistance = distance;
          closestFeature = feature;
        }
      }
    }

    return closestFeature;
  }

  static Future<TrailblazeRoute?> getRouteByClickProximity(
      List<TrailblazeRoute> routes,
      num touchLon,
      num touchLat,
      double currentZoom) async {
    TrailblazeRoute? closestRoute;
    num? closestDistance;

    final touchCoordinates = mbm.Point(
      coordinates: mbm.Position(touchLon, touchLat),
    );

    for (TrailblazeRoute route in routes) {
      if (route.coordinates == null) {
        continue;
      }
      for (List<dynamic> coordinate in route.coordinates!) {
        final featureCoordinates = mbm.Point(
          coordinates: mbm.Position(coordinate[0], coordinate[1]),
        );

        final distance = turf.distance(
            featureCoordinates, touchCoordinates, turf.Unit.kilometers);
        if (distance < _getCurrentThreshold(currentZoom)) {
          if (closestDistance == null || distance < closestDistance) {
            closestDistance = distance;
            closestRoute = route;
          }
        }
      }
    }

    return closestRoute;
  }

  static double _getCurrentThreshold(double zoom) {
    // Click proximity should become larger the more zoomed out the camera is
    //  (the smaller the zoom value) to account for reduced touch accuracy.
    return 1000000 / math.pow(zoom, 6);
  }

  void drawSingleAnnotation(Map<String?, Object?>? geometry) async {
    final ByteData bytes = await rootBundle.load('assets/location-pin.png');
    final Uint8List list = bytes.buffer.asUint8List();

    var options = mbm.PointAnnotationOptions(
        geometry: geometry, image: list, iconSize: kLocationPinSize);
    final annotation = await showAnnotation(options);
    if (annotation != null) {
      pointAnnotations.add(options);
    }
  }

  void drawCircleAnnotationMulti(
      List<Map<String?, Object?>?> geometryList) async {
    List<mbm.CircleAnnotationOptions> optionsList = [];
    await _circleAnnotationManager.deleteAll();

    for (var i = 0; i < geometryList.length; i++) {
      var options = mbm.CircleAnnotationOptions(
          geometry: geometryList[i],
          circleStrokeColor: Colors.red.value,
          circleColor: Colors.white.value,
          circleStrokeWidth: kFeaturePinSize);
      optionsList.add(options);
    }

    final annotations = await _circleAnnotationManager.createMulti(optionsList);
    circleAnnotations.addAll(annotations.whereType<mbm.CircleAnnotation>());
  }

  void drawOriginAnnotation(Map<String?, Object?> geometry) async {
    deleteOriginAnnotation();

    var options = mbm.CircleAnnotationOptions(
        geometry: geometry,
        circleRadius: 10,
        circleStrokeColor: Colors.purpleAccent.value,
        circleColor: Colors.white.value,
        circleStrokeWidth: 8);

    selectOriginAnnotation = await _circleAnnotationManager.create(options);
  }

  void drawStartAnnotation(Map<String?, Object?> geometry) async {
    await _circleAnnotationManager.deleteAll();

    var options = mbm.CircleAnnotationOptions(
        geometry: geometry,
        circleRadius: 8,
        circleStrokeColor: Colors.white.value,
        circleColor: Colors.deepOrangeAccent.value,
        circleStrokeWidth: 4);

    final annotation = await _circleAnnotationManager.create(options);
    circleAnnotations.add(annotation);
  }

  Future<mbm.PointAnnotation?> showAnnotation(
      mbm.PointAnnotationOptions options) async {
    return _annotationManager.create(options);
  }

  Future<void> deleteAllAnnotations() async {
    await deletePointAnnotations();
    await deleteCircleAnnotations();
  }

  Future<void> deletePointAnnotations() async {
    pointAnnotations.clear();
    await _annotationManager.deleteAll();
  }

  Future<void> deleteCircleAnnotations() async {
    circleAnnotations.clear();
    await _circleAnnotationManager.deleteAll();
  }

  Future<void> deleteOriginAnnotation() async {
    if (selectOriginAnnotation != null) {
      try {
        await _circleAnnotationManager.delete(selectOriginAnnotation!);
      } catch (e) {
        // Already deleted by manager.deleteAll()
      }
      selectOriginAnnotation = null;
    }
  }
}
