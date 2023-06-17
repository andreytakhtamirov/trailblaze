import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:trailblaze/data/transportation_mode.dart';
import 'package:trailblaze/requests/fetch_posts.dart';

import '../constants/discover_constants.dart';
import '../constants/map_constants.dart';
import '../data/post.dart';
import '../data/trailblaze_route.dart';
import '../widgets/post_widget.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin<DiscoverPage> {
  final ScrollController _scrollController = ScrollController();
  final PagingController<int, Post> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPosts(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
    _scrollController.dispose();
  }

  Future<void> _fetchPosts(int pageKey) async {
    final fetchedPosts = await getPosts(pageKey);

    if (fetchedPosts != null) {
      final newPosts = fetchedPosts.map((post) {
        try {
          final title = post[kJsonKeyPostTitle];
          final description = post[kJsonKeyPostDescription];
          final likes = post[kJsonKeyPostLikes];
          final distance = post[kJsonKeyPostRouteId][kJsonKeyPostRoute]
              [kJsonKeyPostDistance];
          final modeStr = post[kJsonKeyPostRouteId][kJsonKeyPostRouteOptions]
              [kJsonKeyPostProfile];
          final imageUrl = post[kJsonKeyPostRouteId][kJsonKeyPostImageUrl];
          final routeJson = post[kJsonKeyPostRouteId][kJsonKeyPostRoute];

          if (title != null &&
              description != null &&
              distance != null &&
              modeStr != null &&
              imageUrl != null) {
            TrailblazeRoute route = TrailblazeRoute(
                kRouteSourceId, kRouteLayerId, routeJson,
                isActive: true);

            return Post(
                title: title,
                description: description,
                distance: distance,
                transportationMode: getTransportationModeFromString(modeStr),
                likes: likes,
                imageUrl: imageUrl,
                route: route);
          }
        } catch (e) {
          _pagingController.error = e;
        }

        return null;
      }).whereType<Post>();

      final isLastPage = newPosts.length < pageKey * postsPerPage;
      if (isLastPage) {
        _pagingController.appendLastPage(newPosts.toList());
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newPosts.toList(), nextPageKey);
      }
    } else {
      _pagingController.error = 'Failed to fetch posts';
    }
  }

  Future<void> _refreshPosts() async {
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: Container(
          color: Colors.grey.withOpacity(0.4),
          child: Scrollbar(
            controller: _scrollController,
            scrollbarOrientation: ScrollbarOrientation.right,
            thumbVisibility: _pagingController.itemList?.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: PagedListView<int, Post>(
                padding: EdgeInsets.zero,
                scrollController: _scrollController,
                pagingController: _pagingController,
                builderDelegate: PagedChildBuilderDelegate<Post>(
                  itemBuilder: (context, item, index) => PostView(
                    post: item,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
