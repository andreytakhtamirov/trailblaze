import 'package:flutter/material.dart';

import '../constants/create_route_constants.dart';
import '../data/transportation_mode.dart';

class TransportationModeWidget extends StatefulWidget {
  const TransportationModeWidget(
      {Key? key, required this.onSelected, required this.initialMode})
      : super(key: key);

  final void Function(TransportationMode) onSelected;
  final TransportationMode initialMode;

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
          TransportationMode.walking,
          Icons.directions_walk,
          'Walking',
        ),
        const SizedBox(width: 120),
        _buildTransportationModeWidget(
          TransportationMode.cycling,
          Icons.directions_bike,
          'Cycling',
        ),
      ],
    );
  }

  Widget _buildTransportationModeWidget(
    TransportationMode mode,
    IconData icon,
    String label,
  ) {
    final isSelected = _selectedMode == mode;

    return GestureDetector(
      onTap: () {
        _handleTransportationModeSelected(mode);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: Colors.redAccent) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28),
          ],
        ),
      ),
    );
  }
}
