import 'dart:developer';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:trailblaze/constants/cache_constants.dart';

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

@DriftDatabase(tables: [SearchFeatures])
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

    final count = await searchFeatures.count().getSingle();

    log("FEATURES ${count}");
    return into(searchFeatures).insert(feature);
  }
}
