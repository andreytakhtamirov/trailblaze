import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trailblaze/trailblaze_icons_icons.dart';

import '../../data/transportation_mode.dart';

class TransportationModeWidget extends StatefulWidget {
  const TransportationModeWidget(
      {Key? key,
      required this.onSelected,
      required this.initialMode,
      required this.isMinifiedView})
      : super(key: key);

  final void Function(TransportationMode) onSelected;
  final TransportationMode initialMode;
  final bool isMinifiedView;

  @override
  State<TransportationModeWidget> createState() =>
      _TransportationModeWidgetState();
}

class _TransportationModeWidgetState extends State<TransportationModeWidget> {
  late TransportationMode _selectedMode;
  bool _isBlinking = false;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;

    if (_selectedMode == TransportationMode.none) {
      startBlinking();
    }
  }

  @override
  void dispose() {
    stopBlinking();
    super.dispose();
  }

  void startBlinking() {
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      setState(() {
        _isBlinking = !_isBlinking;
      });
    });
  }

  void stopBlinking() {
    _isBlinking = false;
    _blinkTimer?.cancel();
  }

  void _handleTransportationModeSelected(
      TransportationMode transportationMode) {
    if (transportationMode != TransportationMode.none) {
      stopBlinking();
    } else {
      startBlinking();
    }

    setState(() {
      _selectedMode = transportationMode;
    });
    widget.onSelected(transportationMode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTransportationModeWidget(
                TransportationMode.walking, Icons.directions_walk, false),
            _buildTransportationModeWidget(
                TransportationMode.cycling, Icons.directions_bike, false),
            _buildTransportationModeWidget(TransportationMode.gravel_cycling,
                TrailblazeIcons.kDirectionsBikeGravel, true),
          ],
        ),
        // Don't show parks+ option for now. Need to design a better UI to select these modes.
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     _buildTransportationModeWidget(
        //       TransportationMode.walking_plus,
        //       TrailblazeIcons.kDirectionsWalkParks,
        //       false,
        //       minIconHeight: 36,
        //     ),
        //     _buildTransportationModeWidget(
        //       TransportationMode.cycling_plus,
        //       TrailblazeIcons.kDirectionsBikeParks,
        //       false,
        //       minIconHeight: 36,
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildTransportationModeWidget(
      TransportationMode mode, IconData icon, bool isCustomIcon,
      {double minIconHeight = 24}) {
    final isSelected = _selectedMode == mode;
    minIconHeight += isCustomIcon ? 8 : 0; // Custom icon needs to be larger

    return GestureDetector(
      onTap: () {
        _handleTransportationModeSelected(mode);
      },
      child: Stack(
        children: [
          AnimatedContainer(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Colors.redAccent)
                  : _isBlinking
                      ? Border.all(color: Colors.orange)
                      : Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(8),
            ),
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                Icon(icon, size: widget.isMinifiedView ? 42 : minIconHeight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
