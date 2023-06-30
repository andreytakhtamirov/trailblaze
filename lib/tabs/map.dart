import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/create_route_constants.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/extensions/mapbox_place_extensions.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:trailblaze/screens/waypoint_edit_screen.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/widgets/picked_locations_widget.dart';
import 'package:trailblaze/widgets/place_info_widget.dart';
import 'package:trailblaze/widgets/route_info_widget.dart';
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
  String _selectedMode = kDefaultTransportationMode.value;
  bool _isRouteLoading = false;
  List<TrailblazeRoute> routesList = [];
  TrailblazeRoute? _selectedRoute;
  final List<mbm.PointAnnotationOptions> _pointAnnotations = [];

  @override
  void initState() {
    super.initState();
    geo.Geolocator.getServiceStatusStream().listen((geo.ServiceStatus status) {
      // Listen for location permission granting.
      _getCurrentPosition();
    });
  }

  final geocoding = GeoCoding(
    apiKey: kMapboxAccessToken,
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
    _mapboxMap.compass.updateSettings(kDefaultCompassSettings);
    _mapboxMap.scaleBar.updateSettings(defaultScaleBarSettings);
    _mapboxMap.attribution.updateSettings(defaultAttributionSettings);
  }

  Future<geo.Position?> _getCurrentPosition() async {
    geo.LocationPermission permission;
    try {
      permission = await geo.Geolocator.checkPermission();
      if (permission == geo.LocationPermission.denied) {
        permission = await geo.Geolocator.requestPermission();
      }
      if (permission == geo.LocationPermission.deniedForever) {
        if (context.mounted) {
          UiHelper.showSnackBar(
            context,
            'Location permissions are needed to show routes.',
          );
        }
        return null;
      }
    } catch (e) {
      log('Failed to check or request location permission: $e');
      return null;
    }

    geo.Position? position;
    try {
      position = await geo.Geolocator.getLastKnownPosition() ??
          await geo.Geolocator.getCurrentPosition();
    } catch (e) {
      log('Failed to fetch user location: $e');
      return null;
    }

    MapBoxPlace myLocation = MapBoxPlace(
        placeName: "My Location",
        center: [position.longitude, position.latitude]);
    _startingLocation = myLocation;

    return position;
  }

  Future<mbm.CameraOptions> _getCameraOptions() async {
    geo.Position? position = await _getCurrentPosition();

    Map<String?, Object?>? center;
    if (position != null && position.latitude != 0 && position.longitude != 0) {
      center = mbm.Point(
              coordinates: mbm.Position(position.longitude, position.latitude))
          .toJson();
    } else {
      center = kDefaultCameraState.center;
    }
    return mbm.CameraOptions(
        zoom: kDefaultCameraState.zoom,
        center: center,
        bearing: kDefaultCameraState.bearing,
        padding: kDefaultCameraState.padding,
        pitch: kDefaultCameraState.pitch);
  }

  void _onGpsButtonPressed() {
    _goToUserLocation();
  }

  void _displayRoute(String profile, List<dynamic> waypoints) async {
    _removeRouteLayers();

    setState(() {
      _isRouteLoading = true;
    });

    final dartz.Either<int, Map<String, dynamic>?> routeResponse;
    if (profile != TransportationMode.gravelCycling.value) {
      routeResponse = await createRoute(profile, waypoints);
    } else {
      routeResponse = await createPathsenseRoute(waypoints);
    }

    setState(() {
      _isRouteLoading = false;
    });

    routesList.clear();

    Map<String, dynamic>? routeData;

    routeResponse.fold(
      (error) => {
        if (error == 400)
          {
            UiHelper.showSnackBar(
                context, "Sorry, this region is not supported yet.")
          }
        else if (error == 404)
          {UiHelper.showSnackBar(context, "Failed to connect to the server.")}
        else
          {UiHelper.showSnackBar(context, "An unknown error occurred.")}
      },
      (data) => {routeData = data},
    );

    if (routeData == null || routeData?['routes'] == null) {
      return;
    }

    for (var i = routeData!['routes'].length - 1; i >= 0; i--) {
      final routeJson = routeData!['routes'][i];

      bool isFirstRoute = i == 0;

      TrailblazeRoute route = TrailblazeRoute(kRouteSourceId + i.toString(),
          kRouteLayerId + i.toString(), routeJson,
          isActive: isFirstRoute);

      await _mapboxMap.style.addSource(route.geoJsonSource);
      await _mapboxMap.style.addLayer(route.lineLayer);
      routesList.add(route);
    }

    _drawAllAnnotations();

    setState(() {
      // The first route is selected initially.
      _selectedRoute = routesList.last;
    });

    if (_selectedRoute != null) {
      _flyToRoute(_selectedRoute!);
    }
  }

  void _flyToRoute(TrailblazeRoute route) async {
    mbm.CameraOptions cameraOptions = await _mapboxMap.cameraForGeometry(
        route.geometryJson,
        kRouteCameraState.padding,
        kRouteCameraState.bearing,
        kRouteCameraState.pitch);
    _mapboxMap.flyTo(cameraOptions,
        mbm.MapAnimationOptions(duration: kMapFlyToDuration, startDelay: 0));
  }

  void _setSelectedRoute(TrailblazeRoute route) async {
    setState(() {
      _selectedRoute = route;
    });

    final allRoutes = [...routesList];
    allRoutes.remove(_selectedRoute);

    if (_selectedRoute != null) {
      // Update all other routes (unselected grey)
      for (var route in allRoutes) {
        await _updateRouteSelected(route, false);
      }

      // Update selected route (red)
      await _updateRouteSelected(_selectedRoute!, true);
      _flyToRoute(_selectedRoute!);
    }

    _drawAllAnnotations();
  }

  Future<void> _updateRouteSelected(
      TrailblazeRoute route, bool isSelected) async {
    // Make sure route is removed before we add it again.
    await _removeRouteLayer(route);
    route.setActive(isSelected);
    await _mapboxMap.style.addSource(route.geoJsonSource);
    await _mapboxMap.style.addLayer(route.lineLayer);
  }

  void _removeRouteLayers() async {
    for (var route in routesList) {
      _removeRouteLayer(route);
    }
  }

  Future<void> _removeRouteLayer(TrailblazeRoute route) async {
    if (await _mapboxMap.style.styleLayerExists(route.layerId)) {
      await _mapboxMap.style.removeStyleLayer(route.layerId);
    }

    if (await _mapboxMap.style.styleSourceExists(route.sourceId)) {
      await _mapboxMap.style.removeStyleSource(route.sourceId);
    }
  }

  TrailblazeRoute? _getRouteBySourceId(String sourceId) {
    for (var route in routesList) {
      if (route.sourceId == sourceId) {
        return route;
      }
    }
    return null;
  }

  void _goToUserLocation({bool isAnimated = true}) async {
    mbm.CameraOptions options = await _getCameraOptions();

    if (isAnimated) {
      _mapboxMap.flyTo(options,
          mbm.MapAnimationOptions(duration: kMapFlyToDuration, startDelay: 0));
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
              padding: kDefaultCameraState.padding,
              zoom: kDefaultCameraState.zoom,
              bearing: kDefaultCameraState.bearing,
              pitch: kDefaultCameraState.pitch),
          mbm.MapAnimationOptions(duration: kMapFlyToDuration, startDelay: 0));

      final ByteData bytes = await rootBundle.load('assets/location-pin.png');
      final Uint8List list = bytes.buffer.asUint8List();
      var options =
          mbm.PointAnnotationOptions(geometry: point.toJson(), image: list);
      _pointAnnotations.add(options);
      _showAnnotation(options);
    } else {
      _deleteAnnotations();
    }
  }

  void _drawAllAnnotations() async {
    _annotationManager.deleteAll();
    _annotationManager =
        await _mapboxMap.annotations.createPointAnnotationManager();

    for (var annotation in _pointAnnotations) {
      _showAnnotation(annotation);
    }
  }

  void _showAnnotation(mbm.PointAnnotationOptions options) {
    _annotationManager.create(options);
  }

  void _deleteAnnotations() async {
    _pointAnnotations.clear();
    _annotationManager.deleteAll();
  }

  void _onDirectionsClicked(MapBoxPlace place) {
    setState(() {
      _isDirectionsView = true;
    });

    if (_selectedMode == TransportationMode.none.value) {
      // Prompt user to select mode
      return;
    }

    _getDirectionsFromSettings();
  }

  void _getDirectionsFromSettings() {
    List<MapBoxPlace> waypoints = [];

    waypoints.insert(0, _startingLocation);
    waypoints.add(_selectedPlace!);

    List<dynamic> waypointsJson = [];

    for (MapBoxPlace place in waypoints) {
      waypointsJson.add(place.toRawJsonWithNullCheck());
    }

    _displayRoute(_selectedMode, waypointsJson);
  }

  Future<void> _onMapTapListener(mbm.ScreenCoordinate coordinate) async {
    if (_isDirectionsView) {
      mbm.ScreenCoordinate pixelCoordinates =
          await _mapboxMap.pixelForCoordinate({
        "coordinates": [coordinate.y, coordinate.x]
      });

      final mbm.RenderedQueryGeometry queryGeometry = mbm.RenderedQueryGeometry(
          value: json.encode(pixelCoordinates.encode()),
          type: mbm.Type.SCREEN_COORDINATE);

      List<String> routeLayers = [];
      for (var route in routesList) {
        routeLayers.add(route.layerId);
      }

      final mbm.RenderedQueryOptions queryOptions = mbm.RenderedQueryOptions(
        layerIds: routeLayers,
      );

      final List<mbm.QueriedFeature?> queriedFeatures =
          await _mapboxMap.queryRenderedFeatures(queryGeometry, queryOptions);

      if (queriedFeatures.isNotEmpty) {
        // A feature has been clicked.
        final selectedRoute =
            _getRouteBySourceId(queriedFeatures.first!.source);
        if (selectedRoute != null) {
          _setSelectedRoute(selectedRoute);
        }

        // We've handled the click event for a route
        //  so we can ignore all other things.
        return;
      }

      // Block other map clicks when showing route.
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
      _selectedRoute = null;
      _removeRouteLayers();
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

    _displayRoute(_selectedMode, waypoints);
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
                  accessToken: kMapboxAccessToken,
                ),
                cameraOptions: mbm.CameraOptions(
                    zoom: kDefaultCameraState.zoom,
                    center: kDefaultCameraState.center,
                    bearing: kDefaultCameraState.bearing,
                    padding: kDefaultCameraState.padding,
                    pitch: kDefaultCameraState.pitch),
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
                      firstChild: PlaceSearchBar(
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
              bottom: 16.0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
                  Visibility(
                    visible: _isDirectionsView && _selectedRoute != null,
                    child: RouteInfo(
                      route: _selectedRoute,
                    ),
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
