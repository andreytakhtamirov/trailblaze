import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/extensions/mapbox_search_extension.dart';
import 'package:trailblaze/util/format_helper.dart';

import '../../constants/map_constants.dart';

class PlacePicker extends StatefulWidget {
  const PlacePicker({Key? key, this.selectedPlace, required this.onSelected})
      : super(key: key);
  final MapBoxPlace? selectedPlace;
  final void Function(MapBoxPlace?) onSelected;

  @override
  State<PlacePicker> createState() => _PlacePickerState();
}

class _PlacePickerState extends State<PlacePicker> {
  bool _isExpanded = false;
  final FocusNode _searchFocusNode = FocusNode();
  List<SuggestionTb> _results = [];
  geo.Position? _futureLocation;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    geo.Geolocator.getServiceStatusStream().listen((geo.ServiceStatus status) {
      // Listen for location permission granting.
      _loadLocation();
    });
  }

  void _loadLocation() async {
    try {
      _futureLocation = await geo.Geolocator.getLastKnownPosition();
    } catch (e) {
      log('Failed to check or request location permission: $e');
      return null;
    }
  }

  void _search(String query) async {
    query = query.trim();
    if (query.isEmpty) {
      setState(() {
        _results.clear();
      });
      return;
    }
    geo.Position? currentLocation;

    if (_futureLocation != null) {
      currentLocation = _futureLocation;
    }

    SearchBoxAPI searchBoxAPI = SearchBoxAPI(
      limit: 10,
      types: [
        PlaceType.address,
        PlaceType.place,
        PlaceType.poi,
        PlaceType.neighborhood
      ],
    );

    if (currentLocation?.longitude != null &&
        currentLocation?.latitude != null) {
      ApiResponse<SuggestionResponseTb> result =
          await searchBoxAPI.getSuggestionsCustom(
        kMapboxAccessToken,
        query,
        proximity: currentLocation != null
            ? Proximity.LatLong(
                lat: currentLocation.latitude,
                long: currentLocation.longitude,
              )
            : Proximity.LocationIp(),
        origin: currentLocation != null
            ? Proximity.LatLong(
                lat: currentLocation.latitude,
                long: currentLocation.longitude,
              )
            : Proximity.LocationNone(),
      );

      result.fold((sr) async {
        final List<SuggestionTb> suggestions = sr.suggestions;
        suggestions.sort((a, b) {
          if (a.distance == null && b.distance == null) return 0;
          if (a.distance == null) return -1; // Null comes before non-null
          if (b.distance == null) return 1; // Null comes before non-null
          return a.distance!.compareTo(b.distance!);
        });

        setState(() {
          _results = suggestions;
        });
      }, (failure) {
        log("FAIL ${failure.error}");
      });
    }
  }

  void _onPlaceSelected(MapBoxPlace? place) {
    widget.onSelected(place);
    _searchFocusNode.unfocus();
    setState(() {
      _isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? null : kSearchBarHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: _isExpanded
          ? Column(
              children: [
                TextFormField(
                  initialValue: widget.selectedPlace?.placeName,
                  focusNode: _searchFocusNode,
                  onChanged: (value) async {
                    _search(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          _isExpanded = false;
                        });
                      },
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _onPlaceSelected(null);
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _results.length,
                          itemBuilder: (BuildContext context, int index) {
                            final result = _results[index];
                            return _buildSuggestionTile(
                              result,
                              // onTap: () => {} //_onPlaceSelected(result),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: () {
                setState(() {
                  _searchFocusNode.requestFocus();
                  _isExpanded = true;
                });
              },
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
    );
  }

  Widget _buildSuggestionTile(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: _iconForFeatureType(type),
              ),
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    type != SearchFeatureType.category
                        ? Text(
                            "${FormatHelper.toCapitalizedText(s.address ?? "")}, ${s.context?.place?.name}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          )
                        : const Text(
                            'Click to search',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue,
                            ),
                          ),
                  ],
                ),
              ),
              Flexible(
                  fit: FlexFit.loose,
                  child: Text(FormatHelper.formatDistance(s.distance,
                      noRemainder: true))),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  Widget _iconForFeatureType(SearchFeatureType type) {
    final IconData icon;
    switch (type) {
      case SearchFeatureType.category:
        icon = Icons.search;
        break;
      case SearchFeatureType.poi:
        icon = Icons.location_on_outlined;
        break;
      case SearchFeatureType.address:
        icon = Icons.location_city_rounded;
        break;
      default:
        icon = Icons.question_mark;
        break;
    }

    return Icon(icon);
  }
}

enum SearchFeatureType {
  category("category"),
  poi("poi"),
  address("address");

  final String value;

  const SearchFeatureType(this.value);
}

SearchFeatureType getFeatureTypeFromString(String value) {
  return SearchFeatureType.values.firstWhere(
    (mode) => mode.toString() == 'SearchFeatureType.$value',
    orElse: () => SearchFeatureType.address,
  );
}
