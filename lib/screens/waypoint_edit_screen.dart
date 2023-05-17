import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/extensions/mapbox_place_extensions.dart';
import 'package:trailblaze/widgets/place_picker_widget.dart';

class WaypointEditScreen extends StatefulWidget {
  final MapBoxPlace? startingLocation;
  final MapBoxPlace? endingLocation;
  final List<String> waypoints;

  const WaypointEditScreen(
      {super.key,
      required this.startingLocation,
      required this.endingLocation,
      required this.waypoints});

  @override
  State<WaypointEditScreen> createState() => _WaypointEditScreenState();
}

class _WaypointEditScreenState extends State<WaypointEditScreen> {
  late final List<dynamic> _locations = [];

  @override
  void initState() {
    super.initState();

    if (widget.startingLocation != null) {
      _locations.add(widget.startingLocation!);
    }

    if (widget.endingLocation != null) {
      _locations.add(widget.endingLocation!);
    }
  }

  void _onSave() {
    List<dynamic> waypointsJson = [];
    List validLocations = _locations.where((place) => place?.center != null).toList();

    if (validLocations.length < 2) {
      const snackBar = SnackBar(
        content: Text('Please select at least two valid locations.'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }


    for (MapBoxPlace? place in _locations) {
      waypointsJson.add(place?.toRawJsonWithNullCheck());
    }

    Navigator.pop(context, {
      'waypoints': waypointsJson,
      'startingLocation': _locations[0],
      'endingLocation': _locations[_locations.length - 1]
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Waypoints'),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Flexible(
                child: Scrollbar(
                  thumbVisibility: true,
                  child: ReorderableListView(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onReorder: (int oldIndex, int newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final location = _locations.removeAt(oldIndex);
                        _locations.insert(newIndex, location);
                      });
                    },
                    children: <Widget>[
                      for (int i = 0; i < _locations.length; i++)
                        Dismissible(
                          key: Key('$i'),
                          onDismissed: (DismissDirection _) {
                            setState(() {
                              _locations.removeAt(i);
                            });
                          },
                          child: ListTile(
                            key: Key('$i'),
                            title: PlacePicker(
                              selectedPlace: _locations[i],
                              onSelected: (MapBoxPlace? place) {
                                setState(() {
                                  _locations[i] = place;
                                });
                              },
                            ),
                            leading: const Icon(Icons.add_location_alt),
                            trailing: const Icon(Icons.drag_handle),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  setState(() {
                    _locations.insert(_locations.length - 1,
                        MapBoxPlace(placeName: 'Point of Interest'));
                  });
                },
                color: Colors.blueGrey,
                child: const Text(
                  'Add point of interest',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              MaterialButton(
                onPressed: _onSave,
                color: Colors.indigo,
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
