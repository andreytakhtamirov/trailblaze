import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/annotation_state.dart';
import 'package:trailblaze/data/feature.dart' as tb;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/util/distance_helper.dart';
import 'dart:math' as math;
import 'package:turf/turf.dart' as turf;
import 'package:undo/undo.dart';

class AnnotationAction {
  final mbm.CircleAnnotation annotation;
  final bool isAdded;

  AnnotationAction(this.annotation, this.isAdded);
}

class AnnotationHelper implements mbm.OnCircleAnnotationClickListener {
  final mbm.PointAnnotationManager _annotationManager;
  final mbm.PointAnnotationManager _pointAnnotationManager;
  final mbm.CircleAnnotationManager _circleAnnotationManager;
  final mbm.CircleAnnotationManager _metricAnnotationManager;
  final mbm.CircleAnnotationManager _avoidAnnotationManager;
  final mbm.PolygonAnnotationManager _polygonAnnotationManager;
  final Function() onAvoidAnnotationClick;

  late final Uint8List _poiAnnotationImage;
  late final Uint8List _locationPinImage;
  final List<mbm.PointAnnotationOptions> pointAnnotations = [];
  final List<mbm.CircleAnnotation> circleAnnotations = [];
  List<mbm.CircleAnnotation> avoidAnnotations = [];
  final List<mbm.PolygonAnnotation> polygonAnnotations = [];
  mbm.CircleAnnotation? selectOriginAnnotation;
  mbm.CircleAnnotation? _metricAnnotation;

  late final SimpleStack _avoidAnnotationChanges;

  final List<AnnotationState> _annotationStates = [];
  final Map<String, int> _currentClusters = {};
  final Map<String, mbm.PointAnnotation> _activeAnnotations = {};

  // List of clusters (each cluster is a list of annotations)
  final List<List<AnnotationState>> _clusters = [];

  AnnotationHelper(
    this._annotationManager,
    this._pointAnnotationManager,
    this._circleAnnotationManager,
    this._metricAnnotationManager,
    this._avoidAnnotationManager,
    this._polygonAnnotationManager,
    this.onAvoidAnnotationClick,
  ) {
    _pointAnnotationManager.setSymbolSortKey(1);
    _pointAnnotationManager.setIconAllowOverlap(false);
    _pointAnnotationManager.setTextAllowOverlap(false);
    _avoidAnnotationChanges = SimpleStack<List<mbm.CircleAnnotation>>(
      [],
      onUpdate: (val) {
        avoidAnnotations.clear();
        avoidAnnotations.addAll(val);
        redrawAvoidAnnotations(val);
      },
    );
    _loadAnnotationImages();
  }

  Future<void> _loadAnnotationImages() async {
    ByteData bytes = await rootBundle.load('assets/feature-puck.png');
    _poiAnnotationImage = bytes.buffer.asUint8List();

    bytes = await rootBundle.load('assets/location-pin.png');
    _locationPinImage = bytes.buffer.asUint8List();
  }

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

    final touchPoint = turf.Point(
        coordinates: turf.Position(
      touchLon.toDouble(),
      touchLat.toDouble(),
    ));

    for (TrailblazeRoute route in routes) {
      if (route.coordinates == null || route.coordinates!.isEmpty) {
        continue;
      }

      List<turf.Position> lineCoordinates = route.coordinates!
          .map((coordinate) =>
              turf.Position(coordinate[0].toDouble(), coordinate[1].toDouble()))
          .toList();

      final routeLine = turf.LineString(coordinates: lineCoordinates);
      final nearestPoint = turf
          .nearestPointOnLine(
            routeLine,
            touchPoint,
          )
          .geometry;

      if (nearestPoint == null) {
        continue;
      }

      final distance = turf.distance(
        nearestPoint,
        touchPoint,
        turf.Unit.kilometers,
      );

      if (distance < _getCurrentThreshold(currentZoom)) {
        if (closestDistance == null || distance < closestDistance) {
          closestDistance = distance;
          closestRoute = route;
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

  Future<void> drawSingleAnnotation(mbm.Position coordinates) async {
    var options = mbm.PointAnnotationOptions(
      geometry: mbm.Point(coordinates: coordinates),
      image: _locationPinImage,
      iconSize: kLocationPinSize,
    );
    final annotation = await showAnnotation(options);
    if (annotation != null) {
      pointAnnotations.add(options);
    }
  }

  Future<void> showAvoidAnnotation(mbm.Position coordinates) async {
    var options = mbm.CircleAnnotationOptions(
      geometry: mbm.Point(coordinates: coordinates),
      circleStrokeColor: Colors.red.value,
      circleColor: Colors.white.value,
      circleStrokeWidth: kFeaturePinSize,
    );

    drawAvoidAnnotation(await _avoidAnnotationManager.create(options));
  }

  Future<void> drawAvoidAnnotation(mbm.CircleAnnotation annotation) async {
    avoidAnnotations.add(annotation);
    _avoidAnnotationManager.addOnCircleAnnotationClickListener(this);
    _avoidAnnotationChanges.modify(avoidAnnotations.toList(growable: false));
  }

  Future<void> deleteAvoidAnnotation(mbm.CircleAnnotation annotation) async {
    await _avoidAnnotationManager.delete(annotation);
    avoidAnnotations
        .removeWhere((item) => item.geometry == annotation.geometry);
    _avoidAnnotationChanges.modify(avoidAnnotations.toList(growable: false));
  }

  void drawPolygonAnnotation() async {
    final poly = getAvoidPolygon();
    if (poly == null) {
      return;
    }

    await _polygonAnnotationManager.deleteAll();
    var options = mbm.PolygonAnnotationOptions(
      geometry: poly,
      fillColor: Colors.red.value,
      fillOpacity: 0.6,
      fillSortKey: 2,
      fillOutlineColor: Colors.black.value,
    );
    final annotation = await _polygonAnnotationManager.create(options);
    polygonAnnotations.add(annotation);
  }

  mbm.Polygon? getAvoidPolygon() {
    if (avoidAnnotations.length < 3) {
      return null;
    }

    List<mbm.Position> coordinates = [];
    for (int i = 0; i < avoidAnnotations.length; i++) {
      coordinates.add(avoidAnnotations[i].geometry.coordinates);
    }

    return mbm.Polygon(coordinates: [DistanceHelper.buildPolygon(coordinates)]);
  }

  List<mbm.Point>? coordinatesForCluster(tb.Feature feature) {
    final featureId =
        feature.center['lat'].toString() + feature.center['lon'].toString();

    for (List<AnnotationState> cluster in _clusters) {
      if (cluster.any((state) => state.id == featureId)) {
        if (cluster.length == 1) {
          // Single point cluster
          return null;
        }
        return cluster.map((state) {
          return mbm.Point(
            coordinates: mbm.Position(
              state.options.geometry.coordinates.lng,
              state.options.geometry.coordinates.lat,
            ),
          );
        }).toList();
      }
    }

    return null;
  }

  Future<void> drawPointAnnotationMulti(List<tb.Feature> features) async {
    List<mbm.PointAnnotationOptions> optionsList = [];
    for (tb.Feature feature in features) {
      final state = AnnotationState.fromFeature(feature, _poiAnnotationImage);
      _annotationStates.add(state);
      optionsList.add(state.options);
    }

    final annotations = await _pointAnnotationManager.createMulti(optionsList);
    for (int i = 0; i < annotations.length; i++) {
      mbm.PointAnnotation? a = annotations[i];
      if (a == null) continue;
      _annotationStates[i].annotation = a;
    }
  }

  Future<void> simplifyFeatures(mbm.MapboxMap map) async {
    Set<String> visited = {};
    _clusters.clear();

    for (int i = 0; i < _annotationStates.length; i++) {
      final state1 = _annotationStates[i];
      final point1 = state1.options.geometry;
      final pixelCoord1 = await map.pixelForCoordinate(point1);

      if (pixelCoord1.x == -1 || pixelCoord1.y == -1) {
        // Coordinate isn't on screen (out of camera bounds)
        continue;
      }

      bool merged = false;

      // Check for collisions with other points
      for (int j = i + 1; j < _annotationStates.length; j++) {
        final state2 = _annotationStates[j];
        final point2 = state2.options.geometry;
        final pixelCoord2 = await map.pixelForCoordinate(point2);

        if (pixelCoord2.x == -1 || pixelCoord2.y == -1) {
          continue;
        }

        final distanceInPixels =
            DistanceHelper.calculatePixelDistance(pixelCoord1, pixelCoord2);

        if (distanceInPixels < 22) {
          List<AnnotationState>? cluster1;
          List<AnnotationState>? cluster2;

          // Find existing clusters for state1 and state2
          for (var cluster in _clusters) {
            if (cluster.contains(state1)) cluster1 = cluster;
            if (cluster.contains(state2)) cluster2 = cluster;
          }

          if (cluster1 != null && cluster2 != null && cluster1 != cluster2) {
            // Merge the two clusters if they are different
            cluster1.addAll(cluster2);
            _clusters.remove(cluster2);
          } else if (cluster1 != null) {
            // Add state2 to the existing cluster of state1
            if (!cluster1.contains(state2)) {
              cluster1.add(state2);
            }
          } else if (cluster2 != null) {
            // Add state1 to the existing cluster of state2
            if (!cluster2.contains(state1)) {
              cluster2.add(state1);
            }
          } else {
            // Create a new cluster for both points
            _clusters.add([state1, state2]);
          }

          // Mark both points as not visible (collided)
          state1.isClustered = true;
          state2.isClustered = true;

          merged = true;
          visited.add(state1.id);
          visited.add(state2.id);
        }
      }

      // If no merge occurred, mark state1 as a single point
      if (!merged && !visited.contains(state1.id)) {
        state1.isClustered = false;
        _clusters.add([state1]);
      }
    }

    final clustersToRemove = Set<String>.from(_currentClusters.keys);

    for (int i = 0; i < _clusters.length; i++) {
      if (_clusters[i].length > 1) {
        for (var state in _clusters[i]) {
          state.isClustered = true;
        }

        final p = await _createPointsCluster(_clusters[i]);
        final String clusterKey =
            "${p.geometry.coordinates.lat},${p.geometry.coordinates.lng}";
        _activeAnnotations[clusterKey] = p;
        clustersToRemove.remove(clusterKey);
      } else {
        _clusters[i][0].isClustered = false;
      }
    }

    // Now remove clusters that no longer exist
    for (String clusterKey in clustersToRemove) {
      await _pointAnnotationManager.delete(_activeAnnotations[clusterKey]!);
      _activeAnnotations.remove(clusterKey);
      _currentClusters.remove(clusterKey);
    }

    _drawActiveAnnotations(_annotationStates);
  }

  Future<mbm.PointAnnotation> _createPointsCluster(
      List<AnnotationState> clustered) async {
    double totalLatitude = 0.0;
    double totalLongitude = 0.0;

    // Find the midpoint for a collection of points to form a cluster
    for (AnnotationState s in clustered) {
      final coordinates = s.options.geometry.coordinates;
      totalLatitude += coordinates.lat;
      totalLongitude += coordinates.lng;

      if (s.annotation != null) {
        // Delete the existing annotation
        await _pointAnnotationManager.delete(s.annotation!);
        s.annotation = null;
      }
    }

    final int pointCount = clustered.length;
    final double midpointLatitude = totalLatitude / pointCount;
    final double midpointLongitude = totalLongitude / pointCount;
    final midpointCoordinates = mbm.Position(
      midpointLongitude,
      midpointLatitude,
    );

    final String clusterKey = "$midpointLatitude,$midpointLongitude";
    // Check if the cluster already exists or needs to be redrawn
    if (_currentClusters.containsKey(clusterKey)) {
      if (_currentClusters[clusterKey] == pointCount) {
        // No change in the cluster, no need to redraw
        return _activeAnnotations[clusterKey]!;
      } else {
        // Cluster count changed, remove the old annotation and redraw
        await _pointAnnotationManager.delete(_activeAnnotations[clusterKey]!);
      }
    }

    _currentClusters[clusterKey] = pointCount;
    return _drawCluster(midpointCoordinates, pointCount.toString());
  }

  Future<mbm.PointAnnotation> _drawCluster(
      mbm.Position coordinates, String label) async {
    final clusterOptions = mbm.PointAnnotationOptions(
      geometry: mbm.Point(coordinates: coordinates),
      image: _poiAnnotationImage,
      iconSize: kLocationPinSize + 0.6,
      textField: label,
      textHaloWidth: 0.5,
      textSize: 20,
      textMaxWidth: 2,
      textEmissiveStrength: 1,
      textHaloColor: const Color.fromRGBO(255, 255, 255, 0.15).value,
      textOcclusionOpacity: 0.4,
      textColor: Colors.white.value,
      symbolSortKey: 10,
    );

    return await _pointAnnotationManager.create(clusterOptions);
  }

  void _drawActiveAnnotations(List<AnnotationState> annotations) async {
    List<mbm.PointAnnotationOptions> annotationsToCreate = [];
    List<AnnotationState> annotationStatesToCreate = [];

    for (AnnotationState s in annotations) {
      if (s.isClustered || s.annotation != null) {
        continue;
      }
      annotationsToCreate.add(s.options);
      annotationStatesToCreate.add(s);
    }

    if (annotationsToCreate.isNotEmpty) {
      final options =
          await _pointAnnotationManager.createMulti(annotationsToCreate);
      for (int i = 0; i < options.length; i++) {
        annotationStatesToCreate[i].annotation = options[i];
      }
    }
  }

  Future<void> clearPointAnnotations() async {
    _clusters.clear();
    _currentClusters.clear();
    _activeAnnotations.clear();
    _annotationStates.clear();
    await _pointAnnotationManager.deleteAll();
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

  Future<void> drawStartAnnotation(mbm.Position coordinates) async {
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

  void drawSingleMetricAnnotation(
      BuildContext context, mbm.Position coordinates) async {
    if (_metricAnnotation == null) {
      var options = mbm.CircleAnnotationOptions(
        geometry: mbm.Point(coordinates: coordinates),
        circleRadius: 10,
        circleStrokeColor: Theme.of(context).colorScheme.primary.value,
        circleColor: Colors.white.value,
        circleStrokeWidth: 4,
      );
      _metricAnnotation = await _metricAnnotationManager.create(options);
    } else {
      _metricAnnotation!.geometry = mbm.Point(coordinates: coordinates);
      await _metricAnnotationManager.update(_metricAnnotation!);
    }
  }

  void deleteMetricAnnotation() async {
    _metricAnnotation = null;
    await _metricAnnotationManager.deleteAll();
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

  Future<void> deleteAvoidArea() async {
    _avoidAnnotationChanges.modify(List<mbm.CircleAnnotation>.empty());
    await _avoidAnnotationManager.deleteAll();
    await _polygonAnnotationManager.deleteAll();
  }

  Future<void> hideAvoidAnnotations() async {
    await _avoidAnnotationManager.deleteAll();
  }

  Future<void> undoLastAction() async {
    _avoidAnnotationChanges.undo();
  }

  Future<void> redoLastAction() async {
    _avoidAnnotationChanges.redo();
  }

  void clearAvoidActionHistory() {
    _avoidAnnotationChanges.clearHistory();
  }

  bool canUndoAvoidAction() {
    return _avoidAnnotationChanges.canUndo;
  }

  bool canRedoAvoidAction() {
    return _avoidAnnotationChanges.canRedo;
  }

  Future<void> showAvoidAnnotations(
      List<mbm.CircleAnnotation> annotations) async {
    final List<mbm.CircleAnnotationOptions> options = [];
    for (mbm.CircleAnnotation a in annotations) {
      options.add(mbm.CircleAnnotationOptions(
        geometry: a.geometry,
        circleStrokeColor: Colors.red.value,
        circleColor: Colors.white.value,
        circleStrokeWidth: kFeaturePinSize,
      ));
    }
    await _avoidAnnotationManager.createMulti(options);
  }

  Future<void> redrawAvoidAnnotations(
      List<mbm.CircleAnnotation> annotations) async {
    final List<mbm.CircleAnnotationOptions> options = [];
    for (mbm.CircleAnnotation a in annotations) {
      options.add(mbm.CircleAnnotationOptions(
        geometry: a.geometry,
        circleStrokeColor: Colors.red.value,
        circleColor: Colors.white.value,
        circleStrokeWidth: kFeaturePinSize,
      ));
    }

    await _polygonAnnotationManager.deleteAll();
    await _avoidAnnotationManager.deleteAll();
    await _avoidAnnotationManager.createMulti(options);
    drawPolygonAnnotation();
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
    onAvoidAnnotationClick();
    deleteAvoidAnnotation(annotation);
  }
}
