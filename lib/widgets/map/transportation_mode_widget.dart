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
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: _buildTransportationModeWidget(
                    TransportationMode.walking, Icons.directions_walk, false),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: _buildTransportationModeWidget(
                    TransportationMode.cycling, Icons.directions_bike, false),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: _buildTransportationModeWidget(
                    TransportationMode.gravel_cycling,
                    TrailblazeIcons.kDirectionsBikeGravel,
                    true),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransportationModeWidget(
      TransportationMode mode, IconData icon, bool isCustomIcon,
      {double minIconHeight = 24}) {
    final isSelected = _selectedMode == mode;
    minIconHeight += (isCustomIcon ? 8 : 0) +
        (widget.isMinifiedView ? 16 : 0); // Custom icon needs to be larger
    final double verticalPadding =
        (widget.isMinifiedView ? 0 : 4) + (isCustomIcon ? 0 : 4);

    return GestureDetector(
      onTap: () {
        _handleTransportationModeSelected(mode);
      },
      child: Stack(
        children: [
          AnimatedContainer(
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Colors.redAccent)
                  : _isBlinking
                      ? Border.all(color: Colors.orange)
                      : Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(16),
            ),
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Icon(icon, size: minIconHeight)],
            ),
          ),
        ],
      ),
    );
  }
}
