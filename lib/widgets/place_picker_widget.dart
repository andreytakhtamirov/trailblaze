import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:turf/turf.dart' as turf;

import '../constants/map_constants.dart';

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
  List<MapBoxPlace> _results = [];
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
    _futureLocation = await geo.Geolocator.getLastKnownPosition();
  }

  void _search(String query) async {
    query = query.trim();
    if (query.isEmpty) {
      setState(() {
        _results.clear();
      });
    }
    geo.Position? currentLocation;

    if (_futureLocation != null) {
      currentLocation = _futureLocation;
    }

    final geocoding = GeoCoding(
      apiKey: kMapboxAccessToken,
      types: [
        PlaceType.address,
        PlaceType.place,
        PlaceType.poi,
        PlaceType.neighborhood
      ],
      limit: 10,
    );

    List<MapBoxPlace>? result;
    if (currentLocation?.longitude != null &&
        currentLocation?.latitude != null) {
      result = await geocoding.getPlaces(
        query,
        proximity: Location(
          lat: currentLocation!.latitude,
          lng: currentLocation.longitude,
        ),
      );
    } else {
      result = await geocoding.getPlaces(
        query,
      );
    }
    setState(() {
      _results = result!;
    });
  }

  void _onPlaceSelected(MapBoxPlace? place) {
    widget.onSelected(place);
    _searchFocusNode.unfocus();
    setState(() {
      _isExpanded = false;
    });
  }

  String _calculateDistanceToUser(List<double>? point1) {
    if (_futureLocation == null) {
      return "test";
    }

    final point1Coord = mbm.Point(
      coordinates: mbm.Position(point1![0], point1[1]),
    );
    final point2Coord = mbm.Point(
      coordinates:
          mbm.Position(_futureLocation!.longitude, _futureLocation!.latitude),
    );

    final distance = turf.distance(point1Coord, point2Coord);
    return "${distance.toStringAsFixed(2)} km";
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? null : 50,
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
                  height: 400,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _results.length,
                          itemBuilder: (BuildContext context, int index) {
                            final result = _results[index];
                            return ListTile(
                              title: Text(result.placeName ?? ''),
                              subtitle: _futureLocation != null
                                  ? Text(
                                      _calculateDistanceToUser(result.center))
                                  : null,
                              onTap: () => _onPlaceSelected(result),
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
}
