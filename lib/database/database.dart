import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:trailblaze/constants/cache_constants.dart';
import 'package:trailblaze/data/feature.dart';
import 'package:trailblaze/util/distance_helper.dart';

part 'database.g.dart';

class SearchFeatures extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get mapboxId => text().unique()();

  TextColumn get placeName => text()();

  TextColumn get subtitle => text()();

  TextColumn get geometryJson => text()();

  BoolColumn get hidden => boolean()();

  IntColumn get lastUsed => integer()();
}

class NearbyParks extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get distanceMeters => integer()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  TextColumn get features => text()();

  IntColumn get lastUsed => integer()();
}

@DriftDatabase(tables: [SearchFeatures, NearbyParks])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'trailblaze_db');
  }

  Future<List<SearchFeature>> limitFeaturesByRecency(int limit, {int? offset}) {
    return (select(searchFeatures)
          ..limit(limit, offset: offset)
          ..where((t) => t.hidden.equals(false))
          ..orderBy([
            (t) => OrderingTerm(expression: t.lastUsed, mode: OrderingMode.desc)
          ]))
        .get();
  }

  Future<SearchFeature?> featureById(String mapboxId) {
    return (select(searchFeatures)..where((t) => t.mapboxId.equals(mapboxId)))
        .getSingleOrNull();
  }

  Future<void> updateLastUsed(String mapboxId) async {
    await (update(searchFeatures)..where((t) => t.mapboxId.equals(mapboxId)))
        .write(SearchFeaturesCompanion(
      hidden: const Value(false), // Also un-hide the item
      lastUsed: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<void> hideFeature(String mapboxId) async {
    await (update(searchFeatures)..where((t) => t.mapboxId.equals(mapboxId)))
        .write(const SearchFeaturesCompanion(hidden: Value(false)));
  }

  Future<void> hideAllFeatures() async {
    await (update(searchFeatures))
        .write(const SearchFeaturesCompanion(hidden: Value(true)));
  }

  Future<int> deleteFeature(String mapboxId) {
    return (delete(searchFeatures)..where((t) => t.mapboxId.equals(mapboxId)))
        .go();
  }

  Future<int> addFeature(SearchFeaturesCompanion feature) async {
    final numEntries = await searchFeatures.count().getSingle();
    if (numEntries > kSearchFeatureCacheLimit) {
      final oldestFeature = await (select(searchFeatures)
            ..orderBy([(t) => OrderingTerm.asc(t.lastUsed)])
            ..limit(1))
          .getSingleOrNull();

      if (oldestFeature != null) {
        await (delete(searchFeatures)
              ..where((t) => t.id.equals(oldestFeature.id)))
            .go();
      }
    }

    return into(searchFeatures).insert(feature);
  }

  Future<int> insertNearbyParks(
    int queryDistance,
    double queryLat,
    double queryLon,
    List<Feature> features,
  ) async {
    final numEntries = await nearbyParks.count().getSingle();
    if (numEntries >= kNearbyParksCacheLimit) {
      final oldestEntry = await (select(nearbyParks)
            ..orderBy([(t) => OrderingTerm.asc(t.lastUsed)])
            ..limit(1))
          .getSingleOrNull();
      if (oldestEntry != null) {
        await (delete(nearbyParks)..where((t) => t.id.equals(oldestEntry.id)))
            .go();
      }
    }

    final truncatedLat = DistanceHelper.truncateCoordinate(queryLat);
    final truncatedLon = DistanceHelper.truncateCoordinate(queryLon);
    final featuresJson =
        features.map((feature) => feature.toJsonSimple()).toList();

    return into(nearbyParks).insert(
      NearbyParksCompanion(
        distanceMeters: Value(queryDistance),
        longitude: Value(truncatedLon),
        latitude: Value(truncatedLat),
        features: Value(jsonEncode(featuresJson)),
        lastUsed: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<List<Feature>?> getNearbyParksByLocation(
    int distance,
    double lat,
    double lon,
  ) async {
    final truncatedLat = DistanceHelper.truncateCoordinate(lat);
    final truncatedLon = DistanceHelper.truncateCoordinate(lon);
    final queryResult = await (select(nearbyParks)
          ..where(
            (t) =>
                t.latitude.equals(truncatedLat) &
                t.longitude.equals(truncatedLon) &
                t.distanceMeters.equals(distance),
          ))
        .get();

    if (queryResult.isNotEmpty) {
      final nearbyPark = queryResult.first;
      await (update(nearbyParks)..where((t) => t.id.equals(nearbyPark.id)))
          .write(NearbyParksCompanion(
        lastUsed: Value(DateTime.now().millisecondsSinceEpoch),
      ));

      final List<dynamic> featuresJson = jsonDecode(nearbyPark.features);
      return featuresJson
          .map((jsonItem) => Feature.fromJson(jsonItem))
          .toList();
    }

    return null;
  }
}
