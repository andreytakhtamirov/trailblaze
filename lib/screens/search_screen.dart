import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/data/search_feature_type.dart';
import 'package:trailblaze/extensions/mapbox_search_extension.dart';
import 'package:trailblaze/managers/map_state_notifier.dart';
import 'package:trailblaze/managers/place_manager.dart';
import 'package:trailblaze/util/distance_helper.dart';
import 'package:trailblaze/util/search_item_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/widgets/search/empty_search.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({
    super.key,
    this.selectedPlaceName,
    this.isEditLocationsView = false,
  });

  final String? selectedPlaceName;
  final bool isEditLocationsView;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  List<SuggestionTb> _results = [];
  geo.Position? _futureLocation;
  final TextEditingController _textEditController = TextEditingController();
  http.Client _httpClient = http.Client();
  late final PlaceManager _placeManager;
  bool _isHistoryShowing = false;
  bool _isLoading = true;
  CoordinateBounds? _mapViewBounds;

  @override
  void initState() {
    super.initState();
    _placeManager = PlaceManager(ignoreCategory: widget.isEditLocationsView);
    _loadLocation();
    geo.Geolocator.getServiceStatusStream().listen((geo.ServiceStatus status) {
      // Listen for location permission granting.
      _loadLocation();
    });
    _searchFocusNode.requestFocus();
    _textEditController.text = widget.selectedPlaceName ?? '';
    _search(_textEditController.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _showBounds();
  }

  @override
  void dispose() {
    super.dispose();
    _httpClient.close();
  }

  void _showBounds() {
    final cameraBounds = ref.watch(mapStateProvider.notifier).getCameraBounds();
    if (!mounted) {
      return;
    }
    setState(() {
      _mapViewBounds = cameraBounds;
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

  void _clearResults() {
    setState(() {
      _results.clear();
    });
  }

  void _showHistory() async {
    final places = await _placeManager.mostRecentPlaces(10);
    final List<SuggestionTb> results = [];

    for (MapBoxPlace p in places) {
      results.add(SuggestionTb(
        mapboxId: p.id!,
        name: p.placeName!,
        placeFormatted: p.text!,
        featureType: SearchFeatureType.history.value,
      ));
    }

    setState(() {
      _results = results;
      _isHistoryShowing = true;

      if (_isLoading) {
        _isLoading = false;
      }
    });
  }

  void _search(String query) async {
    _httpClient = http.Client();
    query = query.trim();
    if (query.isEmpty) {
      _showHistory();
      return;
    }
    geo.Position? currentLocation;

    // If query doesn't contain comma (only separated with space, replace the space with a comma).
    final queryWithComma =
        !query.contains(',') ? query.replaceFirst(' ', ',') : query;
    final coordinatePattern = RegExp(r'^-?\d+(\.\d+)?,\s?-?\d+(\.\d+)?$');
    if (coordinatePattern.hasMatch(queryWithComma)) {
      final coordinates = queryWithComma.split(',');
      final lat = double.tryParse(coordinates[0].trim());
      final lng = double.tryParse(coordinates[1].trim());

      if (lat != null &&
          lng != null &&
          DistanceHelper.isValidCoordinate(lat, lng)) {
        setState(() {
          final suggestion = SuggestionTb(
            name: "$lat, $lng",
            mapboxId: "$lat,$lng",
            featureType: SearchFeatureType.coordinates.value,
            placeFormatted: "Search for coordinates (lat, lon)",
          );
          _results = [suggestion];
          _isHistoryShowing = false;
        });
        return;
      } else {
        setState(() {
          _clearResults();
        });
      }
    }

    if (_futureLocation != null) {
      currentLocation = _futureLocation;
    }

    final List<SuggestionTb>? suggestions =
        await _placeManager.resolveSearch(query, _httpClient, currentLocation);
    if (suggestions != null) {
      setState(() {
        _results = suggestions;
        _isHistoryShowing = false;
      });
    }
  }

  void _hideAllFeatures() async {
    await _placeManager.hideAllFeatures();
    _clearResults();
  }

  void _onSelectSuggestion(SuggestionTb s) async {
    if (s.featureType == SearchFeatureType.category.value) {
      // Fetch list of features for category.
      final features = await _placeManager.resolveCategory(
        _httpClient,
        s.poiCategoryIds?.firstOrNull,
        _mapViewBounds,
      );

      if (features == null) {
        if (mounted) {
          UiHelper.showSnackBar(
              context, "Couldn't retrieve category ${s.name}.");
        }
      } else if (mounted) {
        Navigator.of(context).pop({
          'categoryId': s.poiCategoryIds?.first,
          'features': features,
        });
      }
    } else if (s.featureType == SearchFeatureType.coordinates.value) {
      final place = _placeManager.placeFromCoordinates(s);
      Navigator.of(context).pop(place);
    } else if (s.featureType != SearchFeatureType.userLocation.value) {
      // Fetch info about particular place.
      final place = await _placeManager.resolveFeature(s);
      if (place == null) {
        if (mounted) {
          UiHelper.showSnackBar(context, "Couldn't retrieve place.");
        }
      } else if (mounted) {
        Navigator.of(context).pop(place);
      }
    } else {
      geo.Position? currentLocation;
      if (_futureLocation != null) {
        currentLocation = _futureLocation;
        Navigator.of(context).pop(MapBoxPlace(
            placeName: "My Location",
            center: (
              long: currentLocation!.longitude,
              lat: currentLocation.latitude
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Hero(
              tag: 'Search',
              child: TextFormField(
                controller: _textEditController,
                focusNode: _searchFocusNode,
                onChanged: (value) async {
                  _httpClient.close();
                  _search(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _textEditController.clear();
                        _showHistory();
                      });
                    },
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: _inputBorder(),
                  focusedBorder: _inputBorder(),
                  enabledBorder: _inputBorder(),
                ),
              ),
            ),
            if (widget.isEditLocationsView && _futureLocation != null)
              _buildMyLocationTile(),
            _isHistoryShowing && _results.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: 16,
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: _hideAllFeatures,
                          child: Text(
                            'Clear All',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            Expanded(
              child: !_isLoading && _results.isEmpty
                  ? EmptySearch(isSearchEmpty: _textEditController.text.isEmpty)
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _results.length,
                      itemBuilder: (BuildContext context, int index) {
                        final suggestion = _results[index];
                        return InkWell(
                          onTap: () {
                            _onSelectSuggestion(suggestion);
                          },
                          child: _buildSuggestionTile(
                            suggestion,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      )),
    );
  }

  OutlineInputBorder _inputBorder() {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(24)),
      borderSide: BorderSide(color: Colors.grey.shade400),
    );
  }

  Widget _buildSuggestionTile(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 16),
              Flexible(
                fit: FlexFit.loose,
                child: SearchItemHelper.iconForFeatureType(type),
              ),
              const SizedBox(width: 24),
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchItemHelper.titleForFeatureType(s),
                    SearchItemHelper.subtitleForFeatureType(s),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                fit: FlexFit.loose,
                child:
                    SearchItemHelper.suffixForFeatureType(_futureLocation, s),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  Widget _buildMyLocationTile() {
    return InkWell(
      onTap: () {
        _onSelectSuggestion(
          SuggestionTb(
            name: 'My Location',
            mapboxId: '',
            featureType: SearchFeatureType.userLocation.value,
            placeFormatted: '',
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.navigation_rounded,
                  color: Colors.blue.shade900,
                ),
                const SizedBox(width: 20),
                Text(
                  'My Location',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade300),
        ],
      ),
    );
  }
}
