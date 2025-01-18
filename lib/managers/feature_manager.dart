import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:trailblaze/data/feature.dart';
import 'package:trailblaze/database/database.dart';
import 'package:trailblaze/requests/explore.dart';
import 'package:trailblaze/util/ui_helper.dart';

class FeatureManager {
  static AppDatabase db = Database.instance;

  static Future<List<Feature>> loadFeatures(
      BuildContext context, int distanceMeters, List<double> center) async {
    final features = await _resolveFromDb(distanceMeters, center);
    if (features != null) {
      return features;
    }

    if (context.mounted) {
      return _fetchFeatures(context, distanceMeters, center);
    } else {
      return [];
    }
  }

  static Future<List<Feature>?> _resolveFromDb(
      int distanceMeters, List<double> center) async {
    return await db.getNearbyParksByLocation(
        distanceMeters, center[0], center[1]);
  }

  static Future<List<Feature>> _fetchFeatures(
      BuildContext context, int distanceMeters, List<double> center) async {
    final dartz.Either<Map<int, String>, List<dynamic>?> response;
    response = await getFeatures([center[0], center[1]], distanceMeters);

    List<dynamic>? jsonData;

    response.fold(
      (error) => {
        if (error.keys.first == 404)
          {UiHelper.showSnackBar(context, error.values.first)}
        else
          {UiHelper.showSnackBar(context, "An unknown error occurred.")}
      },
      (data) => {jsonData = data},
    );

    if (jsonData == null || jsonData?.length == null) {
      return [];
    }

    List<Feature> features = await Future.wait(jsonData!.map((json) async {
      var feature = Feature.fromJson(json);
      await Feature.loadAddress(feature);
      return feature;
    }).toList());

    // Save features to cache
    _writeToDb(distanceMeters, center, features);
    return features;
  }

  static Future<void> _writeToDb(
      int distanceMeters, List<double> center, List<Feature> features) async {
    await db.insertNearbyParks(
      distanceMeters,
      center[0],
      center[1],
      features,
    );
  }
}
