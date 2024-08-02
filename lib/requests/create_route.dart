import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/extensions/mapbox_place_extension.dart';

import '../constants/request_constants.dart';

Future<Either<int, Map<String, dynamic>?>> createGraphhopperRoute(
    String profile, List<MapBoxPlace> waypoints,
    {bool isRoundTrip = false,
    double? distanceMeters,
    Polygon? avoidArea,
    num? influence}) async {
  const endpoint = '$kBaseUrl/v1/routes/create-route-graphhopper';

  final List<dynamic> waypointsJson = [];
  for (MapBoxPlace place in waypoints) {
    waypointsJson.add(place.toJsonTb());
  }

  final body = jsonEncode({
    if (isRoundTrip) 'mode': 'round_trip',
    'profile': profile,
    'waypoints': waypointsJson,
    'influence': influence,
    'ignore_area': avoidArea,
    if (isRoundTrip) 'distance': distanceMeters,
  });

  try {
    final response = await http.post(Uri.parse(endpoint),
        headers: kRequestHeaderBasic, body: body);

    if (response.statusCode == 200) {
      return Right(jsonDecode(response.body));
    } else {
      log("fail status: ${response.statusCode}");
      return Left(response.statusCode);
    }
  } catch (e) {
    log("Exception when fetching Graphhopper route: $e");
    return const Left(-1);
  }
}
