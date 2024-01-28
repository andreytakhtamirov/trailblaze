import 'dart:async';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:trailblaze/data/profile.dart';
import 'package:trailblaze/requests/user_profile.dart';
import 'package:trailblaze/util/ui_helper.dart';

class ListItemActionHelper {
  static Future<bool?> deleteRouteById(
    BuildContext context,
    Profile? profile,
    Credentials? credentials,
    String itemId,
  ) async {
    final response = await deleteRoute(
        credentials?.idToken ?? '', profile?.id ?? '', itemId);
    Completer<bool> completer = Completer();

    response.fold(
      (error) => {
        UiHelper.showSnackBar(context, 'Failed to delete route.'),
        completer.complete(false),
      },
      (data) => {
        // Route deleted successfully.
        UiHelper.showSnackBar(context, "Route deleted successfully."),
        completer.complete(true),
      },
    );

    return completer.future;
  }
}
