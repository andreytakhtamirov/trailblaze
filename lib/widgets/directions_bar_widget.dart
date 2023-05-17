import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/widgets/search_bar_widget.dart';

import '../constants/create_route_constants.dart';
import '../constants/map_constants.dart';

class DirectionsBar extends StatefulWidget {
  const DirectionsBar({Key? key, this.selectedPlace, required this.onSelected})
      : super(key: key);
  final MapBoxPlace? selectedPlace;
  final void Function(MapBoxPlace?) onSelected;

  @override
  State<DirectionsBar> createState() => _DirectionsBarState();
}

class _DirectionsBarState extends State<DirectionsBar> {
  @override
  void initState() {
    super.initState();
  }

  void _onPlaceSelected(MapBoxPlace? place) {
    widget.onSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                SearchBar(onSelected: _onPlaceSelected),
                SearchBar(onSelected: _onPlaceSelected),
                SearchBar(onSelected: _onPlaceSelected),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
