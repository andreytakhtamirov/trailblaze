import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.credentials,
    this.profile,
    required this.refreshProfile,
    required this.onEditProfilePressed,
  });

  final Credentials? credentials;
  final Profile? profile;
  final Future<void> Function(Credentials?) refreshProfile;
  final void Function(Credentials?) onEditProfilePressed;

  @override
  Widget build(BuildContext context) {
    ImageProvider? userPicture = profile?.profilePicture;
    bool accountSetupNeeded = profile != null && profile!.username == null;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => refreshProfile(credentials),
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 4, 16),
                      child: userPicture != null
                          ? Image(
                              width: 50 * kDevicePixelRatio,
                              fit: BoxFit.fitWidth,
                              image: userPicture,
                            )
                          : CachedNetworkImage(
                              width: 50 * kDevicePixelRatio,
                              fit: BoxFit.fitWidth,
                              imageUrl:
                                  credentials?.user.pictureUrl.toString() ?? '',
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                              fadeOutDuration: const Duration(milliseconds: 0),
                              fadeInDuration: const Duration(milliseconds: 0),
                            ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 48, 16, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                profile?.username ?? credentials?.user.email ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Center(
            child: Visibility(
              visible: accountSetupNeeded,
              child: MaterialButton(
                onPressed: () => onEditProfilePressed(credentials),
                color: Colors.red,
                shape: const StadiumBorder(),
                child: const Text(
                  "Complete account setup",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
