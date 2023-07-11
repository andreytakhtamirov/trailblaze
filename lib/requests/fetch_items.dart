import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

abstract class ApiEndpointService {
  final CacheManager _cacheManager = DefaultCacheManager();

  Future<List<dynamic>?> fetchData(int page, String jwtToken) async {
    final endpoint = getEndpoint(page);

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // If no connection is available, fall back on items in cache.
      try {
        final cachedResult = await _cacheManager.getFileFromCache(endpoint);
        if (cachedResult != null) {
          final cachedData = await cachedResult.file.readAsString();
          return jsonDecode(cachedData);
        }
      } catch (e) {
        log('Error reading from cache: $e');
      }
    } else {
      final http.Response response;

      try {
        response = await makeRequest(endpoint, jwtToken);
      } catch (e) {
        log("Failed to fetch data for $endpoint. $e");
        return null;
      }

      if (response.statusCode == 200) {
        await _cacheManager.putFile(endpoint, response.bodyBytes);
        return jsonDecode(response.body);
      } else {
        log("Failed to fetch data for $endpoint. Status code: ${response.statusCode}");
      }
    }

    return null;
  }

  String getEndpoint(int page);

  Future<http.Response> makeRequest(String endpoint, String jwtToken);
}

class PostsApiService extends ApiEndpointService {
  @override
  String getEndpoint(int page) {
    return '$kBaseUrl/posts/get-posts?page=$page';
  }

  @override
  Future<http.Response> makeRequest(String endpoint, String jwtToken) {
    return http.get(Uri.parse(endpoint), headers: kRequestHeaderBasic);
  }
}

class UserPostsApiService extends ApiEndpointService {
  @override
  String getEndpoint(int page) {
    return '$kBaseUrl/posts/get-user-posts?page=$page';
  }

  @override
  Future<http.Response> makeRequest(String endpoint, String jwtToken) {
    final kRequestHeaders = {
      ...kRequestHeaderBasic,
      'Authorization': 'Bearer $jwtToken',
    };
    return http.get(Uri.parse(endpoint), headers: kRequestHeaders);
  }
}

class UserRoutesApiService extends ApiEndpointService {
  @override
  String getEndpoint(int page) {
    return '$kBaseUrl/routes/get-routes?page=$page';
  }

  @override
  Future<http.Response> makeRequest(String endpoint, String jwtToken) {
    final kRequestHeaders = {
      ...kRequestHeaderBasic,
      'Authorization': 'Bearer $jwtToken',
    };
    return http.get(Uri.parse(endpoint), headers: kRequestHeaders);
  }
}

class LikedPostsApiService extends ApiEndpointService {
  @override
  String getEndpoint(int page) {
    return '$kBaseUrl/posts/get-user-likes?page=$page';
  }

  @override
  Future<http.Response> makeRequest(String endpoint, String jwtToken) {
    final kRequestHeaders = {
      ...kRequestHeaderBasic,
      'Authorization': 'Bearer $jwtToken',
    };
    return http.get(Uri.parse(endpoint), headers: kRequestHeaders);
  }
}
