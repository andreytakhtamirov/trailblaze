import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/search_feature_type.dart';
import 'package:trailblaze/extensions/mapbox_search_extension.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/data/feature.dart' as tb;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.selectedPlaceName});

  final String? selectedPlaceName;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FocusNode _searchFocusNode = FocusNode();
  List<SuggestionTb> _results = [];
  geo.Position? _futureLocation;
  final TextEditingController _textEditController = TextEditingController();
  http.Client _httpClient = http.Client();
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
  void dispose() {
    super.dispose();
    _httpClient.close();
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

  void _search(String query) async {
    _httpClient = http.Client();
    query = query.trim();
    if (query.isEmpty) {
      _clearResults();
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
      });
    }, (failure) {
      if (failure.error != null) {
        log("Couldn't get suggestions: ${failure.error}");
      }
    });
  }

  void _onPlaceSelected(SuggestionTb s) async {
    log(s.poiCategoryIds!.first);
    if (s.featureType == SearchFeatureType.category.value) {
      // Fetch list of features

      geo.Position? currentLocation;

      if (_futureLocation != null) {
        currentLocation = _futureLocation;
      }

      ApiResponse<mbm.FeatureCollection> result =
          await searchBoxAPI.getCategory(
        kMapboxAccessToken,
        s.poiCategoryIds?.first ?? "",
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

      result.fold((response) async {
        List<mbm.Feature<mbm.GeometryObject>> features = response.features;

        List<tb.Feature> places = [];
        for (mbm.Feature<mbm.GeometryObject> f in features) {
          log("FEATURE: ${f.toJson().toString()}");

          if (f.geometry == null) {
            return;
          }
          final name = f.properties?['name'];
          final point = mbm.Point.fromJson(f.geometry!.toJson());

          final fe = tb.Feature.fromPlace(MapBoxPlace(
            placeName: name,
            center: (
            lat: point.coordinates.lat.toDouble(),
            long: point.coordinates.lng.toDouble()
            ),
          ));
          places.add(
            fe
          );

          log("name: ${fe.center}");
          log("point: ${point.coordinates.lat.toDouble()}");
        }
        Navigator.of(context).pop(places);
      }, (failure) {
        if (mounted) {
          UiHelper.showSnackBar(
              context, "Couldn't retrieve category: ${failure.error}");
        }
      });
    } else {
      // Fetch full place info
      ApiResponse<RetrieveResonse> result =
          await searchBoxAPI.getPlace(s.mapboxId);

      result.fold((response) async {
        Feature? f = response.features.firstOrNull;
        Navigator.of(context).pop(MapBoxPlace(
          placeName: _suggestionFullName(s),
          center: f?.geometry.coordinates,
        ));
      }, (failure) {
        if (mounted) {
          UiHelper.showSnackBar(
              context, "Couldn't retrieve place: ${failure.error}");
        }
      });
    }
  }

  String _suggestionFullName(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    final String fullName;

    switch (type) {
      case SearchFeatureType.place:
      case SearchFeatureType.address:
      case SearchFeatureType.neighborhood:
        fullName = '${s.name}, ${s.placeFormatted}';
        break;
      case SearchFeatureType.poi:
      default:
        fullName = "${s.address}, ${s.placeFormatted}";
    }

    return fullName;
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
              tag: "Search",
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
                        _clearResults();
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
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: _results.length,
                itemBuilder: (BuildContext context, int index) {
                  final result = _results[index];
                  return InkWell(
                    onTap: () {
                      _onPlaceSelected(result);
                    },
                    child: _buildSuggestionTile(
                      result,
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: _iconForFeatureType(type),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 5,
                fit: FlexFit.tight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _titleForFeatureType(s),
                    _subtitleForFeatureType(s),
                  ],
                ),
              ),
              Flexible(
                fit: FlexFit.loose,
                child: _suffixForFeatureType(s),
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey.shade300),
      ],
    );
  }

  Widget _iconForFeatureType(SearchFeatureType type) {
    switch (type) {
      case SearchFeatureType.category:
        return Icon(
          Icons.search,
          color: Colors.blue.shade900,
        );
      case SearchFeatureType.poi:
        return const Icon(
          Icons.location_on_outlined,
        );
      case SearchFeatureType.address:
        return const Icon(
          Icons.home,
        );
      case SearchFeatureType.place:
        return const Icon(
          Icons.location_city_rounded,
        );
      case SearchFeatureType.neighborhood:
        return const Icon(
          Icons.home_work_outlined,
        );
      default:
        return const Icon(
          Icons.question_mark,
        );
    }
  }

  Widget _titleForFeatureType(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    switch (type) {
      case SearchFeatureType.category:
        return Text(
          s.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade900,
          ),
        );
      case SearchFeatureType.place:
      case SearchFeatureType.neighborhood:
      case SearchFeatureType.poi:
      case SearchFeatureType.address:
      default:
        return Text(
          s.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
          ),
        );
    }
  }

  Widget _subtitleForFeatureType(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    final String label;
    switch (type) {
      case SearchFeatureType.category:
        return Text(
          'Click to see nearby',
          style: TextStyle(
            color: Colors.blue.shade800,
            decoration: TextDecoration.underline,
            decorationColor: Colors.blue.shade800,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case SearchFeatureType.place:
      case SearchFeatureType.address:
      case SearchFeatureType.neighborhood:
        label = s.placeFormatted;
        break;
      case SearchFeatureType.poi:
      default:
        label = "${s.address}, ${s.placeFormatted}";
    }

    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
      ),
    );
  }

  Widget _suffixForFeatureType(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    final Widget distance;
    if (_futureLocation != null) {
      distance = Text(
        FormatHelper.formatDistance(
          s.distance,
          noRemainder: true,
        ),
      );
    } else {
      distance = const SizedBox();
    }

    switch (type) {
      case SearchFeatureType.category:
        return Icon(
          Icons.open_in_new,
          color: Colors.blue.shade800,
        );
      default:
        return distance;
    }
  }
}
