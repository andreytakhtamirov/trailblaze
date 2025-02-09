import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';
import 'package:trailblaze/widgets/map/place_picker_widget.dart';
import 'package:trailblaze/data/feature.dart' as tb;

class PlaceSearchBar extends StatefulWidget {
  const PlaceSearchBar({
    Key? key,
    this.selectedPlace,
    this.showBackButton = false,
    required this.onSelected,
    required this.onSelectFeatures,
    required this.onSearchBarTap,
    required this.onBackClick,
  }) : super(key: key);
  final MapBoxPlace? selectedPlace;
  final bool showBackButton;
  final void Function(MapBoxPlace?) onSelected;
  final void Function(String category, List<tb.Feature>) onSelectFeatures;
  final void Function() onSearchBarTap;
  final void Function() onBackClick;

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
      child: Row(
        children: [
          Visibility(
            visible: widget.showBackButton,
            child: Expanded(
              flex: 1,
              child: Material(
                animationDuration: const Duration(milliseconds: 300),
                elevation: 5,
                borderRadius: BorderRadius.circular(20),
                child: IconButtonSmall(
                  iconFontSize: 30,
                  icon: Icons.arrow_back_ios_new,
                  onTap: widget.onBackClick,
                ),
              ),
            ),
          ),
          if (widget.showBackButton) const SizedBox(width: 10),
          Expanded(
            flex: 6,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(20),
              child: PlacePicker(
                selectedPlace: widget.selectedPlace,
                onSelected: widget.onSelected,
                onSelectFeatures: widget.onSelectFeatures,
                onSearchBarTap: widget.onSearchBarTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
