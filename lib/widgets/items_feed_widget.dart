import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:trailblaze/constants/discover_constants.dart';

import '../data/list_item.dart';
import '../requests/fetch_items.dart';
import 'list_items/mini_post_widget.dart';
import 'list_items/post_widget.dart';

class ItemsFeed extends ConsumerStatefulWidget {
  const ItemsFeed(this.endpointService, this.itemType,
      {Key? key,
      this.isMinified = false,
      this.jwtToken = "",
      this.feedInfoText = "No items found."})
      : super(key: key);

  final Type itemType;
  final bool isMinified;
  final String jwtToken;
  final ApiEndpointService endpointService;
  final String feedInfoText;

  @override
  ConsumerState<ItemsFeed> createState() => _ItemsFeedState();
}

class _ItemsFeedState extends ConsumerState<ItemsFeed>
    with AutomaticKeepAliveClientMixin {
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
    final fetchedItems =
        await widget.endpointService.fetchData(pageKey, widget.jwtToken);

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
          log("Item fetch failed: $e");
          _pagingController.error = e;
        }

        return null;
      }).whereType<Item>();

      final isLastPage = newItems.length < kItemsPerPage;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems.toList());
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems.toList(), nextPageKey);
      }
    } else {
      _pagingController.appendLastPage([]);
    }
  }

  Future<void> _refreshItems() async {
    _pagingController.refresh();
  }

  void _onItemDeleted(String itemId) {
    if (_pagingController.itemList == null) {
      return;
    }

    final items = _pagingController.itemList!;
    items.removeWhere((element) => element.id == itemId);
    setState(() {
      _pagingController.itemList = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refreshItems,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.4),
        ),
        child: Scrollbar(
          controller: _scrollController,
          scrollbarOrientation: ScrollbarOrientation.right,
          thumbVisibility: _pagingController.itemList?.isNotEmpty,
          child: PagedListView<int, Item>(
            padding: EdgeInsets.zero,
            scrollController: _scrollController,
            pagingController: _pagingController,
            physics: const AlwaysScrollableScrollPhysics(),
            builderDelegate: PagedChildBuilderDelegate<Item>(
              animateTransitions: true,
              transitionDuration: const Duration(milliseconds: 150),
              noItemsFoundIndicatorBuilder: (context) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      widget.feedInfoText,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
              itemBuilder: (context, item, index) {
                if (widget.isMinified) {
                  return MiniPostView(
                    item: item,
                    onItemDeleted: _onItemDeleted,
                  );
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

  @override
  // Keep feed alive to not refresh the list
  // on navigation to other tabs within the app.
  bool get wantKeepAlive => true;
}
