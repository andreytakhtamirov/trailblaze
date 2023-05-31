import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:polyline_codec/polyline_codec.dart';

import '../constants/map_constants.dart';

class TrailblazeRoute {
  late final String sourceId;
  late final String layerId;
  late final LineLayer lineLayer;
  late final GeoJsonSource geoJsonSource;
  late final Map<String?, Object?> geometryJson;
  late final num distance;
  late final num duration;

  TrailblazeRoute(this.sourceId, this.layerId, dynamic routeJson, {bool isActive = false}) {
    lineLayer = LineLayer(
        id: layerId,
        sourceId: sourceId,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: isActive ? Colors.red.value : Colors.grey.value,
        lineWidth: routeLineWidth);

    final geometry = routeJson['geometry'];
    distance = routeJson['distance'];
    duration = routeJson['duration'];

    List<List<dynamic>> coordinates =
    PolylineCodec.decode(geometry, precision: polylinePrecision)
        .map((c) => [c[1], c[0]])
        .toList();

    geometryJson = {"type": "LineString", "coordinates": coordinates};

    final fills = {
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

    geoJsonSource = GeoJsonSource(id: sourceId, data: json.encode(fills));
  }

  void setActive(bool isActive) {
    if (isActive) {
      lineLayer.lineColor = Colors.red.value;
    } else {
      lineLayer.lineColor = Colors.grey.value;
    }
  }
}
