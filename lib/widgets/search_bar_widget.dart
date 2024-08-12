import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/widgets/map/place_picker_widget.dart';
import 'package:trailblaze/data/feature.dart' as tb;

class PlaceSearchBar extends StatefulWidget {
  const PlaceSearchBar({
    Key? key,
    this.selectedPlace,
    required this.onSelected,
    required this.onSelectFeatures,
  }) : super(key: key);
  final MapBoxPlace? selectedPlace;
  final void Function(MapBoxPlace?) onSelected;
  final void Function(List<tb.Feature>) onSelectFeatures;

  @override
  State<PlaceSearchBar> createState() => _PlaceSearchBarState();
}

class _PlaceSearchBarState extends State<PlaceSearchBar> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: PlacePicker(
          selectedPlace: widget.selectedPlace,
          onSelected: widget.onSelected,
          onSelectFeatures: widget.onSelectFeatures,
        ),
      ),
    );
  }
}
