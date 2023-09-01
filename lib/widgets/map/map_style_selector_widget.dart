import 'package:flutter/material.dart';

class MapStyleSelector extends StatefulWidget {
  const MapStyleSelector({super.key, required this.onStyleChanged});

  final void Function(String newStyle) onStyleChanged;

  @override
  State<MapStyleSelector> createState() => _MapStyleSelectorState();
}

class _MapStyleSelectorState extends State<MapStyleSelector> {
  String _selectedStyle = 'outdoors-v12';
  final List<String> _styleOptions = [
    'outdoors-v12',
    'streets-v12',
    'satellite-streets-v12',
    'dark-v10',
  ];

  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Container(
        width: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            !_isExpanded
                ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(_getIconForStyle(_selectedStyle)),
                )
                : Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      children: _styleOptions
                          .map((style) => InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedStyle = style;
                                    _isExpanded = false;
                                  });
                                  widget.onStyleChanged(_selectedStyle);
                                },
                                child: Container(
                                  decoration: style == _selectedStyle
                                      ? BoxDecoration(
                                          border: Border.all(
                                              color: Colors.redAccent,
                                              width: 2.0),
                                          borderRadius:
                                              BorderRadius.circular(4),
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
      case 'outdoors-v12':
        return Icons.nature;
      case 'streets-v12':
        return Icons.location_city;
      case 'satellite-streets-v12':
        return Icons.satellite;
      case 'dark-v10':
        return Icons.nightlight_round;
      default:
        return Icons.nature;
    }
  }
}
