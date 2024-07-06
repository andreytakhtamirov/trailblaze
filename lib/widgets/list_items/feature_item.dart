import 'package:flutter/material.dart';
import 'package:trailblaze/data/feature.dart';
import 'package:trailblaze/util/distance_helper.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:turf/turf.dart' as turf;

class FeatureItem extends StatelessWidget {
  final Feature feature;
  final turf.Position? userLocation;
  final void Function() onClicked;

  const FeatureItem({
    super.key,
    required this.feature,
    required this.userLocation,
    required this.onClicked,
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
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: () {
          onClicked();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onTertiary.withOpacity(0.2),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(20),
          ),
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
                        Expanded(
                          flex: 2,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: FittedBox(
                                  child: Icon(
                                    Icons.forest_rounded,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
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
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          feature.tags['name'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
