import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/extensions/mapbox_place_extension.dart';
import 'package:trailblaze/constants/request_api_constants.dart';
import 'package:trailblaze/data/profile.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/data/transportation_mode.dart';
import 'package:trailblaze/util/list_item_action_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';

import '../constants/discover_constants.dart';
import '../constants/map_constants.dart';

abstract class Item {
  String get id;

  String get title;

  String? get description;

  int? get likes;

  TransportationMode get transportationMode;

  String get imageUrl;

  TrailblazeRoute get route;

  bool get isDismissible;

  Item? jsonToItem(dynamic jsonObject);

  Future<bool?> onSwipeEndToStartAction(
      BuildContext context, Profile? profile, Credentials? credentials);

  Future<bool?> onSwipeStartToEndAction(
      BuildContext context, Profile? profile, Credentials? credentials);
}

class PostListItem implements Item {
  @override
  final String id;
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
  @override
  final bool isDismissible = false;

  PostListItem({
    required this.id,
    required this.title,
    required this.description,
    required this.likes,
    required this.transportationMode,
    required this.imageUrl,
    required this.route,
  });

  factory PostListItem.fromJson(dynamic itemJson) {
    final id = itemJson[kJsonKeyId];
    final title = itemJson[kJsonKeyPostTitle];
    final description = itemJson[kJsonKeyPostDescription];
    final likes = itemJson[kJsonKeyPostLikes];
    final routeOptions =
        itemJson[kJsonKeyPostRouteId][kJsonKeyPostRouteOptions];
    final modeString = routeOptions[kJsonKeyPostProfile];
    final imageUrl = itemJson[kJsonKeyPostRouteId][kJsonKeyPostImageUrl];
    final routeJson = itemJson[kJsonKeyPostRouteId][kJsonKeyPostRoute];
    final routeType = itemJson[kJsonKeyRouteType];
    final waypoints = routeOptions[kJsonKeyWaypoints];

    if (id != null &&
        title != null &&
        description != null &&
        routeOptions != null &&
        modeString != null &&
        imageUrl != null &&
        waypoints != null) {
      final List<MapBoxPlace> places = [];
      for (dynamic w in waypoints) {
        places.add(MapBoxPlaceExtensions.fromJsonTb(w));
      }

      TrailblazeRoute route = TrailblazeRoute(
        kRouteSourceId,
        kRouteLayerId,
        routeJson,
        places,
        routeOptions,
        isActive: true,
        isGraphhopperRoute: routeType == kRouteTypeGraphhopper,
      );

      return PostListItem(
        id: id,
        title: title,
        description: description,
        transportationMode: getTransportationModeFromString(modeString),
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

  @override
  Future<bool?> onSwipeEndToStartAction(
      BuildContext context, Profile? profile, Credentials? credentials) async {
    throw const FormatException(
        'Post Swipe End to Start action not implemented');
  }

  @override
  Future<bool?> onSwipeStartToEndAction(
      BuildContext context, Profile? profile, Credentials? credentials) async {
    throw const FormatException(
        'Post Swipe Start to End action not implemented');
  }
}

class RouteListItem implements Item {
  @override
  final String id;
  @override
  final String title;
  @override
  final TransportationMode transportationMode;
  @override
  final String imageUrl;
  @override
  final TrailblazeRoute route;
  @override
  final bool isDismissible = true;

  // These are unused since a route can't have a description or likes.
  @override
  String? get description => null;

  @override
  int? get likes => null;

  RouteListItem({
    required this.id,
    required this.title,
    required this.transportationMode,
    required this.imageUrl,
    required this.route,
  });

  factory RouteListItem.fromJson(dynamic itemJson) {
    final id = itemJson[kJsonKeyId];
    final title = itemJson[kJsonKeyPostTitle];
    final distance = itemJson[kJsonKeyPostRoute][kJsonKeyPostDistance];
    final routeOptions = itemJson[kJsonKeyPostRouteOptions];
    final modeString = routeOptions[kJsonKeyPostProfile];
    final imageUrl = itemJson[kJsonKeyPostImageUrl];
    final routeJson = itemJson[kJsonKeyPostRoute];
    final routeType = itemJson[kJsonKeyRouteType];
    final waypoints = routeOptions[kJsonKeyWaypoints];

    final List<MapBoxPlace> places = [];
    for (dynamic w in waypoints) {
      places.add(MapBoxPlaceExtensions.fromJsonTb(w));
    }

    if (id != null &&
        title != null &&
        distance != null &&
        routeOptions != null &&
        modeString != null &&
        imageUrl != null &&
        waypoints != null) {
      TrailblazeRoute route = TrailblazeRoute(
        kRouteSourceId,
        kRouteLayerId,
        routeJson,
        places,
        routeOptions,
        isActive: true,
        isGraphhopperRoute: routeType == kRouteTypeGraphhopper,
      );

      return RouteListItem(
        id: id,
        title: title,
        transportationMode: getTransportationModeFromString(modeString),
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

  @override
  Future<bool?> onSwipeEndToStartAction(
      BuildContext context, Profile? profile, Credentials? credentials) async {
    bool? confirmed;

    confirmed = await UiHelper.showConfirmationDialog(
      context,
      'Delete Route?',
      'Are you sure you want to delete this route?',
      'Delete',
      'Cancel',
      Colors.red,
      Colors.white,
    );

    if (context.mounted && confirmed != null && confirmed) {
      confirmed = await ListItemActionHelper.deleteRouteById(
          context, profile, credentials, id);
    }

    return confirmed;
  }

  @override
  Future<bool?> onSwipeStartToEndAction(
      BuildContext context, Profile? profile, Credentials? credentials) {
    throw const FormatException(
        'Route Swipe Start to End action not implemented');
  }
}
