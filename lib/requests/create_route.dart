import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

Future<Map<String, dynamic>?> createRoute(
  String profile,
  List<dynamic> waypoints,
) async {
  const endpoint = '$baseUrl/routes/create-route';

  final body = jsonEncode({'profile': profile, 'waypoints': waypoints});

  final response = await http.post(Uri.parse(endpoint),
      headers: requestHeaderBasic, body: body);

  if (response.statusCode == 200) {
    // Handle the success response
    return jsonDecode(response.body);
  } else {
    // Handle the error response
    log("fail status: ${response.statusCode}");
  }

  return null;
}
