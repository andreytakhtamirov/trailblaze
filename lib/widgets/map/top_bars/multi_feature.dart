import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/widgets/map/place_picker_widget.dart';

import '../../../data/feature.dart' as tb;

class MultiFeatureTopBar extends StatefulWidget {
  final MapBoxPlace? startingLocation;
  final MapBoxPlace? selectedPlace;
  final void Function() onBackClick;
  final void Function(MapBoxPlace?) onSelected;
  final void Function(String categoryId, List<tb.Feature>) onSelectFeatures;
  final void Function() onSearchBarTap;

  const MultiFeatureTopBar({
    super.key,
    this.startingLocation,
    required this.selectedPlace,
    required this.onBackClick,
    required this.onSelected,
    required this.onSelectFeatures,
    required this.onSearchBarTap,
  });

  @override
  State<MultiFeatureTopBar> createState() => _MultiFeatureTopBarState();
}

class _MultiFeatureTopBarState extends State<MultiFeatureTopBar> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 8, 8, 8),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: PlacePicker(
                        transparentBackground: true,
                        selectedPlace: widget.selectedPlace,
                        onSelected: widget.onSelected,
                        onSelectFeatures: widget.onSelectFeatures,
                        onSearchBarTap: widget.onSearchBarTap,
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                child: IconButton(
                  padding: const EdgeInsets.all(16),
                  iconSize: 32,
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: widget.onBackClick,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
