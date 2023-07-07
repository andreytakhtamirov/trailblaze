import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../constants/request_constants.dart';

Future<Either<int, Map<String, dynamic>?>> getProfile(String jwtToken) async {
  const endpoint = '$kBaseUrl/users';
  final kRequestHeaders = {
    ...kRequestHeaderBasic,
    'Authorization': 'Bearer $jwtToken',
  };

  final response =
      await http.get(Uri.parse(endpoint), headers: kRequestHeaders);

  if (response.statusCode == 200) {
    return Right(jsonDecode(response.body));
  } else {
    log("Failed to fetch user profile. Status code: ${response.statusCode}");
  }

  return Left(response.statusCode);
}

Future<Either<int, Map<String, dynamic>?>> saveProfile(
    String jwtToken, String? username, String? profilePicture) async {
  const endpoint = '$kBaseUrl/users';
  final kRequestHeaders = {
    ...kRequestHeaderBasic,
    'Authorization': 'Bearer $jwtToken',
  };

  final body = jsonEncode({
    'username': username,
    'profile_picture': profilePicture,
  });

  final response = await http.post(
    Uri.parse(endpoint),
    headers: kRequestHeaders,
    body: body,
  );

  if (response.statusCode == 201 || response.statusCode == 200) {
    return Right(jsonDecode(response.body));
  } else {
    log("Failed to save user profile. Status code: ${response.statusCode}");
  }

  return Left(response.statusCode);
}

Future<Either<int, Map<String, dynamic>?>> checkUsernameAvailability(
    String username) async {
  final endpoint = '$kBaseUrl/users/check/$username';

  final response = await http.get(
    Uri.parse(endpoint),
    headers: kRequestHeaderBasic,
  );

  if (response.statusCode == 200) {
    return Right(jsonDecode(response.body));
  } else if (response.statusCode != 409) {
    log("Failed to fetch username availability. Status code: ${response.statusCode}");
  }

  return Left(response.statusCode);
}
