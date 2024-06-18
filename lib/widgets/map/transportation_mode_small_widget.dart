import 'package:flutter/material.dart';
import 'package:trailblaze/trailblaze_icons_icons.dart';

import '../../data/transportation_mode.dart';

class TransportationModeSmallWidget extends StatelessWidget {
  final TransportationMode selectedMode;
  const TransportationModeSmallWidget({super.key, required this.selectedMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _showSelectedMode(),
        ],
      ),
    );
  }

  Widget _buildTransportationModeWidget(
      TransportationMode mode, IconData icon, bool isCustomIcon,
      {double minIconHeight = 24}) {
    minIconHeight += isCustomIcon ? 8 : 0; // Custom icon needs to be larger

    return Stack(
      children: [
        AnimatedContainer(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          duration: const Duration(milliseconds: 300),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: minIconHeight)
            ],
          ),
        ),
      ],
    );
  }

  Widget _showSelectedMode() {
    switch (selectedMode) {
      case TransportationMode.walking:
        return _buildTransportationModeWidget(
          TransportationMode.walking,
          Icons.directions_walk,
          false,
        );
      case TransportationMode.cycling:
        return _buildTransportationModeWidget(
          TransportationMode.cycling,
          Icons.directions_bike,
          false,
        );
      case TransportationMode.gravel_cycling:
        return _buildTransportationModeWidget(
          TransportationMode.gravel_cycling,
          TrailblazeIcons.kDirectionsBikeGravel,
          true,
        );
      default:
        return const SizedBox();
    }
  }
}
