import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/widgets/map/transportation_mode_widget.dart';

import '../../data/transportation_mode.dart';

class PickedLocationsWidget extends StatelessWidget {
  final MapBoxPlace? startingLocation;
  final MapBoxPlace? endingLocation;
  final List<String> waypoints;
  final TransportationMode selectedMode;
  final void Function() onBackClicked;
  final void Function(TransportationMode) onModeChanged;

  const PickedLocationsWidget(
      {super.key,
      this.startingLocation,
      this.endingLocation,
      required this.selectedMode,
      required this.waypoints,
      required this.onBackClicked,
      required this.onModeChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: selectedMode == TransportationMode.none
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 8, 48, 0),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildLocationTile(
                              title: startingLocation!.placeName ??
                                  "Select origin"),
                          Visibility(
                            visible: waypoints.isNotEmpty,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${waypoints.length} waypoints",
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildLocationTile(
                              title: endingLocation?.placeName ??
                                  endingLocation?.center.toString() ??
                                  "Select destination"),
                        ],
                      ),
                    ),
                  ],
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 8, 48, 4),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildLocationTile(
                              title: 'Starting Location',
                              subtitle: startingLocation!.placeName ??
                                  "Select origin"),
                          Visibility(
                            visible: waypoints.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${waypoints.length} waypoints",
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildLocationTile(
                              title: 'Ending Location',
                              subtitle: endingLocation?.placeName ??
                                  endingLocation?.center.toString() ??
                                  "Select destination"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: TransportationModeWidget(
                    onSelected: onModeChanged,
                    initialMode: selectedMode,
                    isMinifiedView: selectedMode == TransportationMode.none),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              padding: const EdgeInsets.all(16),
              iconSize: 32,
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackClicked,
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(
                Icons.edit_location_alt_outlined,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile({required String title, String? subtitle}) {
    bool isDense = subtitle == null;
    return ListTile(
        dense: isDense,
        visualDensity: VisualDensity.comfortable,
        title: Text(
          title,
          maxLines: selectedMode == TransportationMode.none
              ? 5
              : 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: !isDense ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: !isDense
            ? Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                child: Text(
                  subtitle,
                  maxLines: selectedMode == TransportationMode.none
                      ? 5
                      : 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              )
            : null);
  }
}
