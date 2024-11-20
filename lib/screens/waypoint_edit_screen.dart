import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart' as mbs;
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/widgets/map/place_picker_widget.dart';

class WaypointEditScreen extends StatefulWidget {
  final mbs.MapBoxPlace? startingLocation;
  final mbs.MapBoxPlace? endingLocation;
  final List<String> waypoints;
  final void Function() onSearchBarTap;

  const WaypointEditScreen({
    super.key,
    required this.startingLocation,
    required this.endingLocation,
    required this.waypoints,
    required this.onSearchBarTap,
  });

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
    List validLocations =
        _locations.where((place) => place?.center != null).toList();

    if (validLocations.length < 2) {
      UiHelper.showSnackBar(
          context, 'Please select at least two valid locations.');
      return;
    }

    for (mbs.MapBoxPlace? place in _locations) {
      waypointsJson.add(place?.toJson());
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
                              heroTag: i.toString(),
                              onSearchBarTap: widget.onSearchBarTap,
                              selectedPlace: _locations[i],
                              isEditLocationsView: true,
                              onSelected: (mbs.MapBoxPlace? place) {
                                setState(() {
                                  _locations[i] = place;
                                });
                              },
                              // Won't show category search item in waypoint edit screen
                              onSelectFeatures: (features, category) {},
                            ),
                            leading: const Icon(Icons.location_city_rounded),
                            trailing: const Icon(Icons.drag_handle),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Opacity(
                opacity: _locations.length < 2 ? 1.0 : 0.5,
                child: MaterialButton(
                  shape: const StadiumBorder(),
                  onPressed: () {
                    if (_locations.length > 1) {
                      UiHelper.showSnackBar(
                        context,
                        'Currently limited to start/end',
                        margin: const EdgeInsets.only(
                          bottom: 100,
                          right: 40,
                          left: 40,
                        ),
                      );
                      return;
                    }
                    setState(() {
                      _locations.insert(_locations.length,
                          mbs.MapBoxPlace(placeName: 'Point of Interest'));
                    });
                  },
                  color: const Color(0xFFBDD2DD),
                  child: const Text(
                    'Add point of interest',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              MaterialButton(
                shape: const StadiumBorder(),
                onPressed: _onSave,
                color: Theme.of(context).colorScheme.primary,
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
