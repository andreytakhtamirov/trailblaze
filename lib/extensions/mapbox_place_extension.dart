import 'dart:convert';

import 'package:mapbox_search/mapbox_search.dart';

extension MapBoxPlaceExtensions on MapBoxPlace {
  String toRawJsonWithNullCheck() => json.encode(toJsonWithNullCheck());

  // Add null checking to fields.
  Map<String, dynamic> toJsonWithNullCheck() {
    return {
      "id": id,
      "type": featureTypeValues.reverse![type],
      "place_type": placeType.map((x) => x?.value).toList(),
      "address": addressNumber,
      "properties": properties?.toJson(),
      "text": text,
      "place_name": placeName,
      "bbox": bbox?.map((x) => x).toList(),
      "center": center?.map((x) => x).toList(),
      "geometry": geometry?.toJson(),
      "matching_text": matchingText,
      "matching_place_name": matchingPlaceName,
    };
  }
}
