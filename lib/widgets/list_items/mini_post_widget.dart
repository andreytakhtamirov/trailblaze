import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailblaze/managers/credential_manager.dart';
import 'package:trailblaze/managers/profile_manager.dart';
import 'package:trailblaze/screens/route_details.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';

import '../../data/list_item.dart';

class MiniPostView extends ConsumerWidget {
  final Item item;
  final Function(String) onItemDeleted;

  const MiniPostView({
    super.key,
    required this.item,
    required this.onItemDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final credentials = ref.watch(credentialsProvider);

    return Dismissible(
      direction: item.isDismissible
          ? DismissDirection.horizontal
          : DismissDirection.none,
      key: Key(
        item.hashCode.toString(),
      ),
      dismissThresholds: const {
        DismissDirection.endToStart: 0.2,
        DismissDirection.startToEnd: 0.2,
      },
      secondaryBackground: Container(
        color: Colors.red,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.all(36),
              child: Icon(
                Icons.delete,
                size: 32,
              ),
            ),
          ],
        ),
      ),
      background: Container(
        color: Colors.green,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(36),
              child: Icon(
                Icons.public_rounded,
                size: 32,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        bool? confirmed;

        if (direction == DismissDirection.endToStart) {
          if (context.mounted) {
            confirmed = await item.onSwipeEndToStartAction(
              context,
              profile,
              credentials,
            );
            if (confirmed != null && confirmed) {
              onItemDeleted(item.id);
            }
          }
        } else if (direction == DismissDirection.startToEnd) {
          // TODO Post action
          UiHelper.showSnackBar(context, 'Creating posts is not possible yet.');
        }

        return confirmed;
      },
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RouteDetails(item: item),
            ),
          );
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: CachedNetworkImage(
                        fit: BoxFit.scaleDown,
                        imageUrl: item.imageUrl,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fadeOutDuration: const Duration(milliseconds: 0),
                        fadeInDuration: const Duration(milliseconds: 0),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..scale(-1.0, 1.0, 1.0),
                              child: Icon(
                                UiHelper.iconForTransportationMode(
                                    item.transportationMode),
                                color: Colors.green.shade800,
                                size: 36,
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              child: Text(
                                FormatHelper.formatDistance(
                                    item.route.distance),
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
