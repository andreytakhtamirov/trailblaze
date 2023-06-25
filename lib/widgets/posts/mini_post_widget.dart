import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:trailblaze/util/format_helper.dart';

import '../../data/list_item.dart';
import '../../data/transportation_mode.dart';
import '../../screens/post_details_screen.dart';

class MiniPostView extends StatelessWidget {
  final Item item;

  const MiniPostView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailsScreen(item: item),
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
                              item.transportationMode ==
                                      TransportationMode.walking
                                  ? Icons.directions_walk_rounded
                                  : Icons.directions_bike_rounded,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            child: Text(
                              FormatHelper.formatDistance(item.route.distance),
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
    );
  }
}
