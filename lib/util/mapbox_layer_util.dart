import 'dart:convert';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/util/polyline_helper.dart';

class MapboxLayerUtil {
  static const String layerId = "current-progress-layer";
  static const String sourceId = "current-progress-source";
  static const String instructionId = "instruction";

  static Future<void> drawRoute(
      mbm.MapboxMap mapboxMap, TrailblazeRoute route) async {

    if (await mapboxMap.style.styleSourceExists(route.geoJsonSource.id)) {
      await mapboxMap.style.removeStyleSource(route.geoJsonSource.id);
    }

    if (await mapboxMap.style.styleLayerExists(route.layerId)) {
      await mapboxMap.style.removeStyleLayer(route.layerId);
    }

    try {
      await mapboxMap.style.addSource(route.geoJsonSource);
    } catch (e) {
      // Source might exist already
    }

    try {
      await mapboxMap.style
          .addLayerAt(route.lineLayer, mbm.LayerPosition(below: "road-label"));
    } catch (e) {
      // "road-label" may not have been created yet or doesn't exist.
      await mapboxMap.style.addLayer(route.lineLayer);
    }
  }

  static Future<void> deleteRoute(
      mbm.MapboxMap mapboxMap, TrailblazeRoute route) async {
    try {
      if (await mapboxMap.style.styleLayerExists(route.layerId)) {
        await mapboxMap.style.removeStyleLayer(route.layerId);
      }
    } catch (e) {
      dev.log('Exception removing route style layer: $e');
    }

    try {
      if (await mapboxMap.style.styleSourceExists(route.sourceId)) {
        await mapboxMap.style.removeStyleSource(route.sourceId);
      }
    } catch (e) {
      dev.log('Exception removing route style source layer: $e');
    }
  }

  static Future<void> updateProgressLayer(
      mbm.MapboxMap mapboxMap, List<List<num>> coordinates) async {
    if (coordinates.isEmpty || coordinates.length < 2) {
      return;
    }

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

    final geoJsonSource =
        mbm.GeoJsonSource(id: sourceId, data: json.encode(fills));

    try {
      if (!await mapboxMap.style.styleSourceExists(sourceId)) {
        await mapboxMap.style.addSource(geoJsonSource);
      } else {
        final source =
            await mapboxMap.style.getSource(sourceId) as mbm.GeoJsonSource;
        await source.updateGeoJSON(json.encode(fills));
      }

      if (!await mapboxMap.style.styleLayerExists(layerId)) {
        final lineLayer = mbm.LineLayer(
          id: layerId,
          sourceId: sourceId,
          lineJoin: mbm.LineJoin.ROUND,
          lineCap: mbm.LineCap.ROUND,
          lineColor: Colors.grey.value,
          lineSortKey: 20,
          lineOpacity: kRouteActiveLineOpacity,
          lineWidth: kRouteLineWidth,
        );

        try {
          await mapboxMap.style
              .addLayerAt(lineLayer, mbm.LayerPosition(below: "road-label"));
        } catch (e) {
          dev.log("Layer position error, adding layer at top: $e");
          await mapboxMap.style.addLayer(lineLayer);
        }
      }
    } catch (e) {
      dev.log("Error adding progress layer: $e");
    }
  }

  static Future<void> deleteProgressLayer(mbm.MapboxMap mapboxMap) async {
    try {
      if (await mapboxMap.style.styleLayerExists(layerId)) {
        await mapboxMap.style.removeStyleLayer(layerId);
      }
    } catch (e) {
      dev.log("Exception removing route style layer: $e");
    }

    try {
      if (await mapboxMap.style.styleSourceExists(sourceId)) {
        await mapboxMap.style.removeStyleSource(sourceId);
      }
    } catch (e) {
      dev.log("Exception removing route style source layer: $e");
    }
  }

  static Future<void> drawInstructionLine(
      mbm.MapboxMap mapboxMap, List<List<num>> polylines) async {
    try {
      await mapboxMap.style.addSource(
          PolylineHelper.buildGeoJsonSource([polylines], instructionId));
    } catch (e) {
      // Source might exist already
    }

    await mapboxMap.style.addLayerAt(
        PolylineHelper.buildLineLayer(instructionId),
        mbm.LayerPosition(below: "road-label"));
  }

  static Future<void> deleteInstructionLine(mbm.MapboxMap mapboxMap) async {
    try {
      await mapboxMap.style.removeStyleLayer(instructionId);
    } catch (e) {
      // Layer might have been removed already.
    }

    try {
      await mapboxMap.style.removeStyleSource(instructionId);
    } catch (e) {
      // Layer might have been removed already.
    }
  }
}
