import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:mapbox_search/models/location.dart';
import 'package:http/http.dart' as http;
import 'package:trailblaze/data/search_feature_type.dart';
import 'package:trailblaze/util/device_info_helper.dart';

part "mapbox_search_extension.g.dart";

final Uri _baseUri = Uri.parse('https://api.mapbox.com/search/searchbox/v1/');

extension MapBoxSearchExtension on SearchBoxAPI {
  Uri _createUrl(
    String apiKey,
    String sessionUUID,
    String queryOrId,
    Proximity proximity,
    Proximity origin, [
    List<POICategory> poi = const [],
    bool isCategory = false,
  ]) {
    final typesStr = types.map((e) => e.value).toList(growable: true);
    typesStr.add(SearchFeatureType.category.value);

    final finalUri = Uri(
      scheme: _baseUri.scheme,
      host: _baseUri.host,
      path: _baseUri.path + (!isCategory ? 'suggest' : 'category/$queryOrId'),
      queryParameters: {
        if (!isCategory) 'q': queryOrId,
        ...switch (proximity) {
          (LocationProximity l) => {"proximity": l.asString},
          (IpProximity _) => {"proximity": 'ip'},
          (NoProximity _) => {},
        },
        ...switch (origin) {
          (LocationProximity l) => {"origin": l.asString},
          (IpProximity _) => {},
          (NoProximity _) => {},
        },
        'access_token': apiKey,
        if (!isCategory) 'session_token': sessionUUID,
        'navigation_profile': 'walking',
        if (country != null) 'country': country,
        if (limit != null) 'limit': limit.toString(),
        if (language != null) 'language': language,
        if (!isCategory && types.isNotEmpty) 'types': typesStr.join(','),
        if (bbox != null) 'bbox': bbox?.asString,
        if (poi.isNotEmpty) 'poi_category': poi.map((e) => e.value).join(','),
      },
    );
    return finalUri;
  }

  /// Get a list of places that match the query.
  Future<ApiResponse<SuggestionResponseTb>> getSuggestionsCustom(
    String apiKey,
    String queryText,
    http.Client client, {
    Proximity proximity = const NoProximity(),
    Proximity origin = const NoProximity(),
    List<POICategory> poi = const [],
  }) async {
    try {
      String? sessionUUID = await DeviceInfoHelper.getDeviceDetails();
      final uri = _createUrl(
          apiKey, sessionUUID, queryText, proximity, origin, poi, false);
      final response = await client.get(uri);
      if (response.statusCode != 200) {
        return (
          success: null,
          failure: FailureResponse.fromJson(json.decode(response.body))
        );
      } else {
        return (
          success: SuggestionResponseTb.fromJson(json.decode(response.body)),
          failure: null
        );
      }
    } catch (e) {
      return (
        success: null,
        failure: FailureResponse(
          message: 'Client closed',
          error: null,
          response: {},
        )
      );
    }
  }

  /// Get a list of places that match the query.
  Future<ApiResponse<FeatureCollection>> getCategory(
    String apiKey,
    String categoryName,
    http.Client client, {
    Proximity proximity = const NoProximity(),
    Proximity origin = const NoProximity(),
    List<POICategory> poi = const [],
  }) async {
    try {
      String? sessionUUID = await DeviceInfoHelper.getDeviceDetails();
      final uri = _createUrl(
          apiKey, sessionUUID, categoryName, proximity, origin, poi, true);
      print(uri.toString());

      final response = await client.get(uri);
      print("RESPONSE: ${response.statusCode}");
      if (response.statusCode != 200) {
        return (
          success: null,
          failure: FailureResponse.fromJson(json.decode(response.body))
        );
      } else {
        return (
          success: FeatureCollection.fromJson(json.decode(response.body)),
          failure: null
        );
      }
    } catch (e) {
      return (
        success: null,
        failure: FailureResponse(
          message: 'Client closed',
          error: null,
          response: {},
        )
      );
    }
  }
}

@JsonSerializable()
class SuggestionResponseTb {
  SuggestionResponseTb({
    required this.suggestions,
    required this.attribution,
    required this.url,
  });

  final List<SuggestionTb> suggestions;
  final String attribution;
  final String? url;

  factory SuggestionResponseTb.fromJson(Map<String, dynamic> json) =>
      _$SuggestionResponseTbFromJson(json);

  Map<String, dynamic> toJson() => _$SuggestionResponseTbToJson(this);
}

class SuggestionTb {
  SuggestionTb({
    required this.name,
    this.namePreferred,
    required this.mapboxId,
    required this.featureType,
    required this.address,
    required this.fullAddress,
    required this.placeFormatted,
    required this.context,
    required this.language,
    required this.maki,
    this.distance,
    this.externalIds,
    this.poiCategory,
    this.poiCategoryIds,
    this.brand,
    this.brandId,
  });

  final String name;
  final String? namePreferred;
  final String mapboxId;
  final String featureType;
  final String? address;
  final String? fullAddress;
  final String placeFormatted;
  final Context? context;
  final String language;
  final String? maki;
  final int? distance;
  final ExternalIds? externalIds;
  final List<String>? poiCategory;
  final List<String>? poiCategoryIds;
  final List<String>? brand;
  final List<String>? brandId;

  factory SuggestionTb.fromJson(Map<String, dynamic> json) => SuggestionTb(
        name: json['name'] as String,
        namePreferred: json['name_preferred'] as String?,
        mapboxId: json['mapbox_id'] as String,
        featureType: json['feature_type'] as String,
        address: json['address'] as String?,
        fullAddress: json['full_address'] as String?,
        placeFormatted: json['place_formatted'] as String,
        context: json['context'] == null
            ? null
            : Context.fromJson(json['context'] as Map<String, dynamic>),
        language: json['language'] as String,
        maki: json['maki'] as String?,
        distance: json['distance'] as int?,
        externalIds: json['external_ids'] == null
            ? null
            : ExternalIds.fromJson(
                json['external_ids'] as Map<String, dynamic>),
        poiCategory: (json['poi_category'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        poiCategoryIds: (json['poi_category_ids'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        brand:
            (json['brand'] as List<dynamic>?)?.map((e) => e as String).toList(),
        brandId: (json['brand_id'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'name_preferred': namePreferred,
        'mapbox_id': mapboxId,
        'feature_type': featureType,
        'address': address,
        'full_address': fullAddress,
        'place_formatted': placeFormatted,
        'context': context,
        'language': language,
        'maki': maki,
        'distance': distance,
        'external_ids': externalIds,
        'poi_category': poiCategory,
        'poi_category_ids': poiCategoryIds,
        'brand': brand,
        'brand_id': brandId,
      };
}
