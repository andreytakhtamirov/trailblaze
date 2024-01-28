import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

Future<Either<int, Map<String, dynamic>?>> createRoute(
  String profile,
  List<dynamic> waypoints,
) async {
  const endpoint = '$kBaseUrl/routes/create-route';

  final body = jsonEncode({'profile': profile, 'waypoints': waypoints});

  final response = await http.post(Uri.parse(endpoint),
      headers: kRequestHeaderBasic, body: body);

  if (response.statusCode == 200) {
    return Right(jsonDecode(response.body));
  } else {
    log("fail status: ${response.statusCode}");
  }

  return Left(response.statusCode);
}

Future<Either<int, Map<String, dynamic>?>> createGraphhopperRoute(
    String profile, List<dynamic> waypoints) async {
  const endpoint = '$kBaseUrl/v1/routes/create-route-graphhopper';

  final body = jsonEncode({'profile': profile, 'waypoints': waypoints});

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
