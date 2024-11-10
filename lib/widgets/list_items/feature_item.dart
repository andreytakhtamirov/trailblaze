import 'package:flutter/material.dart';
import 'package:trailblaze/data/feature.dart';
import 'package:trailblaze/util/distance_helper.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';
import 'package:turf/turf.dart' as turf;

class FeatureItem extends StatelessWidget {
  final Feature feature;
  final turf.Position? userLocation;
  final void Function() onClicked;
  final void Function() onDirections;
  final void Function() onSave;

  const FeatureItem({
    super.key,
    required this.feature,
    required this.userLocation,
    required this.onClicked,
    required this.onDirections,
    required this.onSave,
  });

  String getDistance() {
    if (userLocation == null) {
      return "";
    }

    final point1Coord = turf.Point(
      coordinates: turf.Position(userLocation!.lng, userLocation!.lat),
    );
    final point2Coord = turf.Point(
      coordinates: turf.Position(feature.center['lon'], feature.center['lat']),
    );

    return FormatHelper.formatDistancePrecise(
        DistanceHelper.euclideanDistance(point1Coord, point2Coord));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          onClicked();
        },
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    Icons.forest_rounded, // TODO type dependent icon
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        feature.tags['name'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      Text(
                                        feature.tags['address'] ?? '',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  textAlign: TextAlign.end,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  getDistance(),
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                IconButtonSmall(
                                  text: 'Directions',
                                  icon: Icons.directions,
                                  iconFontSize: 18.0,
                                  textFontSize: 14,
                                  onTap: onDirections,
                                  hasBorder: true,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                IconButtonSmall(
                                  icon: Icons.bookmark_border,
                                  iconFontSize: 22.0,
                                  onTap: onSave,
                                  hasBorder: true,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ],
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
