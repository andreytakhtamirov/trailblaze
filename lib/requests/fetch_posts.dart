import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

Future<List<dynamic>?> getPosts(
  int page,
) async {
  final endpoint = '$kBaseUrl/posts/get-posts?page=$page';

  final response =
      await http.get(Uri.parse(endpoint), headers: kRequestHeaderBasic);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    log("fail status: ${response.statusCode}");
  }

  return null;
}
