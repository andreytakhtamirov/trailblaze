import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trailblaze/constants/create_route_constants.dart';
import 'package:trailblaze/extensions/mapbox_place_extensions.dart';

import '../constants/map_constants.dart';
import '../widgets/transportation_mode_widget.dart';

class CreateRouteScreen extends StatefulWidget {
  const CreateRouteScreen({super.key});

  @override
  State<CreateRouteScreen> createState() => _CreateRouteScreenState();
}

class _CreateRouteScreenState extends State<CreateRouteScreen> {
  final _startingLocationController = TextEditingController();
  final _waypointLocationController = TextEditingController();
  List<MapBoxPlace> _results = [];
  final Future<Position?> _futureLocation = Geolocator.getLastKnownPosition();

  final List<MapBoxPlace> _waypoints = [];
  MapBoxPlace _startingLocation = MapBoxPlace();
  final _focusNodeStartingLocation = FocusNode();
  final _focusNodeWaypoint = FocusNode();

  TransportationMode _selectedMode = defaultTransportationMode;

  @override
  void dispose() {
    _startingLocationController.dispose();
    _focusNodeStartingLocation.dispose();
    super.dispose();
  }

  void _clearFocus() {
    _focusNodeStartingLocation.unfocus();
  }

  void _onTextChanged(value) async {
    value = value.trim();
    if (value.isNotEmpty && value != "") {
      Position? currentLocation = await _futureLocation;

      final geocoding = GeoCoding(
        apiKey: mapboxAccessToken,
        types: [
          PlaceType.address,
          PlaceType.place,
          PlaceType.poi,
          PlaceType.neighborhood
        ],
        limit: geocodeResultsLimit,
      );

      List<MapBoxPlace>? result;
      if (currentLocation?.longitude != null &&
          currentLocation?.latitude != null) {
        result = await geocoding.getPlaces(
          value,
          proximity: Location(
            lat: currentLocation!.latitude,
            lng: currentLocation.longitude,
          ),
        );
      } else {
        result = await geocoding.getPlaces(
          value,
        );
      }
      setState(() {
        _results = result!;
      });
    } else {
      setState(() {
        _results.clear();
      });
    }
  }

  void _onSelectPlace(place) {
    if (_focusNodeStartingLocation.hasFocus) {
      setState(() {
        _startingLocation = place;
        _startingLocationController.text = "";
        _results.clear();
      });
    } else if (_focusNodeWaypoint.hasFocus) {
      setState(() {
        _waypoints.add(place);
        _waypointLocationController.text = "";
        _results.clear();
      });
    }
    _clearFocus();
  }

  void _onModeChanged(TransportationMode mode) {
    setState(() {
      _selectedMode = mode;
    });
  }

  void _onResetPressed() {
    _clearFocus();
    setState(() {
      _startingLocation = MapBoxPlace();
      _waypoints.clear();
      _waypointLocationController.text = "";
      _startingLocationController.text = "";
      _results.clear();
    });
  }

  void _onSubmitPressed() {
    _waypoints.insert(0, _startingLocation);

    String profile = _selectedMode.value;

    List<dynamic> waypointsJson = [];

    for (MapBoxPlace place in _waypoints) {
      waypointsJson.add(place.toRawJsonWithNullCheck());
    }

    Navigator.pop(context, {'profile': profile, 'waypoints': waypointsJson});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height - kToolbarHeight * 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      focusNode: _focusNodeStartingLocation,
                      controller: _startingLocationController,
                      decoration: const InputDecoration(
                        hintText: 'Search for a starting location',
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: _onTextChanged,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            _startingLocation.placeName ?? '',
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: TransportationModeWidget(
                            initialMode: _selectedMode,
                            onSelected: _onModeChanged,
                          ),
                        ),
                      )),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      focusNode: _focusNodeWaypoint,
                      controller: _waypointLocationController,
                      decoration: const InputDecoration(
                        hintText: 'Add a waypoint',
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: _onTextChanged,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: _waypoints.length,
                              itemBuilder: (BuildContext context, int index) {
                                MapBoxPlace place = _waypoints[index];
                                return Column(
                                  children: [
                                    Text(
                                      place.placeName ?? '',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => _onResetPressed(),
                                child: const Text('Reset'),
                              ),
                              ElevatedButton(
                                onPressed: () => _onSubmitPressed(),
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: kToolbarHeight,
              left: 0,
              right: 0,
              bottom: 0,
              child: Visibility(
                visible: _results.isNotEmpty,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final place = _results[index];
                      return ListTile(
                        title: Text(place.placeName ?? ''),
                        onTap: () => _onSelectPlace(place),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
