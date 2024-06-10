import 'package:flutter/material.dart';
import 'package:trailblaze/constants/ui_control_constants.dart';
import 'package:trailblaze/screens/distance_selector_screen.dart';
import 'package:trailblaze/util/firebase_helper.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';
import 'package:trailblaze/widgets/map/transportation_mode_widget.dart';

import '../../data/transportation_mode.dart';

class RoundTripControlsWidget extends StatelessWidget {
  final TransportationMode selectedMode;
  final void Function() onBackClicked;
  final void Function(TransportationMode, double?) onModeChanged;
  final double? selectedDistanceMeters;
  final List<double>? center;
  final Function({double? distanceMeters}) onDistanceChanged;

  const RoundTripControlsWidget({
    super.key,
    required this.selectedMode,
    required this.onBackClicked,
    required this.onModeChanged,
    this.selectedDistanceMeters,
    this.center,
    required this.onDistanceChanged,
  });

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
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: const Text(
                  "Route Explorer",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(48, 8, 48, 0),
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildControls(context),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                child: TransportationModeWidget(
                    onSelected: (mode) => {onModeChanged(mode, null)},
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
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _buildEditButton(context),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: IconButtonSmall(
        text:
            "Target Distance ${FormatHelper.formatDistance(selectedDistanceMeters, noRemainder: true)}",
        textFontSize: 20,
        icon: Icons.edit,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        foregroundColor: Colors.white,
        onTap: () async {
          FirebaseHelper.logScreen("DistanceSelectorScreen(RoundTrip)");
          final distanceKm = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DistanceSelectorScreen(
                center: center,
                initialDistanceMeters:
                    selectedDistanceMeters ?? kDefaultRoundTripDistanceMeters,
                minDistanceKm: kMinRoundTripFilterKm,
                maxDistanceKm: kMaxRoundTripFilterKm,
                minZoom: kMinRoundTripFilterCameraZoom,
                maxZoom: kMaxRoundTripFilterCameraZoom,
              ),
            ),
          );

          if (distanceKm == null) {
            return;
          }

          onDistanceChanged(distanceMeters: distanceKm * 1000);
        },
        // onTap: _onSelectDistanceTap,
      ),
    );
  }
}
