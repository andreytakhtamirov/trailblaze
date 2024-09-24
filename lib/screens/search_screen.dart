import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/search_feature_type.dart';
import 'package:trailblaze/extensions/mapbox_search_extension.dart';
import 'package:trailblaze/managers/map_state_notifier.dart';
import 'package:trailblaze/managers/place_manager.dart';
import 'package:trailblaze/util/search_item_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/widgets/search/empty_search.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.selectedPlaceName});

  final String? selectedPlaceName;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  List<SuggestionTb> _results = [];
  geo.Position? _futureLocation;
  final TextEditingController _textEditController = TextEditingController();
  http.Client _httpClient = http.Client();
  final placeManager = PlaceManager();
  bool _isHistoryShowing = false;
  CoordinateBounds? mapViewBounds;

  SearchBoxAPI searchBoxAPI = SearchBoxAPI(
    limit: 10,
    types: [
      PlaceType.address,
      PlaceType.place,
      PlaceType.poi,
      PlaceType.neighborhood
    ],
  );

  @override
  void initState() {
    super.initState();
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
      mapViewBounds = cameraBounds;
    });
    log("BOUNDS northEast: ${cameraBounds?.northeast.coordinates.toList()}");
    log("BOUNDS southwest: ${cameraBounds?.southwest.coordinates.toList()}");
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
    final places = await placeManager.mostRecentPlaces(10);
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

    if (_futureLocation != null) {
      currentLocation = _futureLocation;
    }

    ApiResponse<SuggestionResponseTb> result =
        await searchBoxAPI.getSuggestionsCustom(
      kMapboxAccessToken,
      query,
      _httpClient,
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
      setState(() {
        _results = suggestions;
        _isHistoryShowing = false;
      });
    }, (failure) {
      if (failure.error != null) {
        log("Couldn't get suggestions: ${failure.error}");
      }
    });
  }

  void _hideAllFeatures() async {
    await placeManager.hideAllFeatures();
    _clearResults();
  }

  void _onSelectSuggestion(SuggestionTb s) async {
    if (s.featureType == SearchFeatureType.category.value) {
      // Fetch list of features for category.
      final places = await placeManager.resolveCategory(
        _futureLocation,
        _httpClient,
        s,
        mapViewBounds,
      );

      if (places == null) {
        if (mounted) {
          UiHelper.showSnackBar(
              context, "Couldn't retrieve category ${s.name}.");
        }
      } else if (mounted) {
        Navigator.of(context).pop(places);
      }
    } else {
      // Fetch info about particular place.
      final place = await placeManager.resolveFeature(s);
      if (place == null) {
        if (mounted) {
          UiHelper.showSnackBar(context, "Couldn't retrieve place.");
        }
      } else if (mounted) {
        Navigator.of(context).pop(place);
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
              child: _results.isEmpty
                  ? EmptySearch(isSearchEmpty: _isHistoryShowing)
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
}
