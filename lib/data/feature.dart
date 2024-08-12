import 'package:mapbox_search/mapbox_search.dart';

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
      tags: Map<String, dynamic>.from(json['tags']),
    );
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
      tags: {'name': place.placeName},
    );
  }
}
