import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/widgets/place_picker_widget.dart';


class SearchBar extends StatefulWidget {
  const SearchBar({Key? key, this.selectedPlace, required this.onSelected})
      : super(key: key);
  final MapBoxPlace? selectedPlace;
  final void Function(MapBoxPlace?) onSelected;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
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
