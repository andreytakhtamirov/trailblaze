import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

Future<Map<String, dynamic>?> getRouteMetrics(http.Client client, dynamic route) async {
  const endpoint = '$kBaseUrl/routes/route-metrics';
  final body = jsonEncode(route);

  final http.Response response;
  try {
     response = await client.post(Uri.parse(endpoint),
        headers: kRequestHeaderBasic, body: body);
  } catch(clientException) {
    log("Metrics exception: ${clientException.toString()}");
    return null;
  }

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    log("fail status: ${response.statusCode}");
  }

  return null;
}
