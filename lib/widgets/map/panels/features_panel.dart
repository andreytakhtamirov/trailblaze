import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/constants/ui_control_constants.dart';
import 'package:trailblaze/data/feature.dart';
import 'package:trailblaze/screens/distance_selector_screen.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/list_items/feature_item.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';

class FeaturesPanel extends StatefulWidget {
  const FeaturesPanel({
    Key? key,
    required this.panelController,
    required this.pageController,
    required this.features,
    this.userLocation,
    this.selectedDistanceMeters,
    required this.onFeaturePageChanged,
    required this.onDistanceChanged,
  }) : super(key: key);
  final PanelController panelController;
  final PageController pageController;
  final List<Feature>? features;
  final geo.Position? userLocation;
  final double? selectedDistanceMeters;
  final Function(int page) onFeaturePageChanged;
  final Function(double distance) onDistanceChanged;

  @override
  State<FeaturesPanel> createState() => _FeaturesPanelState();
}

class _FeaturesPanelState extends State<FeaturesPanel> {
  double _valueKm = (kDefaultFeatureDistanceMeters / 1000);

  @override
  void initState() {
    super.initState();
    if (widget.selectedDistanceMeters != null) {
      setState(() {
        _valueKm = widget.selectedDistanceMeters! / 1000;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  textAlign: TextAlign.center,
                  "Nearby Parks – ${FormatHelper.formatDistance(widget.selectedDistanceMeters)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        IgnorePointer(
          ignoring: widget.panelController.isAttached &&
              widget.panelController.isPanelClosed,
          child: SizedBox(
            height: kFeatureItemHeight,
            child: widget.features != null && widget.features!.isNotEmpty
                ? PageView.builder(
                    controller: widget.pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.features?.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FeatureItem(
                          feature: widget.features![index],
                          userLocation: widget.userLocation,
                          onClicked: () {
                            widget.pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                        ),
                      );
                    },
                    onPageChanged: widget.onFeaturePageChanged,
                  )
                : widget.features == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 52),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "No Features Found.\nTry expanding the search distance.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: IconButtonSmall(
            text:
                "Target Distance ${FormatHelper.formatDistance(widget.selectedDistanceMeters, noRemainder: true)}",
            textFontSize: 20,
            icon: Icons.edit,
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            foregroundColor: Colors.white,
            onTap: () async {
              final distanceKm = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DistanceSelectorScreen(
                    center: [
                      widget.userLocation!.longitude,
                      widget.userLocation!.latitude
                    ],
                    initialDistanceMeters: widget.selectedDistanceMeters ??
                        kDefaultFeatureDistanceMeters,
                    minDistanceKm: kMinFeatureDistanceMeters/1000,
                    maxDistanceKm: kMaxFeatureDistanceMeters/1000,
                    minZoom: kMinFeatureFilterCameraZoom,
                    maxZoom: kMaxFeatureFilterCameraZoom,
                  ),
                ),
              );

              if (distanceKm == null) {
                return;
              }

              widget.onDistanceChanged(distanceKm * 1000);
            },
            // onTap: _onSelectDistanceTap,
          ),
        )
      ],
    );
  }
}
