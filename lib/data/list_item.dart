import 'package:trailblaze/constants/request_api_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/data/transportation_mode.dart';

import '../constants/discover_constants.dart';
import '../constants/map_constants.dart';

abstract class Item {
  String get title;

  String? get description;

  int? get likes;

  TransportationMode get transportationMode;

  String get imageUrl;

  TrailblazeRoute get route;

  Item? jsonToItem(dynamic jsonObject);
}

class PostListItem implements Item {
  @override
  final String title;
  @override
  final String description;
  @override
  final int likes;
  @override
  final TransportationMode transportationMode;
  @override
  final String imageUrl;
  @override
  final TrailblazeRoute route;

  PostListItem({
    required this.title,
    required this.description,
    required this.likes,
    required this.transportationMode,
    required this.imageUrl,
    required this.route,
  });

  factory PostListItem.fromJson(dynamic itemJson) {
    final title = itemJson[kJsonKeyPostTitle];
    final description = itemJson[kJsonKeyPostDescription];
    final likes = itemJson[kJsonKeyPostLikes];
    final modeStr = itemJson[kJsonKeyPostRouteId][kJsonKeyPostRouteOptions]
        [kJsonKeyPostProfile];
    final imageUrl = itemJson[kJsonKeyPostRouteId][kJsonKeyPostImageUrl];
    final routeJson = itemJson[kJsonKeyPostRouteId][kJsonKeyPostRoute];

    if (title != null &&
        description != null &&
        modeStr != null &&
        imageUrl != null) {
      TrailblazeRoute route = TrailblazeRoute(
        kRouteSourceId,
        kRouteLayerId,
        routeJson,
        [],
        isActive: true,
      );

      return PostListItem(
        title: title,
        description: description,
        transportationMode: getTransportationModeFromString(modeStr),
        likes: likes,
        imageUrl: imageUrl,
        route: route,
      );
    }

    throw const FormatException('Invalid JSON format for Post item');
  }

  @override
  Item? jsonToItem(dynamic jsonObject) {
    if (jsonObject is Map<String, dynamic>) {
      return PostListItem.fromJson(jsonObject);
    }
    return null;
  }
}

class RouteListItem implements Item {
  @override
  final String title;
  @override
  final TransportationMode transportationMode;
  @override
  final String imageUrl;
  @override
  final TrailblazeRoute route;

  // These are unused since a route can't have a description or likes.
  @override
  String? get description => null;

  @override
  int? get likes => null;

  RouteListItem({
    required this.title,
    required this.transportationMode,
    required this.imageUrl,
    required this.route,
  });

  factory RouteListItem.fromJson(dynamic itemJson) {
    final title = itemJson[kJsonKeyPostTitle];
    final distance = itemJson[kJsonKeyPostRoute][kJsonKeyPostDistance];
    final modeStr = itemJson[kJsonKeyPostRouteOptions][kJsonKeyPostProfile];
    final imageUrl = itemJson[kJsonKeyPostImageUrl];
    final routeJson = itemJson[kJsonKeyPostRoute];

    if (title != null &&
        distance != null &&
        modeStr != null &&
        imageUrl != null) {
      TrailblazeRoute route = TrailblazeRoute(
        kRouteSourceId,
        kRouteLayerId,
        routeJson,
        [],
        isActive: true,
      );

      return RouteListItem(
        title: title,
        transportationMode: getTransportationModeFromString(modeStr),
        imageUrl: imageUrl,
        route: route,
      );
    }

    throw const FormatException('Invalid JSON format for Route item');
  }

  @override
  Item? jsonToItem(dynamic jsonObject) {
    if (jsonObject is Map<String, dynamic>) {
      return RouteListItem.fromJson(jsonObject);
    }
    return null;
  }
}
