import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

abstract class ApiEndpointService {
  Future<List<dynamic>?> fetchData(int page, String jwtToken);
}

class PostsApiService implements ApiEndpointService {
  @override
  Future<List<dynamic>?> fetchData(int page, String jwtToken) async {
    final endpoint = '$kBaseUrl/posts/get-posts?page=$page';

    final response =
        await http.get(Uri.parse(endpoint), headers: kRequestHeaderBasic);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      log("Failed to fetch data. Status code: ${response.statusCode}");
    }

    return null;
  }
}

class UserPostsApiService implements ApiEndpointService {
  @override
  Future<List<dynamic>?> fetchData(int page, String jwtToken) async {
    final endpoint = '$kBaseUrl/posts/get-user-posts?page=$page';
    final kRequestHeaders = {
      ...kRequestHeaderBasic,
      'Authorization': 'Bearer $jwtToken',
    };

    final response =
        await http.get(Uri.parse(endpoint), headers: kRequestHeaders);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      log("Failed to fetch user posts. Status code: ${response.statusCode}");
    }

    return null;
  }
}

class UserRoutesApiService implements ApiEndpointService {
  @override
  Future<List<dynamic>?> fetchData(int page, String jwtToken) async {
    final endpoint = '$kBaseUrl/routes/get-routes?page=$page';
    final kRequestHeaders = {
      ...kRequestHeaderBasic,
      'Authorization': 'Bearer $jwtToken',
    };

    final response =
        await http.get(Uri.parse(endpoint), headers: kRequestHeaders);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      log("Failed to fetch user routes. Status code: ${response.statusCode}");
    }

    return null;
  }
}

class LikedPostsApiService implements ApiEndpointService {
  @override
  Future<List<dynamic>?> fetchData(int page, String jwtToken) async {
    final endpoint = '$kBaseUrl/posts/get-user-likes?page=$page';
    final kRequestHeaders = {
      ...kRequestHeaderBasic,
      'Authorization': 'Bearer $jwtToken',
    };

    final response =
        await http.get(Uri.parse(endpoint), headers: kRequestHeaders);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      log("Failed to fetch user liked posts. Status code: ${response.statusCode}");
    }

    return null;
  }
}
