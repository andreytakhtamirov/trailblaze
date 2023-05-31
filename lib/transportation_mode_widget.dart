import 'package:flutter/material.dart';
import 'package:trailblaze/trailblaze_icons_icons.dart';

import 'data/transportation_mode.dart';

class TransportationModeWidget extends StatefulWidget {
  const TransportationModeWidget(
      {Key? key, required this.onSelected, required this.initialMode, required this.isMinifiedView})
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

  void _handleTransportationModeSelected(
      TransportationMode transportationMode) {
    setState(() {
      _selectedMode = transportationMode;
    });
    widget.onSelected(transportationMode);
  }

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTransportationModeWidget(
            TransportationMode.walking, Icons.directions_walk, false),
        SizedBox(width: widget.isMinifiedView ? 30 : 60),
        _buildTransportationModeWidget(
            TransportationMode.cycling, Icons.directions_bike, false),
        SizedBox(width: widget.isMinifiedView ? 30 : 60),
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
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              border: isSelected ? Border.all(color: Colors.redAccent) : null,
              borderRadius: BorderRadius.circular(8),
            ),
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
