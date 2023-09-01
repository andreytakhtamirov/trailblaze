import 'package:flutter/material.dart';

import '../../constants/map_constants.dart';

class MapStyleSelector extends StatefulWidget {
  const MapStyleSelector({super.key, required this.onStyleChanged});

  final void Function(String newStyle) onStyleChanged;

  @override
  State<MapStyleSelector> createState() => _MapStyleSelectorState();
}

class _MapStyleSelectorState extends State<MapStyleSelector> {
  String _selectedStyle = kMapStyleOptions[0];

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: _isExpanded ? 70 : 40,
        height: _isExpanded ? 140 : 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !_isExpanded
                ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.layers),
                )
                : Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: kMapStyleOptions
                          .map((style) => InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedStyle = style;
                                    _isExpanded = false;
                                  });
                                  widget.onStyleChanged(_selectedStyle);
                                },
                                child: Container(
                                  height: 70,
                                  decoration: style == _selectedStyle
                                      ? BoxDecoration(
                                          border: Border.all(
                                              color: Colors.redAccent,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        )
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(_getIconForStyle(style)),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStyle(String style) {
    switch (style) {
      case kMapStyleOutdoors:
        return Icons.nature;
      case kMapStyleSatellite:
        return Icons.satellite;
      default:
        return Icons.nature;
    }
  }
}
