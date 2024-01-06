import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/feature.dart' as tb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'dart:math' as math;
import 'package:turf/turf.dart' as turf;

class AnnotationHelper {
  mbm.PointAnnotationManager? _annotationManager;
  final mbm.CircleAnnotationManager? _circleAnnotationManager;
  final List<mbm.PointAnnotationOptions> pointAnnotations = [];
  final List<mbm.CircleAnnotation> circleAnnotations = [];

  AnnotationHelper(this._annotationManager, this._circleAnnotationManager);

  static Future<tb.Feature?> getFeatureByClickProximity(
      List<tb.Feature> features,
      num touchLon,
      num touchLat,
      double currentZoom) async {
    tb.Feature? closestFeature;
    num? closestDistance;

    for (tb.Feature feature in features) {
      final point1Coordinates = mbm.Point(
        coordinates: mbm.Position(feature.center['lon'], feature.center['lat']),
      );
      final point2Coordinates = mbm.Point(
        coordinates: mbm.Position(touchLon, touchLat),
      );

      final distance = turf.distance(
          point1Coordinates, point2Coordinates, turf.Unit.kilometers);

      // Click proximity should become larger the more zoomed out the camera is
      //  (the smaller the zoom value) to account for reduced touch accuracy.
      final threshHold = 1000000 / math.pow(currentZoom, 6);

      if (distance < threshHold) {
        if (closestDistance == null || distance < closestDistance) {
          closestDistance = distance;
          closestFeature = feature;
        }
      }
    }

    return closestFeature;
  }

  void drawSingleAnnotation(Map<String?, Object?>? geometry) async {
    final ByteData bytes = await rootBundle.load('assets/location-pin.png');
    final Uint8List list = bytes.buffer.asUint8List();

    var options = mbm.PointAnnotationOptions(geometry: geometry, image: list, iconSize: kLocationPinSize);
    final annotation = await showAnnotation(options);
    if (annotation != null) {
      pointAnnotations.add(options);
    }
  }

  void drawCircleAnnotationMulti(
      List<Map<String?, Object?>?> geometryList) async {
    List<mbm.CircleAnnotationOptions> optionsList = [];
    await _circleAnnotationManager?.deleteAll();

    for (var i = 0; i < geometryList.length; i++) {
      var options = mbm.CircleAnnotationOptions(
          geometry: geometryList[i],
          circleStrokeColor: Colors.red.value,
          circleColor: Colors.white.value,
          circleStrokeWidth: kFeaturePinSize);
      optionsList.add(options);
    }

    final annotations =
        await _circleAnnotationManager?.createMulti(optionsList);

    if (annotations != null) {
      circleAnnotations.addAll(annotations.whereType<mbm.CircleAnnotation>());
    }
  }

  void drawAllAnnotations(
      Future<mbm.PointAnnotationManager> annotationManager) async {
    await _annotationManager?.deleteAll();
    _annotationManager = await annotationManager;

    for (mbm.PointAnnotationOptions options in pointAnnotations) {
      showAnnotation(options);
    }
  }

  Future<mbm.PointAnnotation?> showAnnotation(
      mbm.PointAnnotationOptions options) async {
    if (_annotationManager != null) {
      return _annotationManager!.create(options);
    } else {
      return null;
    }
  }

  Future<void> deleteAllAnnotations() async {
    await deletePointAnnotations();
    await deleteCircleAnnotations();
  }

  Future<void> deletePointAnnotations() async {
    pointAnnotations.clear();

    if (_annotationManager != null) {
      await _annotationManager!.deleteAll();
    }
  }

  Future<void> deleteCircleAnnotations() async {
    circleAnnotations.clear();
    if (_circleAnnotationManager != null) {
      await _circleAnnotationManager.deleteAll();
    }
  }
}
