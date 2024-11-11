import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/util/geocoding_helper.dart';

class Feature {
  final String type;
  final String id;
  final Map<String, dynamic> center;
  final List<int> nodes;
  final Map<String, dynamic> tags;

  Feature({
    required this.type,
    required this.id,
    required this.center,
    required this.nodes,
    required this.tags,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      type: json['type'],
      id: json['id'].toString(),
      center: json['center'],
      nodes: List<int>.from(json['nodes']),
      tags: {'name': json['tags']['name']},
    );
  }

  // Features fetched via the Overpass API (instead of Mapbox) won't
  // have complete addresses. We can guess these from their coordinates.
  static loadAddress(Feature f) async {
    final address = await GeocodingHelper.addressFromCoordinates(
      f.center['lat'] as double,
      f.center['lon'] as double,
    );

    f.tags['address'] = address;
    f.tags['type'] = 'park'; // Type exclusive to non-mapbox features.
  }

  factory Feature.fromPlace(MapBoxPlace place) {
    final String id;
    if (place.id != null) {
      id = place.id!;
    } else {
      id = place.hashCode.toString();
    }

    return Feature(
      type: place.type.toString(),
      id: id,
      center: {
        'lat': place.center?.lat,
        'lon': place.center?.long,
      },
      nodes: [],
      tags: {'name': place.placeName, 'address': place.properties?.address},
    );
  }
}
