import 'dart:convert';
import 'dart:developer';
import 'package:mapbox_search/mapbox_search.dart';

extension MapBoxPlaceExtensions on MapBoxPlace {
  String toJsonTb() => json.encode(_toJson());

  Map<String, dynamic> _toJson() {
    const converter = BBoxConverter();
    return {
      "id": id,
      "type": "Feature",
      "place_type": placeType.map((x) => x?.value).toList(),
      "address": addressNumber,
      "properties": properties?.toJson(),
      "text": text,
      "place_name": placeName,
      "bbox": bbox != null ? converter.toJson(bbox!) : null,
      "center": [center!.long, center!.lat],
      "geometry": geometry?.toJson(),
      "matching_text": matchingText,
      "matching_place_name": matchingPlaceName,
    };
  }

  static MapBoxPlace fromJsonTb(String rawJson) {
    Map<String, dynamic> data = json.decode(rawJson);
    final c = data['center'] as List<dynamic>;
    return MapBoxPlace(
      id: data['id'] ?? '',
      type: FeatureType.FEATURE,
      placeType: [PlaceType.address],
      addressNumber: data['address'] ?? '',
      properties: data['properties'] != null
          ? Properties.fromJson(data['properties'])
          : null,
      text: data['text'] ?? '',
      placeName: data['place_name'] ?? '',
      bbox: data['bbox'] != null ? const BBoxConverter().fromJson(data['bbox']) : null,
      center: (long: c.first, lat: c.last),
      geometry:
          data['geometry'] != null ? Geometry.fromJson(data['geometry']) : null,
      matchingText: data['matching_text'] ?? '',
      matchingPlaceName: data['matching_place_name'] ?? '',
    );
  }
}
