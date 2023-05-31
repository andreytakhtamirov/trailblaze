import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:polyline_codec/polyline_codec.dart';

import '../constants/map_constants.dart';
import '../data/post.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key, required this.post});

  final Post post;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  MapboxMap? _mapboxMap;
  late PointAnnotationManager _annotationManager;
  bool _isRouteShowDeferred = false;

  _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;

    _annotationManager =
        await mapboxMap.annotations.createPointAnnotationManager();
    _setMapControlSettings();

    if (_isRouteShowDeferred) {
      // The map may not have been initialized when the animation
      //  completed. In this case we'll fall back to initializing
      //  the route when the map is initialized.
      _isRouteShowDeferred = false;
      _displayRoute();
    }
  }

  void _setMapControlSettings() {
    _mapboxMap!.attribution.updateSettings(defaultAttributionSettings);
  }

  void _removeRouteLayer() async {
    if (await _mapboxMap!.style.styleLayerExists(routeLayerId)) {
      await _mapboxMap!.style.removeStyleLayer(routeLayerId);
    }

    if (await _mapboxMap!.style.styleSourceExists(routeSourceId)) {
      await _mapboxMap!.style.removeStyleSource(routeSourceId);
    }
  }

  void _displayRoute() async {
    final route = widget.post.route;
    final geometry = route['geometry'];

    List<List<dynamic>> coordinates =
        PolylineCodec.decode(geometry, precision: polylinePrecision)
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

    await _mapboxMap!.style
        .addSource(GeoJsonSource(id: routeSourceId, data: json.encode(fills)));

    await _mapboxMap!.style.addLayer(LineLayer(
        id: routeLayerId,
        sourceId: routeSourceId,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: Colors.red.value,
        lineWidth: routeLineWidth));

    CameraOptions cameraOptions = await _mapboxMap!.cameraForGeometry(
        geometryJson,
        postDetailsCameraState.padding,
        postDetailsCameraState.bearing,
        postDetailsCameraState.pitch);

    await _mapboxMap!.cancelCameraAnimation();
    await _mapboxMap!.setCamera(cameraOptions);
  }

  @override
  Widget build(BuildContext context) {
    var route = ModalRoute.of(context);

    void animationHandler(status) {
      /* Load route to map only when navigation animation is complete.
      *   This is needed to make sure that the map's bounds will not change
      *   while the camera is being updated to show the route.
      */
      if (status == AnimationStatus.completed) {
        route?.animation?.removeStatusListener(animationHandler);

        if (_mapboxMap != null) {
          // Verify that the map has been initialized. Sometimes the map becomes
          //  initialized a little after the animation is completed.
          _displayRoute();
        } else {
          _isRouteShowDeferred = true;
        }
      }
    }

    route?.animation?.addStatusListener(animationHandler);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: IgnorePointer(
        ignoring: true,
        child: MapWidget(
          resourceOptions: ResourceOptions(
            accessToken: mapboxAccessToken,
          ),
          cameraOptions: CameraOptions(
              zoom: postDetailsCameraState.zoom,
              center: postDetailsCameraState.center,
              bearing: postDetailsCameraState.bearing,
              padding: postDetailsCameraState.padding,
              pitch: postDetailsCameraState.pitch),
          onMapCreated: _onMapCreated,
        ),
      ),
    );
  }
}
