import 'package:flutter/material.dart';
import 'package:trailblaze/data/list_item.dart';
import 'package:trailblaze/requests/fetch_items.dart';
import 'package:trailblaze/widgets/items_feed_widget.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage>
    with AutomaticKeepAliveClientMixin<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Routes'),
      ),
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: ItemsFeed(
          PostsApiService(),
          PostListItem,
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
