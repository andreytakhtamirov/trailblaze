import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';
import 'package:trailblaze/data/list_item.dart';
import 'package:trailblaze/requests/fetch_items.dart';
import 'package:trailblaze/widgets/items_feed_widget.dart';

class ProfileTabsWidget extends StatelessWidget {
  const ProfileTabsWidget({
    super.key,
    this.credentials,
  });

  final Credentials? credentials;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                icon: Icon(
                  Icons.route_outlined,
                ),
              ),
              // Tab(
              //   icon: Icon(
              //     Icons.favorite_border,
              //   ),
              // ),
            ],
          ),
          Expanded(
            child: ItemsFeed(
              UserRoutesApiService(),
              RouteListItem,
              isMinified: true,
              jwtToken: credentials?.idToken ?? '',
              feedInfoText: "Routes you've created will appear here.",
            ),
          ),
          // Expanded(
          //   child: TabBarView(
          //     physics: const NeverScrollableScrollPhysics(),
          //     children: [
          //       ItemsFeed(
          //         LikedPostsApiService(),
          //         PostListItem,
          //         isMinified: true,
          //         jwtToken: credentials?.idToken ?? '',
          //         feedInfoText: "Posts you've liked will appear here.",
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
