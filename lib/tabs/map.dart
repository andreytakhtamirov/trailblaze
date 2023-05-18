import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/create_route_constants.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/extensions/mapbox_place_extensions.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:polyline_do/polyline_do.dart';
import 'package:trailblaze/screens/waypoint_edit_screen.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/widgets/picked_locations_widget.dart';
import 'package:trailblaze/widgets/place_info_widget.dart';
import 'package:trailblaze/widgets/search_bar_widget.dart';

import '../data/transportation_mode.dart';
import '../requests/create_route.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, location});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  late mbm.MapboxMap _mapboxMap;
  late mbm.PointAnnotationManager _annotationManager;
  MapBoxPlace? _selectedPlace;
  bool _isDirectionsView = false;
  MapBoxPlace _startingLocation = MapBoxPlace(placeName: "My Location");
  String _selectedMode = defaultTransportationMode.value;
  bool _isRouteLoading = false;

  @override
  void initState() {
    super.initState();
    geo.Geolocator.getServiceStatusStream().listen((geo.ServiceStatus status) {
      // Listen for location permission granting.
      _getCurrentPosition();
    });
  }

  final geocoding = GeoCoding(
    apiKey: mapboxAccessToken,
    types: [PlaceType.address],
    limit: 1,
  );

  _onMapCreated(mbm.MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _annotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _goToUserLocation(isAnimated: false);
    _showUserLocationPuck();
    _setMapControlSettings();
  }

  void _setMapControlSettings() {
    _mapboxMap.compass.updateSettings(defaultCompassSettings);
    _mapboxMap.scaleBar.updateSettings(defaultScaleBarSettings);
    _mapboxMap.attribution.updateSettings(defaultAttributionSettings);
  }

  Future<geo.Position?> _getCurrentPosition() async {
    geo.LocationPermission permission;
    permission = await geo.Geolocator.checkPermission();
    permission = await geo.Geolocator.requestPermission();
    if (permission == geo.LocationPermission.denied) {
      if (context.mounted) {
        UiHelper.showSnackBar(
            context, 'Location permissions are needed to show routes.');
      }
    }
    geo.Position? position = await geo.Geolocator.getLastKnownPosition() ??
        await geo.Geolocator.getCurrentPosition();

    if (position != null) {
      MapBoxPlace myLocation = MapBoxPlace(
          placeName: "My Location",
          center: [position.longitude, position.latitude]);
      _startingLocation = myLocation;
    }

    return position;
  }

  Future<mbm.CameraOptions> _getCameraOptions() async {
    geo.Position? position = await _getCurrentPosition();

    Map<String?, Object?>? center;
    if (position?.latitude != 0 && position?.longitude != 0) {
      center = mbm.Point(
              coordinates: mbm.Position(position!.longitude, position.latitude))
          .toJson();
    } else {
      center = defaultCameraState.center;
    }
    return mbm.CameraOptions(
        zoom: defaultCameraState.zoom,
        center: center,
        bearing: defaultCameraState.bearing,
        padding: defaultCameraState.padding,
        pitch: defaultCameraState.pitch);
  }

  void _onGpsButtonPressed() {
    _goToUserLocation();
  }

  void displayRoute(String profile, List<dynamic> waypoints) async {
    _removeRouteLayer();

    setState(() {
      _isRouteLoading = true;
    });

    final route = await createRoute(profile, waypoints);

    setState(() {
      _isRouteLoading = false;
    });

    if (route != null && route['routes'] != null) {
      final geometry = route['routes'][0]['geometry'];

      List<List<dynamic>> coordinates =
          Polyline.Decode(encodedString: geometry, precision: polylinePrecision)
              .decodedCoords
              .map((c) => [c[1], c[0]])
              .toList();

      final geometryJson = {"type": "LineString", "coordinates": coordinates};

      final fills = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "id": 0,
            "properties": <String, dynamic>{},
            "geometry": geometryJson,
          },
        ]
      };

      await _mapboxMap.style.addSource(
          mbm.GeoJsonSource(id: routeSourceId, data: json.encode(fills)));

      await _mapboxMap.style.addLayer(mbm.LineLayer(
          id: routeLayerId,
          sourceId: routeSourceId,
          lineJoin: mbm.LineJoin.ROUND,
          lineCap: mbm.LineCap.ROUND,
          lineColor: Colors.red.value,
          lineWidth: routeLineWidth));

      mbm.CameraOptions cameraOptions = await _mapboxMap.cameraForGeometry(
          geometryJson,
          routeCameraState.padding,
          routeCameraState.bearing,
          routeCameraState.pitch);
      _mapboxMap.flyTo(
          cameraOptions, mbm.MapAnimationOptions(duration: 100, startDelay: 0));
    }
  }

  void _removeRouteLayer() async {
    if (await _mapboxMap.style.styleLayerExists(routeLayerId)) {
      await _mapboxMap.style.removeStyleLayer(routeLayerId);
    }

    if (await _mapboxMap.style.styleSourceExists(routeSourceId)) {
      await _mapboxMap.style.removeStyleSource(routeSourceId);
    }
  }

  void _goToUserLocation({bool isAnimated = true}) async {
    mbm.CameraOptions options = await _getCameraOptions();

    if (isAnimated) {
      _mapboxMap.flyTo(
          options, mbm.MapAnimationOptions(duration: 100, startDelay: 0));
    } else {
      _mapboxMap.setCamera(options);
    }
  }

  void _showUserLocationPuck() async {
    final ByteData bytes = await rootBundle.load('assets/location-puck.png');
    final Uint8List list = bytes.buffer.asUint8List();

    _mapboxMap.location.updateSettings(mbm.LocationComponentSettings(
        locationPuck: mbm.LocationPuck(
            locationPuck2D: mbm.LocationPuck2D(topImage: list)),
        enabled: true));
  }

  void _onSelectPlace(MapBoxPlace? place,
      {bool isPlaceDataUpdate = false}) async {
    setState(() {
      _selectedPlace = place;
    });

    if (isPlaceDataUpdate) {
      // We don't need to redraw the annotation since
      // the only thing that changes is the place name.
      return;
    }

    if (place != null) {
      mbm.Point point = mbm.Point(
          coordinates: mbm.Position.fromJson(place.center?.cast<num>() ?? []));
      _mapboxMap.flyTo(
          mbm.CameraOptions(
              center: point.toJson(),
              padding: defaultCameraState.padding,
              zoom: defaultCameraState.zoom,
              bearing: defaultCameraState.bearing,
              pitch: defaultCameraState.pitch),
          mbm.MapAnimationOptions(duration: 100, startDelay: 0));

      final ByteData bytes = await rootBundle.load('assets/location-pin.png');
      final Uint8List list = bytes.buffer.asUint8List();
      var options =
          mbm.PointAnnotationOptions(geometry: point.toJson(), image: list);
      _showAnnotation(options);
    } else {
      _deleteAnnotations();
    }
  }

  void _showAnnotation(mbm.PointAnnotationOptions options) {
    _annotationManager.create(options);
  }

  void _deleteAnnotations() async {
    _annotationManager.deleteAll();
  }

  void _onDirectionsClicked(MapBoxPlace place) {
    setState(() {
      _isDirectionsView = !_isDirectionsView;
    });

    if (_isDirectionsView) {
      _getDirectionsFromSettings();
    }
  }

  void _getDirectionsFromSettings() {
    List<MapBoxPlace> waypoints = [];

    waypoints.insert(0, _startingLocation);
    waypoints.add(_selectedPlace!);

    List<dynamic> waypointsJson = [];

    for (MapBoxPlace place in waypoints) {
      waypointsJson.add(place.toRawJsonWithNullCheck());
    }

    displayRoute(_selectedMode, waypointsJson);
  }

  Future<void> _onMapTapListener(mbm.ScreenCoordinate coordinate) async {
    if (_isDirectionsView) {
      return;
    }

    if (_selectedPlace != null) {
      _onSelectPlace(null);
    }

    MapBoxPlace place = MapBoxPlace(center: [coordinate.y, coordinate.x]);

    _onSelectPlace(place);

    Future<List<MapBoxPlace>?> futurePlaces =
        geocoding.getAddress(Location(lat: coordinate.x, lng: coordinate.y));

    futurePlaces.then((places) {
      String placeName;
      if (places != null && places.isNotEmpty && places[0].placeName != null) {
        placeName = places[0].placeName!;
      } else {
        placeName =
            "(${coordinate.y.toStringAsFixed(4)}, ${coordinate.x.toStringAsFixed(4)})";
      }

      MapBoxPlace updatedPlace = MapBoxPlace(
          placeName: placeName, center: [coordinate.y, coordinate.x]);
      _onSelectPlace(updatedPlace, isPlaceDataUpdate: true);
    });
  }

  void _onDirectionsBackClicked() {
    setState(() {
      _isDirectionsView = false;
      _removeRouteLayer();
    });
  }

  void _onTransportationModeChanged(TransportationMode mode) {
    setState(() {
      _selectedMode = mode.value;
    });

    _getDirectionsFromSettings();
  }

  Future<void> _showEditDirectionsScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaypointEditScreen(
          startingLocation: _startingLocation,
          endingLocation: _selectedPlace,
          waypoints: [],
        ),
      ),
    );

    if (result == null) {
      return;
    }

    final List<dynamic> waypoints = result['waypoints'];
    final MapBoxPlace startingLocation = result['startingLocation'];
    final MapBoxPlace endingLocation = result['endingLocation'];

    setState(() {
      _startingLocation = startingLocation;
    });
    _deleteAnnotations();

    _onSelectPlace(endingLocation);

    displayRoute(_selectedMode, waypoints);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (TapDownDetails _) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            Scaffold(
              body: mbm.MapWidget(
                onTapListener: _onMapTapListener,
                resourceOptions: mbm.ResourceOptions(
                  accessToken: mapboxAccessToken,
                ),
                cameraOptions: mbm.CameraOptions(
                    zoom: defaultCameraState.zoom,
                    center: defaultCameraState.center,
                    bearing: defaultCameraState.bearing,
                    padding: defaultCameraState.padding,
                    pitch: defaultCameraState.pitch),
                onMapCreated: _onMapCreated,
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _isDirectionsView
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: SearchBar(
                          onSelected: _onSelectPlace,
                          selectedPlace: _selectedPlace),
                      secondChild: InkWell(
                        onTap: _showEditDirectionsScreen,
                        child: PickedLocationsWidget(
                          onBackClicked: _onDirectionsBackClicked,
                          onModeChanged: _onTransportationModeChanged,
                          startingLocation: _startingLocation,
                          endingLocation: _selectedPlace,
                          waypoints: [],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 32.0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FloatingActionButton(
                          heroTag: 'showMyLocationFab',
                          backgroundColor: Colors.orange,
                          onPressed: _onGpsButtonPressed,
                          child: const Icon(
                            Icons.gps_fixed,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: !_isDirectionsView && _selectedPlace != null,
                    child: PlaceInfo(
                        selectedPlace: _selectedPlace,
                        onDirectionsClicked: _onDirectionsClicked),
                  ),
                ],
              ),
            ),
            if (_isRouteLoading)
              Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (context) => Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.white60,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
