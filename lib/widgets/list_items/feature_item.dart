import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:trailblaze/data/feature.dart';
import 'package:trailblaze/managers/place_manager.dart';
import 'package:trailblaze/util/distance_helper.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';
import 'package:turf/turf.dart' as turf;

class FeatureItem extends StatefulWidget {
  final Feature feature;
  final turf.Position? userLocation;
  final void Function() onClicked;
  final void Function() onDirections;

  const FeatureItem({
    super.key,
    required this.feature,
    required this.userLocation,
    required this.onClicked,
    required this.onDirections,
  });

  @override
  State<FeatureItem> createState() => _FeatureItemState();
}

class _FeatureItemState extends State<FeatureItem> {
  final PlaceManager manager = PlaceManager();
  bool _isSaved = false;
  late final String _featureId = widget.feature.id;

  @override
  void initState() {
    super.initState();
    loadSavedStatus();
  }

  void loadSavedStatus() async {
    final status = await manager.doesPlaceExist(_featureId);
    setState(() {
      _isSaved = status;
    });
  }

  String getDistance() {
    if (widget.userLocation == null) {
      return "";
    }

    final point1Coord = turf.Point(
      coordinates:
          turf.Position(widget.userLocation!.lng, widget.userLocation!.lat),
    );
    final point2Coord = turf.Point(
      coordinates: turf.Position(
          widget.feature.center['lon'], widget.feature.center['lat']),
    );

    return FormatHelper.formatDistancePrecise(
        DistanceHelper.euclideanDistance(point1Coord, point2Coord));
  }

  void _onSaveClick() async {
    if (_isSaved) {
      manager.deleteFeature(_featureId);
      setState(() {
        _isSaved = false;
      });
    } else {
      manager.writeMapboxPlace(
        _featureId,
        widget.feature.tags['name'],
        widget.feature.tags['address'],
        jsonEncode(
          {
            "type": "Point",
            "coordinates": [
              widget.feature.center['lon'],
              widget.feature.center['lat']
            ]
          },
        ),
      );

      setState(() {
        _isSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          widget.onClicked();
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
                                    widget.feature.tags['type'] == 'park'
                                        ? Icons.forest_rounded
                                        : Icons.location_on,
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
                                        widget.feature.tags['name'],
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
                                        widget.feature.tags['address'] ?? '',
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
                                  onTap: widget.onDirections,
                                  hasBorder: true,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                IconButtonSmall(
                                  icon: _isSaved
                                      ? Icons.bookmark
                                      : Icons.bookmark_border,
                                  iconFontSize: 22.0,
                                  onTap: _onSaveClick,
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
