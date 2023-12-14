import 'package:flutter/material.dart';

import '../../constants/map_constants.dart';

class MapStyleSelector extends StatefulWidget {
  const MapStyleSelector({
    super.key,
    required this.onStyleChanged,
    this.hasTouchContext = false,
  });

  final void Function(String newStyle) onStyleChanged;
  final bool hasTouchContext;

  @override
  State<MapStyleSelector> createState() => _MapStyleSelectorState();
}

class _MapStyleSelectorState extends State<MapStyleSelector> {
  String _selectedStyle = kMapStyleOptions[0];

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      width: widget.hasTouchContext ? 70 : 40,
      height: widget.hasTouchContext ? 140 : 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          !widget.hasTouchContext
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(_getIconForStyle(_selectedStyle)),
                )
              : Expanded(
                  child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    children: kMapStyleOptions
                        .map((style) => InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedStyle = style;
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
                                        borderRadius: BorderRadius.circular(16),
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
    );
  }

  IconData _getIconForStyle(String style) {
    switch (style) {
      case kMapStyleOutdoors:
        return Icons.layers_outlined;
      case kMapStyleSatellite:
        return Icons.layers;
      default:
        return Icons.layers_outlined;
    }
  }
}
