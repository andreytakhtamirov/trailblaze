import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

Future<Either<Map<int, String>, List<dynamic>?>> getFeatures(
    List<double> coordinates,
    int distanceMeters,
    ) async {
  const endpoint = '$kBaseUrl/routes/features';

  final body = jsonEncode({'center': coordinates, 'distance': distanceMeters});

  final response = await http.post(Uri.parse(endpoint),
      headers: kRequestHeaderBasic, body: body);

  if (response.statusCode == 200) {
    return Right(jsonDecode(response.body)['features']);
  } else {
    log("fail status: ${response.statusCode}");
  }

  return Left(<int, String>{response.statusCode: response.body});
}