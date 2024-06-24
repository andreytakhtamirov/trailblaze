import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class PolylineHelper {
  static LineLayer buildLineLayer(int index) {
    return LineLayer(
        id: "test $index",
        sourceId: "test $index",
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: Colors.black.value,
        lineDasharray: [3, 3],
        lineOpacity: 1,
        lineWidth: 2);
  }

  static GeoJsonSource buildGeoJsonSource(List<List<num>> coordinates, int index) {
    final geometryJson = {"type": "LineString", "coordinates": coordinates};

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

    return GeoJsonSource(
        id: "test $index", data: json.encode(fills));
  }
}
