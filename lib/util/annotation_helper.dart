import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/feature.dart' as tb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/util/distance_helper.dart';
import 'dart:math' as math;
import 'package:turf/turf.dart' as turf;

class AnnotationHelper implements mbm.OnCircleAnnotationClickListener {
  final mbm.PointAnnotationManager _annotationManager;
  final mbm.CircleAnnotationManager _circleAnnotationManager;
  final mbm.CircleAnnotationManager _ignoreAnnotationManager;
  final mbm.PolygonAnnotationManager _polygonAnnotationManager;
  final List<mbm.PointAnnotationOptions> pointAnnotations = [];
  final List<mbm.CircleAnnotation> circleAnnotations = [];
  final List<mbm.CircleAnnotation> ignoreAnnotations = [];
  final List<mbm.PolygonAnnotation> polygonAnnotations = [];
  mbm.CircleAnnotation? selectOriginAnnotation;

  AnnotationHelper(
    this._annotationManager,
    this._circleAnnotationManager,
    this._ignoreAnnotationManager,
    this._polygonAnnotationManager,
  );

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

  static Future<mbm.CircleAnnotation?> getCircleAnnotationByClickProximity(
      List<mbm.CircleAnnotation> annotations,
      num touchLon,
      num touchLat,
      double currentZoom) async {
    mbm.CircleAnnotation? closest;
    num? closestDistance;

    final touchCoordinates = mbm.Point(
      coordinates: mbm.Position(touchLon, touchLat),
    );

    for (mbm.CircleAnnotation a in annotations) {
      final distance =
          turf.distance(a.geometry, touchCoordinates, turf.Unit.kilometers);
      if (distance < _getCurrentThreshold(currentZoom)) {
        if (closestDistance == null || distance < closestDistance) {
          closestDistance = distance;
          closest = a;
        }
      }
    }

    return closest;
  }

  static double _getCurrentThreshold(double zoom) {
    // Click proximity should become larger the more zoomed out the camera is
    //  (the smaller the zoom value) to account for reduced touch accuracy.
    return 1000000 / math.pow(zoom, 6);
  }

  void drawSingleAnnotation(mbm.Position coordinates) async {
    final ByteData bytes = await rootBundle.load('assets/location-pin.png');
    final Uint8List list = bytes.buffer.asUint8List();

    var options = mbm.PointAnnotationOptions(
      geometry: mbm.Point(coordinates: coordinates),
      image: list,
      iconSize: kLocationPinSize,
    );
    final annotation = await showAnnotation(options);
    if (annotation != null) {
      pointAnnotations.add(options);
    }
  }

  Future<void> drawIgnoreAnnotation(mbm.Position coordinates) async {
    var options = mbm.CircleAnnotationOptions(
      geometry: mbm.Point(coordinates: coordinates),
      circleStrokeColor: Colors.red.value,
      circleColor: Colors.white.value,
      circleStrokeWidth: kFeaturePinSize,
    );

    final annotation = await _ignoreAnnotationManager.create(options);
    ignoreAnnotations.add(annotation);
    _ignoreAnnotationManager.addOnCircleAnnotationClickListener(this);
  }

  void drawPolygonAnnotation() async {
    await _polygonAnnotationManager.deleteAll();
    final poly = getIgnorePolygon();
    var options = mbm.PolygonAnnotationOptions(
      geometry: poly,
      fillColor: Colors.red.value,
      fillOpacity: 0.5,
      fillSortKey: 2,
    );
    final annotation = await _polygonAnnotationManager.create(options);
    polygonAnnotations.add(annotation);
  }

  mbm.Polygon getIgnorePolygon() {
    List<mbm.Position> coordinates = [];
    for (int i = 0; i < ignoreAnnotations.length; i++) {
      coordinates.add(ignoreAnnotations[i].geometry.coordinates);
    }

    return mbm.Polygon(coordinates: [DistanceHelper.buildPolygon(coordinates)]);
  }

  void drawCircleAnnotationMulti(List<mbm.Point> points) async {
    List<mbm.CircleAnnotationOptions> optionsList = [];
    await _circleAnnotationManager.deleteAll();

    for (var i = 0; i < points.length; i++) {
      var options = mbm.CircleAnnotationOptions(
        geometry: points[i],
        circleStrokeColor: Colors.red.value,
        circleColor: Colors.white.value,
        circleStrokeWidth: kFeaturePinSize,
      );
      optionsList.add(options);
    }

    final annotations = await _circleAnnotationManager.createMulti(optionsList);
    circleAnnotations.addAll(annotations.whereType<mbm.CircleAnnotation>());
  }

  void drawOriginAnnotation(mbm.Position coordinates) async {
    deleteOriginAnnotation();

    var options = mbm.CircleAnnotationOptions(
      geometry: mbm.Point(coordinates: coordinates),
      circleRadius: 10,
      circleStrokeColor: Colors.purpleAccent.value,
      circleColor: Colors.white.value,
      circleStrokeWidth: 8,
    );

    selectOriginAnnotation = await _circleAnnotationManager.create(options);
  }

  void drawStartAnnotation(mbm.Position coordinates) async {
    await _circleAnnotationManager.deleteAll();

    var options = mbm.CircleAnnotationOptions(
      geometry: mbm.Point(coordinates: coordinates),
      circleRadius: 8,
      circleStrokeColor: Colors.white.value,
      circleColor: Colors.deepOrangeAccent.value,
      circleStrokeWidth: 4,
    );

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

  Future<void> deleteIgnoreAnnotations() async {
    ignoreAnnotations.clear();
    await _ignoreAnnotationManager.deleteAll();
  }

  Future<void> hideIgnoreAnnotations() async {
    await _ignoreAnnotationManager.deleteAll();
  }

  Future<void> showIgnoreAnnotations() async {
    final List<mbm.CircleAnnotationOptions> options = [];
    for (mbm.CircleAnnotation a in ignoreAnnotations) {
      options.add(mbm.CircleAnnotationOptions(
        geometry: a.geometry,
        circleStrokeColor: Colors.red.value,
        circleColor: Colors.white.value,
        circleStrokeWidth: kFeaturePinSize,
      ));
    }
    await _ignoreAnnotationManager.createMulti(options);
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

  @override
  void onCircleAnnotationClick(mbm.CircleAnnotation annotation) {
    _ignoreAnnotationManager.delete(annotation);
    _polygonAnnotationManager.deleteAll();
  }
}
