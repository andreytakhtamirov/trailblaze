import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:trailblaze/data/feature.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/list_items/feature_item.dart';

class FeaturesPanel extends StatelessWidget {
  const FeaturesPanel({
    Key? key,
    required this.scrollController,
    required this.categoryName,
    required this.features,
    this.userLocation,
    required this.panelPos,
    required this.onSelectFeature,
    required this.onDirectionsClick,
  }) : super(key: key);
  final ScrollController scrollController;
  final String categoryName;
  final List<Feature>? features;
  final mbm.Position? userLocation;
  final double panelPos;
  final Function(Feature feature) onSelectFeature;
  final Function(Feature feature) onDirectionsClick;

  @override
  Widget build(BuildContext context) {
    return panelPos > 0.01
        ? features != null && features!.isNotEmpty
            ? Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  child: MediaQuery.removePadding(
                    context: context,
                    child: Scrollbar(
                      trackVisibility: true,
                      thumbVisibility: true,
                      child: ListView.builder(
                        clipBehavior: Clip.antiAlias,
                        controller: scrollController,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: features?.length,
                        itemBuilder: (context, index) {
                          return FeatureItem(
                            feature: features![index],
                            userLocation: userLocation,
                            onClicked: () {
                              onSelectFeature(features![index]);
                            },
                            onDirections: () {
                              onDirectionsClick(features![index]);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "No ${categoryName}s found.\nTry searching somewhere else.",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(
              "Show ${FormatHelper.toCapitalizedText(categoryName)}s (${features?.length ?? 0})",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.7),
                fontSize: 18,
              ),
            ),
          );
  }
}
