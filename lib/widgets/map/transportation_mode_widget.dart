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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTransportationModeWidget(
            TransportationMode.walking, TrailblazeIcons.kDirectionsWalkParks, false),
        _buildTransportationModeWidget(
            TransportationMode.cycling, TrailblazeIcons.kDirectionsBikeParks, false),
        _buildTransportationModeWidget(TransportationMode.gravelCycling,
            TrailblazeIcons.kDirectionsBikeGravel, true),
      ],
    );
  }

  Widget _buildTransportationModeWidget(
    TransportationMode mode,
    IconData icon,
    bool isBetaFeature,
  ) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () {
        _handleTransportationModeSelected(mode);
      },
      child: Stack(
        children: [
          AnimatedContainer(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                Icon(icon, size: widget.isMinifiedView ? 42 : 24),
              ],
            ),
          ),
          if (isBetaFeature)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Beta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
