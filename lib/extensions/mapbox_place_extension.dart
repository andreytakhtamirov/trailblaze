// import 'dart:convert';
//
// import 'package:mapbox_search/mapbox_search.dart';
//
// extension MapBoxPlaceExtensions on MapBoxPlace {
//   String toRawJsonWithNullCheck() => json.encode(toJsonWithNullCheck());
//
//   // Add null checking to fields.
//   Map<String, dynamic> toJsonWithNullCheck() {
//     return {
//       "id": id,
//       "type": featureVa.reverse![type],
//       "place_type": placeType.map((x) => x?.value).toList(),
//       "address": addressNumber,
//       "properties": properties?.toJson(),
//       "text": text,
//       "place_name": placeName,
//       'bbox': bbox != null ? const BBoxConverter().toJson(bbox!) : null,
//       'center': const OptionalLocationConverter().toJson(instance.center),
//       "geometry": geometry?.toJson(),
//       "matching_text": matchingText,
//       "matching_place_name": matchingPlaceName,
//     };
//   }
//
//   MapBoxPlace fromRawJson(String rawJson) {
//     Map<String, dynamic> data = json.decode(rawJson);
//     return MapBoxPlace(
//       id: data['id'] ?? '',
//       type: FeatureType.FEATURE,
//       placeType: [PlaceType.address],
//       addressNumber: data['address'] ?? '',
//       properties: Properties.fromJson(data['properties'] ?? {}),
//       text: data['text'] ?? '',
//       placeName: data['place_name'] ?? '',
//       bbox: List<double>.from( ?? []),
//       center: (long: data['center']['lon'], lat: data['center']['lat']),
//       geometry: Geometry.fromJson(data['geometry'] ?? {}),
//       matchingText: data['matching_text'] ?? '',
//       matchingPlaceName: data['matching_place_name'] ?? '',
//     );
//   }
// }
