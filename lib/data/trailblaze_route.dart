import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/models/predictions.dart';
import 'package:polyline_codec/polyline_codec.dart';
import 'package:trailblaze/constants/request_api_constants.dart';
import 'package:trailblaze/data/instruction.dart';
import 'package:trailblaze/extensions/polyline_codec_extension.dart';

import '../constants/map_constants.dart';

class TrailblazeRoute {
  late final String sourceId;
  late final String layerId;
  late final LineLayer lineLayer;
  late final Map<String?, Object?> geometryJson;
  late final num distance;
  late final num duration;
  late final Map<String?, dynamic> routeOptions;
  List<num>? elevationMetrics;
  dynamic routeJson;
  List<MapBoxPlace> waypoints;
  List<List<num>>? coordinates;
  List<Instruction>? instructions;

  Map<String, num>? surfaceMetrics;
  Map<String, List<List<List<num>>>>? surfacePolylines;

  Map<String, num>? roadClassMetrics;
  Map<String, List<List<List<num>>>>? roadClassPolylines;

  late final _fills;

  TrailblazeRoute(
    this.sourceId,
    this.layerId,
    this.routeJson,
    this.waypoints,
    Map<String?, dynamic> options, {
    bool isActive = false,
    bool isGraphhopperRoute = false,
  }) {
    lineLayer = LineLayer(
        id: layerId,
        sourceId: sourceId,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: isActive ? Colors.red.value : Colors.grey.value,
        lineSortKey: isActive ? 10 : 1,
        lineOpacity:
            isActive ? kRouteActiveLineOpacity : kRouteInactiveLineOpacity,
        lineWidth: kRouteLineWidth);

    final geometry = routeJson[kMapboxRouteGeometryKey] ??
        routeJson[kGraphhopperRouteGeometryKey];
    distance = routeJson['distance'];
    duration = routeJson['duration'] ??
        routeJson['time'] / 1000; // Graphhopper time is in ms.
    routeOptions = options;

    if (isGraphhopperRoute) {
      final coordinatesWithElevation =
          PolylineCodecExtension.decodeWithElevation(geometry,
              precision: kGraphhopperRoutePrecision);

      coordinates = coordinatesWithElevation.coordinates
          .map((c) => [c[1], c[0]])
          .toList();

      elevationMetrics = coordinatesWithElevation.elevation;
      surfaceMetrics =
          _getMetrics(routeJson['details']['surface'], coordinates!);
      roadClassMetrics =
          _getMetrics(routeJson['details']['road_class'], coordinates!);
      surfacePolylines = _generatePolylinesForMetric(
          coordinates!, routeJson['details']['surface']);
      roadClassPolylines = _generatePolylinesForMetric(
          coordinates!, routeJson['details']['road_class']);

      final instructionsJson = routeJson['instructions'] as List<dynamic>;
      instructions = [];
      for (dynamic iJson in instructionsJson) {
        instructions?.add(Instruction(iJson, coordinates!));
      }
    } else {
      coordinates =
          PolylineCodec.decode(geometry, precision: kMapboxRoutePrecision)
              .map((c) => [c[1], c[0]])
              .toList();
    }

    geometryJson = {"type": "LineString", "coordinates": coordinates};

    _fills = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": 0,
          "properties": <String, dynamic>{},
          "geometry": geometryJson,
        },
      ]
    };
  }

  GeoJsonSource get geoJsonSource {
    return GeoJsonSource(id: sourceId, data: json.encode(_fills));
  }

  Map<String, num> _getMetrics(
    List<dynamic> surfaceData,
    List<List<dynamic>> coordinates,
  ) {
    Map<String, num> metrics = {};

    for (int i = 0; i < surfaceData.length; i++) {
      int start = surfaceData[i][0] as int;
      int end = surfaceData[i][1] as int;
      String key = surfaceData[i][2] as String;
      metrics.putIfAbsent(key, () => 0);

      final distance = this.distance / (coordinates.length - 1) * end -
          this.distance / (coordinates.length - 1) * start;
      metrics.update(key, (value) => value + distance);
    }

    // Sort in decreasing distance order.
    metrics = Map.fromEntries(
        metrics.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

    return metrics;
  }

  void setActive(bool isActive) {
    if (isActive) {
      lineLayer.lineSortKey = 10;
      lineLayer.lineColor = Colors.red.value;
      lineLayer.lineOpacity = kRouteActiveLineOpacity;
    } else {
      lineLayer.lineSortKey = 1;
      lineLayer.lineColor = Colors.grey.value;
      lineLayer.lineOpacity = kRouteInactiveLineOpacity;
    }
  }

  Map<String, List<List<List<num>>>> _generatePolylinesForMetric(
      List<List<num>> coordinates, List<dynamic> metricDetails) {
    final Map<String, List<List<List<num>>>> polylines = {};

    for (var detail in metricDetails) {
      int startIndex = detail[0];
      int endIndex = detail[1];
      String type = detail[2];

      List<List<num>> segment = coordinates.sublist(startIndex, endIndex + 1);
      if (polylines[type] == null) {
        polylines[type] = [];
      }

      polylines[type]!.add(segment);
    }

    return polylines;
  }
}
