import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/feature.dart' as tb;

class AnnotationState {
  late final String id;
  PointAnnotationOptions options;
  PointAnnotation? annotation;
  bool isClustered = false;

  AnnotationState(this.options) {
    id = options.geometry.coordinates.lat.toString() +
        options.geometry.coordinates.lng.toString();
  }

  factory AnnotationState.fromFeature(tb.Feature feature, Uint8List image) {
    final name = feature.tags['name'];
    final coordinates = Point(
      coordinates: Position(
        feature.center['lon'],
        feature.center['lat'],
      ),
    );
    return AnnotationState(initOptions(coordinates, name, image));
  }

  static PointAnnotationOptions initOptions(
      Point point, String name, Uint8List image) {
    return PointAnnotationOptions(
      geometry: point,
      image: image,
      iconSize: kLocationPinSize,
      // Temporary fix for issue https://github.com/mapbox/mapbox-maps-flutter/issues/417
      textAnchor: Platform.isAndroid ? TextAnchor.LEFT : TextAnchor.BOTTOM_LEFT,
      textField: name,
      textHaloWidth: 1,
      textSize: 13,
      textMaxWidth: 20,
      textEmissiveStrength: 1,
      textHaloColor: const Color.fromRGBO(255, 255, 255, 0.15).value,
      textOcclusionOpacity: 0.4,
      textOffset: [1, 0],
      textColor: Colors.black.value,
      symbolSortKey: 1,
    );
  }
}
