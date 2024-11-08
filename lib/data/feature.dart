import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/util/geocoding_helper.dart';

class Feature {
  final String type;
  final int id;
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
      id: json['id'],
      center: json['center'],
      nodes: List<int>.from(json['nodes']),
      tags: {'name': json['tags']['name']},
    );
  }

  static loadAddress(Feature f) async {
    final address = await GeocodingHelper.addressFromCoordinates(
      f.center['lat'] as double,
      f.center['lon'] as double,
    );

    f.tags['address'] = address;
  }

  factory Feature.fromPlace(MapBoxPlace place) {
    return Feature(
      type: place.type.toString(),
      id: place.hashCode,
      center: {
        'lat': place.center?.lat,
        'lon': place.center?.long,
      },
      nodes: [],
      tags: {'name': place.placeName, 'address': place.properties?.address},
    );
  }
}
