import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/screens/create_route_screen.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:polyline_do/polyline_do.dart';

import '../requests/create_route.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, location});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage>
    with AutomaticKeepAliveClientMixin<MapPage> {
  late MapboxMap _mapboxMap;
  late CameraState _state;
  bool _hasUserMovedCamera = false;

  @override
  void initState() {
    super.initState();
    _state = defaultCameraState;
  }

  _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _goToUserLocation();
    _showUserLocationPuck();
  }

  void _onCameraChangedListener(CameraChangedEventData eventData) async {
    _hasUserMovedCamera = true;
    _state = (await _mapboxMap.getCameraState());
  }

  Future<CameraOptions> _getDefaultCameraOptions() async {
    if (!_hasUserMovedCamera) {
      // get the current location
      geo.Position? position = await geo.Geolocator.getLastKnownPosition() ??
          await geo.Geolocator.getCurrentPosition();

      Map<String?, Object?>? center;
      if (position.latitude != 0 && position.longitude != 0) {
        center =
            Point(coordinates: Position(position.longitude, position.latitude))
                .toJson();
      } else {
        center = defaultCameraState.center;
      }
      return CameraOptions(
          zoom: defaultCameraState.zoom,
          center: center,
          bearing: defaultCameraState.bearing,
          padding: defaultCameraState.padding,
          pitch: defaultCameraState.pitch);
    } else {
      return CameraOptions(
          zoom: _state.zoom,
          center: _state.center,
          bearing: _state.bearing,
          padding: _state.padding,
          pitch: _state.pitch);
    }
  }

  void _onGpsButtonPressed() {
    _hasUserMovedCamera = false;
    _flyToUserLocation();
  }

  Future<void> _onCreateRouteButtonPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRouteScreen()),
    );

    _removeRouteLayer();

    final profile = result['profile'];
    final List<dynamic> waypoints = result['waypoints'];

    log('Profile: $profile');
    log('Waypoints: $waypoints');

    final route = await createRoute(profile, waypoints);
    if (route != null && route['routes'] != null) {
      final geometry = route['routes'][0]['geometry'];

      List<List<dynamic>> coordinates =
          Polyline.Decode(encodedString: geometry, precision: polylinePrecision)
              .decodedCoords
              .map((c) => [c[1], c[0]])
              .toList();

      final fills = {
        "type": "FeatureCollection",
        "features": [
          {
            "type": "Feature",
            "id": 0,
            "properties": <String, dynamic>{},
            "geometry": {"type": "LineString", "coordinates": coordinates},
          },
        ]
      };

      // Add new source and lineLayer
      await _mapboxMap.style.addSource(
          GeoJsonSource(id: routeSourceId, data: json.encode(fills)));

      await _mapboxMap.style.addLayer(LineLayer(
          id: routeLayerId,
          sourceId: routeSourceId,
          lineJoin: LineJoin.ROUND,
          lineCap: LineCap.ROUND,
          lineColor: Colors.red.value,
          lineWidth: routeLineWidth));
    }
  }

  void _removeRouteLayer() async {
    if (await _mapboxMap.style.getLayer(routeLayerId) != null) {
      await _mapboxMap.style.removeStyleLayer(routeLayerId);
    }

    if (await _mapboxMap.style.getSource(routeSourceId) != null) {
      await _mapboxMap.style.removeStyleSource(routeSourceId);
    }
  }

  void _flyToUserLocation() async {
    _mapboxMap.flyTo(await _getDefaultCameraOptions(),
        MapAnimationOptions(duration: 100, startDelay: 0));
  }

  void _goToUserLocation() async {
    _mapboxMap.setCamera(await _getDefaultCameraOptions());
  }

  void _showUserLocationPuck() async {
    final ByteData bytes = await rootBundle.load('assets/location-puck.png');
    final Uint8List list = bytes.buffer.asUint8List();

    _mapboxMap.location.updateSettings(LocationComponentSettings(
        locationPuck:
            LocationPuck(locationPuck2D: LocationPuck2D(topImage: list)),
        enabled: true));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: MapWidget(
        resourceOptions: ResourceOptions(
          accessToken: mapboxAccessToken,
        ),
        onCameraChangeListener: _onCameraChangedListener,
        cameraOptions: CameraOptions(
            zoom: _state.zoom,
            center: _state.center,
            bearing: _state.bearing,
            padding: _state.padding,
            pitch: _state.pitch),
        onMapCreated: _onMapCreated,
      ),
      floatingActionButton: Stack(
        children: <Widget>[
          Positioned(
            bottom: 16.0,
            left: 30.0,
            child: FloatingActionButton(
              heroTag: 'createRouteFab',
              backgroundColor: Colors.orange,
              onPressed: _onCreateRouteButtonPressed,
              child: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 0.0,
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
