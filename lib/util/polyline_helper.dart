import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblaze/constants/map_constants.dart';

class PolylineHelper {
  static LineLayer buildLineLayer(String key) {
    return LineLayer(
      id: kMetricLayerIdPrefix + key,
      sourceId: kMetricLayerIdPrefix + key,
      lineJoin: LineJoin.ROUND,
      lineCap: LineCap.ROUND,
      lineColor: Colors.white.value,
      lineOpacity: 1,
      lineWidth: 7,
      lineBorderWidth: 2,
      lineBorderColor: Colors.redAccent.value,
    );
  }

  static GeoJsonSource buildGeoJsonSource(
      List<List<List<num>>> allCoordinates, String key) {
    final fills = {"type": "FeatureCollection", "features": []};

    for (List<List<num>> coordinates in allCoordinates) {
      final geometryJson = {"type": "LineString", "coordinates": coordinates};

      (fills['features'] as List).add({
        "type": "Feature",
        "id": 0,
        "properties": <String, dynamic>{},
        "geometry": geometryJson,
      });
    }

    return GeoJsonSource(
        id: kMetricLayerIdPrefix + key, data: json.encode(fills));
  }

  static Map<String, Object> buildFlatLineString(
      List<List<List<num>>> allCoordinates, String key) {
    final List<List<num>> flatCoordinates = [];

    for (List<List<num>> coordinates in allCoordinates) {
      flatCoordinates.addAll(coordinates);
    }

    return {"type": "LineString", "coordinates": flatCoordinates};
  }
}
