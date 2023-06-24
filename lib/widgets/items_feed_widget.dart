import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:trailblaze/constants/discover_constants.dart';
import 'package:trailblaze/widgets/posts/post_widget.dart';

import '../data/list_item.dart';
import '../requests/fetch_items.dart';
import 'posts/mini_post_widget.dart';

class ItemsFeed extends ConsumerStatefulWidget {
  const ItemsFeed(this.endpointService, this.itemType, {Key? key, this.isMinified = false, this.jwtToken = ""})
      : super(key: key);

  final Type itemType;
  final bool isMinified;
  final String jwtToken;
  final ApiEndpointService endpointService;

  @override
  ConsumerState<ItemsFeed> createState() => _ItemsFeedState();
}

class _ItemsFeedState extends ConsumerState<ItemsFeed> {
  final ScrollController _scrollController = ScrollController();
  final PagingController<int, Item> _pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchItems(pageKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pagingController.dispose();
    _scrollController.dispose();
  }

  Future<void> _fetchItems(int pageKey) async {
    final fetchedItems = await widget.endpointService.fetchData(pageKey, widget.jwtToken);

    if (fetchedItems != null) {
      final newItems = fetchedItems.map((item) {
        try {
          if (widget.itemType == PostListItem) {
            return PostListItem.fromJson(item);
          } else if (widget.itemType == RouteListItem) {
            return RouteListItem.fromJson(item);
          } else {
            return PostListItem.fromJson(item);
          }
        } catch (e) {
          _pagingController.error = e;
        }

        return null;
      }).whereType<Item>();

      final isLastPage = newItems.length < pageKey * kItemsPerPage;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems.toList());
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems.toList(), nextPageKey);
      }
    } else {
      _pagingController.error = 'Failed to fetch items';
    }
  }

  Future<void> _refreshItems() async {
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
          border: const Border(
            top: BorderSide(
              width: 1.0,
              color: Colors.grey,
            ),
            bottom: BorderSide(
              width: 1.0,
              color: Colors.grey,
            ),
          ),
        ),
        child: Scrollbar(
          controller: _scrollController,
          scrollbarOrientation: ScrollbarOrientation.right,
          thumbVisibility: _pagingController.itemList?.isNotEmpty,
          child: PagedListView<int, Item>(
            padding: EdgeInsets.zero,
            scrollController: _scrollController,
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<Item>(
              itemBuilder: (context, item, index) {
                if (widget.isMinified) {
                  return MiniPostView(item: item);
                } else {
                  return PostView(item: item);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
