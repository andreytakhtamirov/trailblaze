import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

Future<Map<String, dynamic>?> getRouteMetrics(dynamic route) async {
  const endpoint = '$kBaseUrl/routes/route-metrics';
  final body = jsonEncode(route);

  final response = await http.post(Uri.parse(endpoint),
      headers: kRequestHeaderBasic, body: body);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    log("fail status: ${response.statusCode}");
  }

  return null;
}
