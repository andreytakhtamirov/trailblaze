import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/screens/search_screen.dart';
import 'package:trailblaze/data/feature.dart' as tb;

import '../../constants/map_constants.dart';

class PlacePicker extends StatelessWidget {
  const PlacePicker({
    Key? key,
    this.heroTag = 'Search',
    this.selectedPlace,
    this.isEditLocationsView = false,
    required this.onSelected,
    required this.onSelectFeatures,
    required this.onSearchBarTap,
  }) : super(key: key);
  final String heroTag;
  final MapBoxPlace? selectedPlace;
  final bool isEditLocationsView;
  final void Function(MapBoxPlace?) onSelected;
  final void Function(String categoryId, List<tb.Feature>) onSelectFeatures;
  final void Function() onSearchBarTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: kSearchBarHeight,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _showSearchScreen(context),
        child: Hero(
          tag: heroTag,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(Icons.search),
              ),
              Expanded(
                child: Text(
                  selectedPlace?.placeName ?? 'Search',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Visibility(
                visible: selectedPlace?.placeName != null,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    onSelected(null);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchScreen(BuildContext context) async {
    onSearchBarTap();
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation1,
            Animation<double> animation2) {
          return SearchScreen(
            selectedPlaceName: isEditLocationsView ? null : selectedPlace?.placeName,
            isEditLocationsView: isEditLocationsView,
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
      onSelected(result);
    } else if (result['categoryId'] != null) {
      onSelectFeatures(
        result['categoryId'],
        result['features'],
      );
    }
  }
}
