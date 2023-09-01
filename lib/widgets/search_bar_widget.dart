import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/widgets/map/place_picker_widget.dart';


class PlaceSearchBar extends StatefulWidget {
  const PlaceSearchBar({Key? key, this.selectedPlace, required this.onSelected})
      : super(key: key);
  final MapBoxPlace? selectedPlace;
  final void Function(MapBoxPlace?) onSelected;

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
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(20),
        child: GestureDetector(
          child: PlacePicker(
            selectedPlace: widget.selectedPlace,
            onSelected: widget.onSelected,
          ),
        ),
      ),
    );
  }
}
