import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblaze/data/trailblaze_route.dart';

import '../constants/map_constants.dart';
import '../data/list_item.dart';
import '../widgets/route_info_widget.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key, required this.item});

  final Item item;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  MapboxMap? _mapboxMap;
  late PointAnnotationManager _annotationManager;
  bool _isRouteShowDeferred = false;
  late final TrailblazeRoute _route;

  @override
  initState() {
    super.initState();
    _route = widget.item.route;
  }

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
    _mapboxMap!.compass.updateSettings(kPostDetailsCompassSettings);
    _mapboxMap!.scaleBar.updateSettings(kPostDetailsScaleBarSettings);
    _mapboxMap!.attribution.updateSettings(kDefaultAttributionSettings);
  }

  void _removeRouteLayer() async {
    if (await _mapboxMap!.style.styleLayerExists(kRouteLayerId)) {
      await _mapboxMap!.style.removeStyleLayer(kRouteLayerId);
    }

    if (await _mapboxMap!.style.styleSourceExists(kRouteSourceId)) {
      await _mapboxMap!.style.removeStyleSource(kRouteSourceId);
    }
  }

  void _displayRoute() async {
    await _mapboxMap!.style.addSource(_route.geoJsonSource);

    await _mapboxMap!.style.addLayer(LineLayer(
        id: kRouteLayerId,
        sourceId: kRouteSourceId,
        lineJoin: LineJoin.ROUND,
        lineCap: LineCap.ROUND,
        lineColor: Colors.red.value,
        lineWidth: kRouteLineWidth));

    CameraOptions cameraOptions = await _mapboxMap!.cameraForGeometry(
        _route.geometryJson,
        kPostDetailsCameraState.padding,
        kPostDetailsCameraState.bearing,
        kPostDetailsCameraState.pitch);

    await _mapboxMap!.cancelCameraAnimation();
    await _mapboxMap!.setCamera(cameraOptions);
  }

  void _resetMapCamera() async {
    CameraOptions cameraOptions = await _mapboxMap!.cameraForGeometry(
        _route.geometryJson,
        kPostDetailsCameraState.padding,
        kPostDetailsCameraState.bearing,
        kPostDetailsCameraState.pitch);

    await _mapboxMap!.flyTo(cameraOptions,
        MapAnimationOptions(duration: kMapFlyToDuration, startDelay: 0));
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
        title: Text(widget.item.title),
      ),
      body: IgnorePointer(
        ignoring: false,
        child: Stack(
          children: [
            MapWidget(
              resourceOptions: ResourceOptions(
                accessToken: kMapboxAccessToken,
              ),
              cameraOptions: CameraOptions(
                  zoom: kPostDetailsCameraState.zoom,
                  center: kPostDetailsCameraState.center,
                  bearing: kPostDetailsCameraState.bearing,
                  padding: kPostDetailsCameraState.padding,
                  pitch: kPostDetailsCameraState.pitch),
              onMapCreated: _onMapCreated,
            ),
            Positioned(
              bottom: 72.0,
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
                          onPressed: _resetMapCamera,
                          child: const Icon(
                            Icons.gps_fixed,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  RouteInfo(
                    route: _route,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
