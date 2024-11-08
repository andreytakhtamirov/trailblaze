import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/screens/search_screen.dart';
import 'package:trailblaze/data/feature.dart' as tb;

import '../../constants/map_constants.dart';

class PlacePicker extends StatefulWidget {
  const PlacePicker({
    Key? key,
    this.selectedPlace,
    this.transparentBackground = true,
    required this.onSelected,
    required this.onSelectFeatures,
    required this.onSearchBarTap,
  }) : super(key: key);
  final MapBoxPlace? selectedPlace;
  final bool transparentBackground;
  final void Function(MapBoxPlace?) onSelected;
  final void Function(String categoryId, List<tb.Feature>) onSelectFeatures;
  final void Function() onSearchBarTap;

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  void _onPlaceSelected(MapBoxPlace? place) {
    widget.onSelected(place);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: kSearchBarHeight,
      decoration: BoxDecoration(
        color: widget.transparentBackground ? Colors.transparent : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: _showSearchScreen,
        child: Hero(
          tag: 'Search',
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.search),
              ),
              Expanded(
                child: Text(
                  widget.selectedPlace?.placeName ?? 'Search',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Visibility(
                visible: widget.selectedPlace?.placeName != null,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _onPlaceSelected(null);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchScreen() async {
    widget.onSearchBarTap();
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          return SearchScreen(
            selectedPlaceName: widget.selectedPlace?.placeName,
          );
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    if (result == null) {
      return;
    }

    if (result is MapBoxPlace) {
      widget.onSelected(result);
    } else if (result['categoryId'] != null) {
      widget.onSelectFeatures(
        result['categoryId'],
        result['features'],
      );
    }
  }
}
