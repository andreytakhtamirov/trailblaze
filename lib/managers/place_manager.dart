import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/constants/request_api_constants.dart';
import 'package:trailblaze/data/feature.dart' as tb;
import 'package:trailblaze/util/search_item_helper.dart';
import 'package:turf/turf.dart' as turf;
import 'package:drift/drift.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/database/database.dart';
import 'package:trailblaze/extensions/mapbox_search_extension.dart';

class PlaceManager {
  static AppDatabase db = AppDatabase();
  SearchBoxAPI searchBoxAPI = SearchBoxAPI(
    limit: kCategoryResultsLimit,
    types: [
      PlaceType.address,
      PlaceType.place,
      PlaceType.poi,
      PlaceType.neighborhood
    ],
  );

  Future<List<tb.Feature>?> resolveCategory(
    Client client,
    String? categoryId,
    mbm.CoordinateBounds? bounds,
  ) async {
    Completer<List<tb.Feature>?> completer = Completer();
    ApiResponse<mbm.FeatureCollection> result = await searchBoxAPI.getCategory(
      kMapboxAccessToken,
      categoryId ?? "",
      client,
      proximity: bounds != null
          ? Proximity.LatLong(
              lat: (bounds.southwest.coordinates.lat.toDouble() +
                      bounds.northeast.coordinates.lat.toDouble()) /
                  2,
              long: (bounds.southwest.coordinates.lng.toDouble() +
                      bounds.northeast.coordinates.lng.toDouble()) /
                  2,
            )
          : Proximity.LocationNone(),
      bbox: bounds != null
          ? BBox(min: (
              lat: bounds.southwest.coordinates.lat.toDouble(),
              long: bounds.southwest.coordinates.lng.toDouble()
            ), max: (
              lat: bounds.northeast.coordinates.lat.toDouble(),
              long: bounds.northeast.coordinates.lng.toDouble()
            ))
          : null,
    );

    result.fold((response) async {
      List<turf.Feature<turf.GeometryObject>> features = response.features;

      List<tb.Feature> places = [];
      for (turf.Feature<turf.GeometryObject> f in features) {
        if (f.geometry == null) {
          return;
        }
        final name = f.properties?['name'];
        final fullAddress = f.properties?['full_address'];
        final point = mbm.Point.fromJson(f.geometry!.toJson());

        final fe = tb.Feature.fromPlace(
          MapBoxPlace(
            placeName: name,
            properties: Properties(address: fullAddress),
            center: (
              lat: point.coordinates.lat.toDouble(),
              long: point.coordinates.lng.toDouble()
            ),
          ),
        );
        places.add(fe);
      }
      completer.complete(places);
    }, (failure) {
      completer.complete(null);
    });
    return completer.future;
  }

  // TODO clean up
  Future<MapBoxPlace?> resolveFeature(SuggestionTb s) async {
    MapBoxPlace? place = await getPlaceById(s.mapboxId);

    // Place is cached
    if (place != null) {
      log("USING CACHED PLACE ${place.placeName}");
      db.updateLastUsed(place.id!);
      return place;
    }

    // Place doesn't exist in cache
    // Fetch full feature info and build place.
    final feature = await fetchFeature(s);
    log("FEATURE ${feature == null}");
    if (feature != null) {
      place = MapBoxPlace(
        placeName: SearchItemHelper.titleLabelForFeatureType(s),
        text: SearchItemHelper.subtitleLabelForFeatureType(s),
        center: feature.geometry.coordinates,
      );

      // Write place to database for quick lookup for next time.
      writeMapboxPlace(
        s.mapboxId,
        place.placeName!,
        place.text!,
        jsonEncode(feature.geometry.toJson()),
      );
      log("WRITING PLACE ${place.toJson()}");
    }

    return place;
  }

  Future<Feature?> fetchFeature(SuggestionTb s) async {
    Completer<Feature?> completer = Completer();
    ApiResponse<RetrieveResonse> result =
        await searchBoxAPI.getPlaceById(kMapboxAccessToken, s.mapboxId);

    result.fold((response) async {
      log("RESPONSE ${response.features.length} ${s.mapboxId}");
      completer.complete(response.features.firstOrNull);
    }, (failure) {
      log("Failed to retrieve Feature details ${failure.error}");
      completer.complete(null);
    });

    return completer.future;
  }

  Future<void> hideFeature(String mapboxId) async {
    return await db.hideFeature(mapboxId);
  }

  Future<void> hideAllFeatures() async {
    return await db.hideAllFeatures();
  }

  Future<bool> deleteFeature(String mapboxId) async {
    return await db.deleteFeature(mapboxId) > 0;
  }

  Future<MapBoxPlace?> getPlaceById(String mapboxId) async {
    final feature = await db.featureById(mapboxId);

    if (feature == null) {
      return null;
    }

    return featureToPlace(feature);
  }

  Future<List<MapBoxPlace>> mostRecentPlaces(int limit) async {
    final features = await db.limitFeaturesByRecency(limit);
    final List<MapBoxPlace> places = [];

    for (SearchFeature f in features) {
      places.add(featureToPlace(f));
    }

    return places;
  }

  MapBoxPlace featureToPlace(SearchFeature feature) {
    final point = turf.Point.fromJson(jsonDecode(feature.geometryJson));

    return MapBoxPlace(
      id: feature.mapboxId,
      placeName: feature.placeName,
      text: feature.subtitle,
      center: (
        lat: point.coordinates.lat.toDouble(),
        long: point.coordinates.lng.toDouble()
      ),
    );
  }

  Future<void> writeMapboxPlace(
      String mapboxId, String placeName, String subtitle, String geometryJson) {
    return db.addFeature(
      SearchFeaturesCompanion(
        mapboxId: Value(mapboxId),
        placeName: Value(placeName),
        subtitle: Value(subtitle),
        hidden: const Value(false),
        geometryJson: Value(geometryJson),
        lastUsed: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }
}
