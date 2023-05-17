import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/create_route_constants.dart';
import 'package:trailblaze/widgets/transportation_mode_widget.dart';

class PickedLocationsWidget extends StatelessWidget {
  final MapBoxPlace? startingLocation;
  final MapBoxPlace? endingLocation;
  final List<String> waypoints;
  final void Function() onBackClicked;
  final void Function(TransportationMode) onModeChanged;

  const PickedLocationsWidget({
    Key? key,
    required this.startingLocation,
    required this.endingLocation,
    required this.waypoints,
    required this.onBackClicked,
    required this.onModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 32, 48, 24),
                child: ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildLocationTile('Starting Location',
                        startingLocation!.placeName ?? "Select origin"),
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
                        'Ending Location',
                        endingLocation?.placeName ??
                            endingLocation?.center.toString() ??
                            "Select destination"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: TransportationModeWidget(
                    onSelected: onModeChanged,
                    initialMode: defaultTransportationMode),
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
                Icons.edit_note,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
        child: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}
