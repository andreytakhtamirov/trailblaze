import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:trailblaze/constants/route_info_constants.dart';
import 'package:trailblaze/data/view_mode_context.dart';
import 'package:trailblaze/managers/map_state_notifier.dart';
import 'package:trailblaze/managers/place_manager.dart';
import 'package:trailblaze/screens/distance_selector_screen.dart';
import 'package:trailblaze/util/export_helper.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/util/polyline_helper.dart';
import 'package:trailblaze/widgets/map/top_bars/metrics.dart';
import 'package:trailblaze/widgets/map/top_bars/multi_feature.dart';
import 'package:trailblaze/widgets/map/top_bars/shuffle.dart';
import 'package:turf/turf.dart' as turf;
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/constants/request_api_constants.dart';
import 'package:trailblaze/constants/ui_control_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:trailblaze/managers/feature_manager.dart';
import 'package:trailblaze/screens/waypoint_edit_screen.dart';
import 'package:trailblaze/util/annotation_helper.dart';
import 'package:trailblaze/util/camera_helper.dart';
import 'package:trailblaze/util/firebase_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/util/position_helper.dart';
import 'package:trailblaze/widgets/buttons/set_origin_button.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';
import 'package:trailblaze/widgets/panels/features_panel.dart';
import 'package:trailblaze/widgets/panels/panel_widgets.dart';
import 'package:trailblaze/widgets/panels/place_info_panel.dart';
import 'package:trailblaze/widgets/panels/route_info_panel.dart';
import 'package:trailblaze/widgets/map/picked_locations_widget.dart';
import 'package:trailblaze/widgets/map_light_widget.dart';
import 'package:trailblaze/widgets/search_bar_widget.dart';
import 'package:trailblaze/data/feature.dart' as tb;

import '../data/transportation_mode.dart';
import '../requests/create_route.dart';
import '../widgets/map/map_style_selector_widget.dart';

class MapWidget extends ConsumerStatefulWidget {
  final bool forceTopBottomPadding;
  final bool isInteractiveMap;
  final TrailblazeRoute? routeToDisplay;

  const MapWidget({
    super.key,
    // If this widget is hosted in a scaffold with a bottom navigation bar
    //  (and without a top app bar), we don't need to pad the top and bottom.
    this.forceTopBottomPadding = false,
    this.isInteractiveMap = true,
    this.routeToDisplay,
  });

  @override
  ConsumerState<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends ConsumerState<MapWidget>
    with AutomaticKeepAliveClientMixin<MapWidget> {
  late mbm.MapboxMap _mapboxMap;
  MapBoxPlace? _selectedPlace;
  MapBoxPlace _startingLocation = MapBoxPlace(placeName: "My Location");
  String _selectedMode = kDefaultTransportationMode.value;
  num? _influenceValue;
  List<TrailblazeRoute> routesList = [];
  TrailblazeRoute? _selectedRoute;
  bool _fetchRouteOnNextUpdate = false;
  bool _isContentLoading = false;
  bool _mapStyleTouchContext = false;
  bool _routeControlsTouchContext = false;
  bool _pauseUiCallbacks = false;
  ViewModeContext _viewModeContext = ViewModeContext(viewMode: ViewMode.search);
  ViewModeContext _previousViewModeContext =
      ViewModeContext(viewMode: ViewMode.search);
  late Completer<void> _mapInitializedCompleter;
  AnnotationHelper? annotationHelper;
  double _panelHeight = 0;
  double? _selectedDistanceMeters = kDefaultFeatureDistanceMeters;
  mbm.Position? _userLocation;
  Timer? _cameraScrollTimer;
  Timer? _checkPointsTimer;
  final GlobalKey _topWidgetKey = GlobalKey();
  final GlobalKey _directionsWidgetKey = GlobalKey();
  final GlobalKey _shareWidgetKey = GlobalKey();

  bool _isOriginChanged = false;
  bool _isCameraLocked = false;
  bool _isAvoidAnnotationClicked = false;

  List<double>? _currentOriginCoordinates;
  List<double>? _nextOriginCoordinates;

  final geocoding = GeoCoding(
    apiKey: kMapboxAccessToken,
    types: [PlaceType.address, PlaceType.poi],
    limit: null,
  );

  final PanelController _panelController = PanelController();

  bool _isEditingAvoidArea = false;
  num _area = 0;
  bool _isAvoidActionUndoable = false;
  bool _isAvoidActionRedoable = false;
  int _numAvoidAnnotations = 0;

  MetricType _metricType = MetricType.elevation;
  String? _metricKey;
  double _panelPos = 0;

  @override
  void initState() {
    super.initState();
    _mapInitializedCompleter = Completer<void>();
    geo.Geolocator.getServiceStatusStream().listen((geo.ServiceStatus status) {
      // Listen for location permission granting.
      _getCurrentPosition();
    });

    if (widget.routeToDisplay != null) {
      if (Platform.isAndroid) {
        Future.delayed(const Duration(milliseconds: 50), () {
          _mapInitializedCompleter.future.then((value) {
            _loadRouteToDisplay();
          });
        });
      } else {
        _mapInitializedCompleter.future.then((value) {
          _loadRouteToDisplay();
        });
      }
    } else if (!Platform.isAndroid) {
      // For iOS we need to initialize the annotation manager AFTER showing the location
      _mapInitializedCompleter.future.then((value) {
        Future.delayed(const Duration(milliseconds: 300), () async {
          _initAnnotationManager();
        });
        // Temporary fix for inconsistent behaviour between Mapbox SDK flavours
      });
    }
  }

  Future<void> _initAnnotationManager() async {
    final pointAnnotationManager = await _mapboxMap.annotations
        .createPointAnnotationManager(
            id: 'point-layer', below: 'multi-point-layer');
    final multiPointAnnotationManager = await _mapboxMap.annotations
        .createPointAnnotationManager(id: 'multi-point-layer');
    final circleAnnotationManager = await _mapboxMap.annotations
        .createCircleAnnotationManager(
            id: 'circle-layer', below: 'point-layer');
    final metricAnnotationManager = await _mapboxMap.annotations
        .createCircleAnnotationManager(id: 'metric-layer');
    final avoidAreaAnnotationManager = await _mapboxMap.annotations
        .createCircleAnnotationManager(id: 'avoid-layer');
    final polygonAnnotationManager = await _mapboxMap.annotations
        .createPolygonAnnotationManager(id: 'poly-layer', below: 'avoid-layer');
    annotationHelper = AnnotationHelper(
      pointAnnotationManager,
      multiPointAnnotationManager,
      circleAnnotationManager,
      metricAnnotationManager,
      avoidAreaAnnotationManager,
      polygonAnnotationManager,
      () {
        setState(() {
          _isAvoidAnnotationClicked = true;
        });
      },
    );
  }

  void _loadRouteToDisplay() async {
    await _setViewMode(ViewMode.directions);

    final route = widget.routeToDisplay!;
    await _drawRoute(route);
    routesList.add(route);

    setState(() {
      _selectedRoute = route;
    });

    Future.delayed(const Duration(milliseconds: 20), () {
      if (_selectedRoute != null) {
        _flyToRoute(_selectedRoute!, isAnimated: false);
      }
    });

    _setMapControlSettings();
  }

  _onMapCreated(mbm.MapboxMap mapboxMap) async {
    setState(() {
      _mapboxMap = mapboxMap;
    });
    if (widget.isInteractiveMap) {
      // Only fly to user location if interactive
      await _goToUserLocation(isAnimated: false);
    }
    if (!Platform.isAndroid) {
      await _showUserLocationPuck();
    }
    _setMapControlSettings();

    final camera = await _mapboxMap.getCameraState();
    setState(() {
      _currentOriginCoordinates = [
        camera.center.coordinates.lng.toDouble(),
        camera.center.coordinates.lat.toDouble()
      ];
    });

    // Temporary fix for inconsistent behaviour between Mapbox SDK flavours
    if (Platform.isAndroid) {
      await _initAnnotationManager();
      await _showUserLocationPuck();
    }
    _mapInitializedCompleter.complete();
  }

  Future<void> _setSelectedFeature(tb.Feature selectedFeature,
      {bool skipFlyToFeature = false}) async {
    final f = selectedFeature;
    MapBoxPlace place = MapBoxPlace(
      placeName: f.tags['name'],
      center: (long: f.center['lon'], lat: f.center['lat']),
    );

    if (!skipFlyToFeature) {
      _onSelectPlace(place);
    } else {
      setState(() {
        _selectedPlace = place;
      });
    }
  }

  Future<void> _updateFeatures() async {
    final features = _viewModeContext.features;
    if (_viewModeContext.features == null) return;

    await annotationHelper?.drawPointAnnotationMulti(features!);
    annotationHelper?.simplifyFeatures(_mapboxMap);

    if (features!.isNotEmpty) {
      _pauseUiCallbacksForDuration(kMapFlyToDuration * 3);
      await _flyToFeatures();
    }
  }

  void _pauseUiCallbacksForDuration(int ms) {
    setState(() {
      _pauseUiCallbacks = true;
    });

    Future.delayed(Duration(milliseconds: ms), () {
      setState(() {
        _pauseUiCallbacks = false;
      });
    });
  }

  Future<void> _flyToFeatures() async {
    await _clearCameraPadding();
    final List<mbm.Point> coordinatesList = [];
    for (var f in _viewModeContext.features!) {
      coordinatesList.add(mbm.Point(
          coordinates: mbm.Position(f.center['lon'], f.center['lat'])));
    }

    if (coordinatesList.length == 1) {
      // Only one feature so just fly to it.
      _flyToPlace(coordinatesList.first.coordinates);
      return;
    }

    _flyToCoordinates(coordinatesList);
  }

  void _onManuallySelectFeature(tb.Feature feature) async {
    await _setViewMode(ViewMode.search);
    setState(() {
      _pauseUiCallbacks = true;
    });
    _setSelectedFeature(feature);
    setState(() {
      _pauseUiCallbacks = false;
    });
  }

  void _onFeatureDirectionsClick(tb.Feature feature) async {
    await _setSelectedFeature(feature);
    _onDirectionsClicked();
  }

  void _onFeatureDistanceChanged(double distanceMeters) {
    setState(() {
      _selectedDistanceMeters = distanceMeters;
    });

    _loadParks(_selectedDistanceMeters!);
  }

  Future<void> _loadParks(double distanceMeters) async {
    if (_currentOriginCoordinates == null) {
      UiHelper.showSnackBar(context, "Could not find selected location.");
      return;
    }

    setState(() {
      _isContentLoading = true;
      _selectedDistanceMeters =
          (_selectedDistanceMeters ?? kDefaultFeatureDistanceMeters)
              .clamp(kMinFeatureDistanceMeters, kMaxFeatureDistanceMeters);
    });

    List<tb.Feature>? features;
    if (context.mounted) {
      final featuresPromise = FeatureManager.loadFeatures(
          context,
          (_selectedDistanceMeters ?? kDefaultFeatureDistanceMeters).toInt(),
          _currentOriginCoordinates!);

      features = await featuresPromise;
      if (features.isEmpty) {
        features = null;
      }

      _setParks(features);
    }

    setState(() {
      _isContentLoading = false;
    });
  }

  void _queryForRoundTrip({double? distanceMeters}) async {
    setState(() {
      _isOriginChanged = false;

      if (distanceMeters != null) {
        _selectedDistanceMeters = distanceMeters;
      }
    });
    _getDirectionsFromSettings();
  }

  void _queryCategoryForBBox() async {
    setState(() {
      _isContentLoading = true;
    });
    PlaceManager placeManager = PlaceManager();
    final cameraBounds = ref.watch(mapStateProvider.notifier).getCameraBounds();
    final features = await placeManager.resolveCategory(
        Client(), _viewModeContext.categoryId, cameraBounds);
    if (features == null) {
      if (mounted) {
        UiHelper.showSnackBar(context,
            "Couldn't retrieve category ${_viewModeContext.categoryId}.");
      }
    } else if (mounted) {
      _setMultiFeatures(_viewModeContext.categoryId!, features);
    }
    setState(() {
      _isContentLoading = false;
    });
  }

  void _setMapControlSettings() {
    Timer(const Duration(milliseconds: 300), () {
      if (_isEditingAvoidArea) {
        _mapboxMap.scaleBar
            .updateSettings(mbm.ScaleBarSettings(enabled: false));
        _mapboxMap.compass.updateSettings(mbm.CompassSettings(enabled: false));
        return;
      }

      double topOffset = _getTopOffset();

      final mbm.CompassSettings compassSettings;
      final mbm.ScaleBarSettings scaleBarSettings;

      if ((widget.isInteractiveMap &&
              _viewModeContext.viewMode != ViewMode.shuffle &&
              _viewModeContext.viewMode != ViewMode.directions &&
              _viewModeContext.viewMode != ViewMode.metricDetails &&
              _viewModeContext.viewMode != ViewMode.multiFeatures) ||
          _viewModeContext.viewMode == ViewMode.parks) {
        topOffset += kOptionsPillHeight;
      }

      if (!widget.forceTopBottomPadding) {
        compassSettings = mbm.CompassSettings(
            enabled: true,
            position: kDefaultCompassSettings.position,
            marginTop: kDefaultCompassSettings.marginTop! + topOffset,
            marginBottom: kDefaultCompassSettings.marginBottom,
            marginLeft: kDefaultCompassSettings.marginLeft,
            marginRight: kDefaultCompassSettings.marginRight);
        scaleBarSettings = mbm.ScaleBarSettings(
            enabled: true,
            isMetricUnits: kDefaultScaleBarSettings.isMetricUnits,
            position: kDefaultScaleBarSettings.position,
            marginTop: kDefaultScaleBarSettings.marginTop! + topOffset,
            marginBottom: kDefaultScaleBarSettings.marginBottom,
            marginLeft: kDefaultScaleBarSettings.marginLeft,
            marginRight: kDefaultScaleBarSettings.marginRight);
      } else {
        compassSettings = mbm.CompassSettings(
            enabled: true,
            position: kPostDetailsCompassSettings.position,
            marginTop: kPostDetailsCompassSettings.marginTop! + topOffset,
            marginBottom: kPostDetailsCompassSettings.marginBottom,
            marginLeft: kPostDetailsCompassSettings.marginLeft,
            marginRight: kPostDetailsCompassSettings.marginRight);
        scaleBarSettings = mbm.ScaleBarSettings(
            enabled: true,
            isMetricUnits: kPostDetailsScaleBarSettings.isMetricUnits,
            position: kPostDetailsScaleBarSettings.position,
            marginTop: kPostDetailsScaleBarSettings.marginTop! + topOffset,
            marginBottom: kPostDetailsScaleBarSettings.marginBottom,
            marginLeft: kPostDetailsScaleBarSettings.marginLeft,
            marginRight: kPostDetailsScaleBarSettings.marginRight);
      }

      final num bottomOffset = _getMinPanelHeight();

      final mbm.AttributionSettings kDefaultAttributionSettings =
          mbm.AttributionSettings(
              position: mbm.OrnamentPosition.BOTTOM_LEFT,
              marginTop: 0,
              marginBottom: kAttributionBottomOffset + bottomOffset,
              marginLeft: kAttributionLeftOffset,
              marginRight: 0);

      final mbm.LogoSettings kDefaultLogoSettings = mbm.LogoSettings(
          position: mbm.OrnamentPosition.BOTTOM_LEFT,
          marginTop: 0,
          marginBottom: kAttributionBottomOffset + bottomOffset,
          marginLeft: kLogoLeftOffset,
          marginRight: 0);

      _mapboxMap.compass.updateSettings(compassSettings);
      _mapboxMap.scaleBar.updateSettings(scaleBarSettings);
      _mapboxMap.attribution.updateSettings(kDefaultAttributionSettings);
      _mapboxMap.logo.updateSettings(kDefaultLogoSettings);
    });
  }

  double _getTopOffset() {
    double topOffset = 0;
    final GlobalKey key;
    if (_shouldShowDirectionsTopBar()) {
      key = _directionsWidgetKey;
    } else {
      key = _topWidgetKey;
    }

    final double height = key.currentContext != null
        ? (key.currentContext?.findRenderObject() as RenderBox).size.height
        : 0;

    if (_shouldShowDirectionsTopBar() &&
        _viewModeContext.viewMode == ViewMode.search) {
      topOffset = kSearchBarHeight + 8;
    } else if (_viewModeContext.viewMode == ViewMode.directions ||
        _viewModeContext.viewMode == ViewMode.shuffle ||
        _viewModeContext.viewMode == ViewMode.metricDetails ||
        _viewModeContext.viewMode == ViewMode.multiFeatures) {
      topOffset = height;
    }

    if (!widget.forceTopBottomPadding) {
      // Need to compensate for Android status bar.
      topOffset += kAndroidTopOffset;
    }

    return topOffset;
  }

  double _getBottomOffset() {
    double bottomOffset;
    if (_panelController.isAttached) {
      bottomOffset = (_getMaxPanelHeight() - _getMinPanelHeight()) *
              _panelController.panelPosition +
          _getMinPanelHeight();
    } else {
      bottomOffset = 0;
    }

    if (widget.forceTopBottomPadding &&
        _viewModeContext.viewMode == ViewMode.metricDetails) {
      bottomOffset = kSafeAreaPaddingBottom;
    }

    return bottomOffset;
  }

  Future<geo.Position?> _getCurrentPosition() async {
    geo.Position? position = await PositionHelper.getCurrentPosition(context);
    if (position == null) {
      return null;
    }

    MapBoxPlace myLocation = MapBoxPlace(
        placeName: "My Location",
        center: (long: position.longitude, lat: position.latitude));

    setState(() {
      _startingLocation = myLocation;
      _userLocation = mbm.Position(position.longitude, position.latitude);
    });

    return position;
  }

  mbm.MbxEdgeInsets _getCameraPadding({bool ignoreBottom = false}) {
    double topOffset = _getTopOffset();
    double bottomOffset = !ignoreBottom ? _getBottomOffset() : 0;

    // Offset bottom by refresh button height.
    if (_viewModeContext.viewMode == ViewMode.shuffle) {
      bottomOffset += kOptionsPillHeight;
    }

    // Widget is inside a view with an app bar.
    // Need to compensate for extra padding.
    if (widget.forceTopBottomPadding) {
      topOffset -= 80;
    }

    return mbm.MbxEdgeInsets(
      top: (widget.isInteractiveMap ? 8 : 0) + topOffset,
      left: 0,
      bottom: bottomOffset,
      right: 0,
    );
  }

  void _onGpsButtonPressed() {
    setState(() {
      _isCameraLocked = false;
    });
    _goToUserLocation();
  }

  void _displayRoute(String profile, List<MapBoxPlace> waypoints) async {
    bool isRoundTrip = waypoints.length == 1;
    final double? distance = isRoundTrip ? _selectedDistanceMeters : null;

    await _removeRouteLayers();

    setState(() {
      _isContentLoading = true;
    });

    final dartz.Either<int, Map<String, dynamic>?> routeResponse;
    routeResponse = await createGraphhopperRoute(
      profile,
      waypoints,
      isRoundTrip: isRoundTrip,
      distanceMeters: distance,
      avoidArea: annotationHelper?.getAvoidPolygon(),
      influence: _influenceValue,
    );

    setState(() {
      _isContentLoading = false;
    });

    Map<String, dynamic>? routeData;

    routeResponse.fold(
      (error) => {
        if (error == 406)
          {
            UiHelper.showSnackBar(
                context, "Sorry, this region is not supported yet.")
          }
        else if (error == 422)
          {UiHelper.showSnackBar(context, "Requested points are too far away.")}
        else if (error == 404)
          {UiHelper.showSnackBar(context, "Failed to connect to the server.")}
        else
          {UiHelper.showSnackBar(context, "An unknown error occurred.")}
      },
      (data) => {routeData = data},
    );

    List<dynamic> routesJson = [];
    if ((routeData == null || routeData?['routes'] == null) &&
        routeData?['paths'] == null) {
      return;
    } else if (routeData?['routes'] != null) {
      routesJson = routeData!['routes'];
    } else {
      routesJson = routeData!['paths'];
    }

    for (var i = routesJson.length - 1; i >= 0; i--) {
      final routeJson = routesJson[i];

      bool isFirstRoute = i == 0;

      TrailblazeRoute route = TrailblazeRoute(
        kRouteSourceId + i.toString(),
        kRouteLayerId + i.toString(),
        routeJson,
        waypoints,
        routeData?['routeOptions'],
        isActive: isFirstRoute,
        isGraphhopperRoute: true,
      );

      _drawRoute(route);
      routesList.add(route);
    }

    setState(() {
      // The first route is selected initially.
      _selectedRoute = routesList.last;
    });

    if (_selectedRoute != null) {
      _flyToRoute(_selectedRoute!);
    }
    _setMapControlSettings();
  }

  void _flyToRoute(TrailblazeRoute route, {bool isAnimated = true}) async {
    await _clearCameraPadding();
    setState(() {
      _isCameraLocked = true;
    });

    final height = mounted ? MediaQuery.of(context).size.height : 0.0;
    final width = mounted ? MediaQuery.of(context).size.width : 0.0;

    final cameraForRoute = await CameraHelper.cameraOptionsForRoute(
      _mapboxMap,
      route,
      _getCameraPadding(),
      height,
      width,
    );
    await _mapFlyToOptions(cameraForRoute, isAnimated: isAnimated);
  }

  void _onFlyToRoute() async {
    Timer(const Duration(milliseconds: 300), () {
      if (_selectedRoute != null) {
        _flyToRoute(_selectedRoute!);
      }
    });
  }

  Future<void> _mapFlyToOptions(mbm.CameraOptions options,
      {bool isAnimated = true}) async {
    if (isAnimated) {
      await _mapboxMap.flyTo(options,
          mbm.MapAnimationOptions(duration: kMapFlyToDuration, startDelay: 0));
    } else {
      await _mapboxMap.setCamera(options);
    }
  }

  Future<void> _flyToPlace(mbm.Position coordinates) {
    return _mapFlyToOptions(
      mbm.CameraOptions(
          center: mbm.Point(coordinates: coordinates),
          padding: _getCameraPadding(),
          zoom: kDefaultCameraState.zoom + kPointSelectedCameraZoomOffset,
          bearing: kDefaultCameraState.bearing,
          pitch: kDefaultCameraState.pitch),
    );
  }

  Future<void> _flyToCoordinates(List<mbm.Point> coordinates) async {
    final height = mounted ? MediaQuery.of(context).size.height : 0.0;
    final width = mounted ? MediaQuery.of(context).size.width : 0.0;
    final cameraForCoordinates = await CameraHelper.cameraOptionsForCoordinates(
      _mapboxMap,
      coordinates,
      _getCameraPadding(ignoreBottom: false),
      height,
      width,
    );

    await _mapFlyToOptions(cameraForCoordinates);
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

      if (_viewModeContext.viewMode == ViewMode.metricDetails) {
        setState(() {
          _metricKey = null;
        });
        _cleanMetricAnnotations();
      }
    }
  }

  Future<void> _updateRouteSelected(
      TrailblazeRoute route, bool isSelected) async {
    route.setActive(isSelected);
    await _mapboxMap.style.updateLayer(route.lineLayer);
    await _drawRoute(route);
  }

  Future<void> _drawRoute(TrailblazeRoute route) async {
    await annotationHelper?.deleteAllAnnotations();
    try {
      await _mapboxMap.style.addSource(route.geoJsonSource);
    } catch (e) {
      // Source might exist already
    }

    try {
      await _mapboxMap.style.removeStyleLayer(route.lineLayer.id);
    } catch (e) {
      // Route layer might have been removed already.
    }

    try {
      await _mapboxMap.style
          .addLayerAt(route.lineLayer, mbm.LayerPosition(below: "road-label"));
    } catch (e) {
      // "road-label" may not have been created yet or doesn't exist.
      await _mapboxMap.style.addLayer(route.lineLayer);
    }

    for (var i = 0; i < route.waypoints.length; i++) {
      final mbp = route.waypoints[i];
      final point = mbm.Position(mbp.center?.long ?? 0, mbp.center?.lat ?? 0);

      if (i == 0) {
        annotationHelper?.drawStartAnnotation(point);
      } else {
        annotationHelper?.drawSingleAnnotation(point);
      }
    }
  }

  Future<void> _removeRouteLayers() async {
    final copyList = [...routesList];
    routesList.clear();
    for (var route in copyList) {
      await _removeRouteLayer(route);
    }
  }

  Future<void> _removeRouteLayer(TrailblazeRoute route) async {
    try {
      if (await _mapboxMap.style.styleLayerExists(route.layerId)) {
        await _mapboxMap.style.removeStyleLayer(route.layerId);
      }
    } catch (e) {
      log('Exception removing route style layer: $e');
    }

    try {
      if (await _mapboxMap.style.styleSourceExists(route.sourceId)) {
        await _mapboxMap.style.removeStyleSource(route.sourceId);
      }
    } catch (e) {
      log('Exception removing route style source layer: $e');
    }
  }

  Future<void> _drawMetric(MetricType type, String targetKey) async {
    final Map<String, List<List<List<num>>>> polylines;
    switch (type) {
      case MetricType.elevation:
        return;
      case MetricType.surface:
        polylines = _selectedRoute!.surfacePolylines!;
        break;
      case MetricType.roadClass:
        polylines = _selectedRoute!.roadClassPolylines!;
        break;
    }

    final p = polylines[targetKey]!;
    await _drawLine(p, targetKey);
    await _flyToMetric(p, targetKey);
  }

  Future<void> _drawLine(List<List<List<num>>> polylines, String key) async {
    await _deleteMetricLines();

    try {
      await _mapboxMap.style
          .addSource(PolylineHelper.buildGeoJsonSource(polylines, key));
    } catch (e) {
      // Source might exist already
    }

    await _mapboxMap.style.addLayerAt(PolylineHelper.buildLineLayer(key),
        mbm.LayerPosition(below: "road-label"));
  }

  Future<void> _deleteMetricLines() async {
    final layers = await _mapboxMap.style.getStyleLayers();

    for (mbm.StyleObjectInfo? l in layers) {
      if (l!.id.startsWith(kMetricLayerIdPrefix)) {
        try {
          await _mapboxMap.style.removeStyleLayer(l.id);
        } catch (e) {
          // Layer might have been removed already.
        }
      }
    }

    final sources = await _mapboxMap.style.getStyleSources();
    for (mbm.StyleObjectInfo? l in sources) {
      if (l!.id.startsWith(kMetricLayerIdPrefix)) {
        try {
          await _mapboxMap.style.removeStyleSource(l.id);
        } catch (e) {
          // Layer might have been removed already.
        }
      }
    }
  }

  Future<void> _flyToMetric(List<List<List<num>>> polylines, String key) async {
    await _clearCameraPadding();
    final height = mounted ? MediaQuery.of(context).size.height : 0.0;
    final width = mounted ? MediaQuery.of(context).size.width : 0.0;

    final cameraForRoute = await CameraHelper.cameraOptionsForGeometry(
      _mapboxMap,
      PolylineHelper.buildFlatLineString(polylines, key),
      _getCameraPadding(),
      height,
      width,
    );
    await _mapFlyToOptions(cameraForRoute, isAnimated: true);
    setState(() {
      _isCameraLocked = false;
    });
  }

  Future<void> _onExportRoute() async {
    if (_selectedRoute == null ||
        _selectedRoute!.coordinates == null ||
        _selectedRoute!.elevationMetrics == null) {
      UiHelper.showSnackBar(
        context,
        'Unable to export route.',
        margin: const EdgeInsets.only(
          bottom: 100,
          right: 40,
          left: 40,
        ),
      );
      return;
    }
    FirebaseHelper.logEvent("Export",
        {'d': FormatHelper.formatDistancePrecise(_selectedRoute?.distance)});
    final coordinates = _selectedRoute!.coordinates!;
    final elevation = _selectedRoute!.elevationMetrics!;
    final gpx = ExportHelper.generateGpx(coordinates, elevation);

    final lastWaypoint = _selectedRoute!.waypoints.last;
    final box =
        (_shareWidgetKey.currentContext?.findRenderObject() as RenderBox);
    await ExportHelper.shareGpxFile(gpx, lastWaypoint.placeName ?? '',
        box.localToGlobal(Offset.zero) & box.size);
  }

  Future<void> _goToUserLocation({bool isAnimated = true}) async {
    geo.Position? position = await _getCurrentPosition();
    mbm.CameraOptions options = _cameraForUserPosition(position);
    _setOriginCoordinates(options);
    await _mapFlyToOptions(options, isAnimated: isAnimated);
    _updateCameraState();
  }

  mbm.CameraOptions _cameraForUserPosition(geo.Position? position) {
    final mbm.Point center;

    if (position != null && position.latitude != 0 && position.longitude != 0) {
      center = mbm.Point(
          coordinates: mbm.Position(position.longitude, position.latitude));
    } else {
      center = kDefaultCameraState.center;
    }
    return mbm.CameraOptions(
      center: center,
      padding: mbm.MbxEdgeInsets(
        top: _getTopOffset(),
        bottom: _getBottomOffset(),
        left: 0,
        right: 0,
      ),
      zoom: kDefaultCameraState.zoom,
    );
  }

  void _setOriginCoordinates(mbm.CameraOptions options) {
    if (options.center != null) {
      setState(() {
        _currentOriginCoordinates = [
          options.center?.coordinates.lng.toDouble() ?? 0,
          options.center?.coordinates.lat.toDouble() ?? 0
        ];
      });
    }
  }

  Future<void> _showUserLocationPuck() async {
    final ByteData bytes = await rootBundle.load('assets/location-puck.png');
    final Uint8List list = bytes.buffer.asUint8List();

    return await _mapboxMap.location.updateSettings(
      mbm.LocationComponentSettings(
        // Layer order behaves differently on each platform
        layerAbove: Platform.isAndroid ? null : 'multi-point-layer',
        layerBelow: Platform.isAndroid ? 'multi-point-layer' : null,
        locationPuck: mbm.LocationPuck(
          locationPuck2D: mbm.LocationPuck2D(topImage: list),
        ),
        enabled: true,
      ),
    );
  }

  void _onSelectPlace(MapBoxPlace? place,
      {bool isPlaceDataUpdate = false}) async {
    setState(() {
      _selectedPlace = place;
    });

    if (place == null) {
      _setMapControlSettings();
    }

    if (isPlaceDataUpdate) {
      // We don't need to redraw the annotation since
      // the only thing that changes is the place name.
      return;
    }

    if (place != null) {
      if (place.center != null) {
        setState(() {
          _currentOriginCoordinates = [
            place.center?.long ?? 0,
            place.center?.lat ?? 0
          ];
        });
      }

      _flyToPlace(
          mbm.Position(place.center?.long ?? 0, place.center?.lat ?? 0));
      annotationHelper?.drawSingleAnnotation(
          mbm.Position(place.center?.long ?? 0, place.center?.lat ?? 0));
    } else {
      annotationHelper?.deleteAllAnnotations();
    }
  }

  void _getDirectionsFromSettings() {
    setState(() {
      _isOriginChanged = false;
    });
    List<MapBoxPlace> waypoints = [];

    if (_viewModeContext.viewMode == ViewMode.directions) {
      waypoints.insert(0, _startingLocation);
      if (_selectedPlace != null) {
        waypoints.add(_selectedPlace!);
      }
    } else if (_viewModeContext.viewMode == ViewMode.shuffle) {
      waypoints.add(CameraHelper.getMapBoxPlaceFromLonLat(
          _currentOriginCoordinates,
          '${FormatHelper.formatDistance(_selectedDistanceMeters, noRemainder: true)} round trip'));
    }
    _displayRoute(_selectedMode, waypoints);
  }

  void _clearAvoidArea() {
    annotationHelper?.deleteAvoidArea();
    setState(() {
      _area = 0;
    });
    _onAvoidAnnotationsUpdate();
  }

  void _undoAvoidArea() async {
    annotationHelper?.undoLastAction();
    _onAvoidAnnotationsUpdate();
    _updateAvoidPoly();
  }

  void _redoAvoidArea() async {
    annotationHelper?.redoLastAction();
    _onAvoidAnnotationsUpdate();
    _updateAvoidPoly();
  }

  void _updateAvoidPoly() {
    if (annotationHelper != null &&
        annotationHelper!.avoidAnnotations.length > 2) {
      annotationHelper?.drawPolygonAnnotation();
    }
  }

  void _onAvoidAnnotationsUpdate() {
    setState(() {
      _numAvoidAnnotations = annotationHelper?.avoidAnnotations.length ?? 0;
      _isAvoidActionUndoable = annotationHelper?.canUndoAvoidAction() ?? false;
      _isAvoidActionRedoable = annotationHelper?.canRedoAvoidAction() ?? false;
    });

    final mbm.Polygon? poly = annotationHelper?.getAvoidPolygon();
    setState(() {
      if (poly != null) {
        _area = turf.area(poly) ?? 0; // Square km
      } else {
        _area = 0;
      }
    });
  }

  Future<void> _onMapTapListener(mbm.MapContentGestureContext context) async {
    final coordinate = context.point.coordinates;

    if (_isEditingAvoidArea) {
      Timer(const Duration(milliseconds: 10), () async {
        if (_isAvoidAnnotationClicked) {
          // Action already handled by annotation callback.
          setState(() {
            _isAvoidAnnotationClicked = false;
          });
        } else {
          await annotationHelper?.showAvoidAnnotation(coordinate);
        }

        _updateAvoidPoly();
        _onAvoidAnnotationsUpdate();
      });
      return;
    }

    if (_viewModeContext.viewMode != ViewMode.directions ||
        _viewModeContext.viewMode == ViewMode.metricDetails) {
      await annotationHelper?.deletePointAnnotations();
    }

    if (_viewModeContext.viewMode == ViewMode.directions ||
        _viewModeContext.viewMode == ViewMode.metricDetails) {
      TrailblazeRoute? selectedRoute;
      final cameraState = await _mapboxMap.getCameraState();

      selectedRoute = await AnnotationHelper.getRouteByClickProximity(
        routesList,
        coordinate.lng,
        coordinate.lat,
        cameraState.zoom,
      );

      // A route layer has been clicked.
      if (selectedRoute != null && selectedRoute != _selectedRoute) {
        _setSelectedRoute(selectedRoute);
        // We've handled the click event so
        //  we can avoid all other things.
        return;
      }

      // Block other map clicks when showing route.
      return;
    } else if (_viewModeContext.viewMode == ViewMode.parks ||
        _viewModeContext.viewMode == ViewMode.multiFeatures &&
            _viewModeContext.features != null) {
      final cameraState = await _mapboxMap.getCameraState();
      final closestFeature = await AnnotationHelper.getFeatureByClickProximity(
          _viewModeContext.features ?? [],
          coordinate.lng,
          coordinate.lat,
          cameraState.zoom);

      if (closestFeature != null) {
        final coordinates =
            annotationHelper?.coordinatesForCluster(closestFeature);
        if (coordinates != null) {
          // Reveal clustered features
          _flyToCoordinates(coordinates);
          return;
        }

        _onManuallySelectFeature(closestFeature);
        return;
      } else if (_viewModeContext.viewMode == ViewMode.parks) {
        await _togglePanel(false);
        _selectOriginOnMap(
            [coordinate.lng.toDouble(), coordinate.lat.toDouble()]);
        return;
      }
    } else if (_viewModeContext.viewMode == ViewMode.shuffle) {
      _selectOriginOnMap(
          [coordinate.lng.toDouble(), coordinate.lat.toDouble()]);
      return;
    }

    MapBoxPlace place = MapBoxPlace(center: (
      long: coordinate.lng.toDouble(),
      lat: coordinate.lat.toDouble()
    ));

    _onSelectPlace(place);

    final futureAddress = await geocoding.getAddress(
        (lat: coordinate.lat.toDouble(), long: coordinate.lng.toDouble()));

    futureAddress.fold((places) {
      String? placeName;
      if (places.isNotEmpty) {
        MapBoxPlace? place;
        for (MapBoxPlace p in places) {
          if (p.placeType.contains(PlaceType.poi)) {
            // Prioritize POI over address
            place = p;
            break;
          } else if (p.placeType.contains(PlaceType.address)) {
            place = p;
          }
        }

        if (place != null) {
          placeName = place.placeName!;
        }
      }

      placeName ??=
          "(${coordinate.lng.toStringAsFixed(4)}, ${coordinate.lat.toStringAsFixed(4)})";

      MapBoxPlace updatedPlace = MapBoxPlace(placeName: placeName, center: (
        long: coordinate.lng.toDouble(),
        lat: coordinate.lat.toDouble()
      ));
      _onSelectPlace(updatedPlace, isPlaceDataUpdate: true);
      _setMapControlSettings();
    }, (failure) => () {});
  }

  void _onMapScrollListener(mbm.MapContentGestureContext context) async {
    if (_isCameraLocked) {
      setState(() {
        _isCameraLocked = false;
      });
    }
  }

  void _onMapCameraChangeListener(mbm.CameraChangedEventData data) {
    if (_viewModeContext.features?.isNotEmpty == true) {
      _debounceSimplifyFeatures();
    }

    if (_pauseUiCallbacks) {
      return;
    }
    _debounceUpdateCameraState();
  }

  void _debounceSimplifyFeatures() {
    if (_checkPointsTimer?.isActive ?? false) _checkPointsTimer!.cancel();
    _checkPointsTimer = Timer(const Duration(milliseconds: 150), () {
      _simplifyFeatures();
    });
  }

  void _simplifyFeatures() {
    annotationHelper?.simplifyFeatures(_mapboxMap);
  }

  void _selectOriginOnMap(List<double> coordinates) {
    setState(() {
      _nextOriginCoordinates = coordinates;
      _isOriginChanged = true;
    });
    annotationHelper?.drawOriginAnnotation(
        mbm.Position(_nextOriginCoordinates![0], _nextOriginCoordinates![1]));
  }

  void _debounceUpdateCameraState() {
    if (_cameraScrollTimer?.isActive ?? false) _cameraScrollTimer!.cancel();
    _cameraScrollTimer = Timer(const Duration(milliseconds: 150), () {
      if (_viewModeContext.viewMode != ViewMode.multiFeatures) {
        // State could have changed in between.
        return;
      }
      _updateCameraState();
      setState(() {
        _isOriginChanged = true;
      });
    });
  }

  Future<void> _updateCameraState() async {
    final bounds =
        await _mapboxMap.coordinateBoundsForCamera(mbm.CameraOptions());
    ref.watch(mapStateProvider.notifier).setCameraBounds(bounds);
  }

  void _onDirectionsBackClicked() async {
    if (_previousViewModeContext.viewMode != ViewMode.metricDetails) {
      await _setViewMode(
        _previousViewModeContext.viewMode,
        categoryId: _previousViewModeContext.categoryId,
        features: _previousViewModeContext.features,
      );
    } else {
      await _setViewMode(ViewMode.search);
    }
    setState(() {
      _selectedRoute = null;
      _removeRouteLayers();
    });

    _setOriginToUserLocation();
    annotationHelper?.deleteCircleAnnotations();
    annotationHelper?.clearAvoidActionHistory();
    _clearAvoidArea();
    _setMapControlSettings();
  }

  void _setOriginToUserLocation() async {
    final position = await _getCurrentPosition();
    if (position != null) {
      setState(() {
        _currentOriginCoordinates = [position.longitude, position.latitude];
      });
    }
  }

  void _onRouteSettingsChanged(
      TransportationMode mode, num? influenceValue, bool isSilent) {
    setState(() {
      _selectedMode = mode.value;
      _influenceValue = influenceValue;
      _routeControlsTouchContext = false;
    });

    if (!isSilent || _fetchRouteOnNextUpdate) {
      if (_fetchRouteOnNextUpdate) {
        setState(() {
          _fetchRouteOnNextUpdate = false;
        });
      }
      _getDirectionsFromSettings();
    }
  }

  Future<void> _showEditDirectionsScreen() async {
    FirebaseHelper.logScreen("EditDirections");
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaypointEditScreen(
          onSearchBarTap: _updateCameraState,
          startingLocation: _startingLocation,
          endingLocation: _selectedPlace,
          waypoints: const [],
        ),
      ),
    );

    if (result == null) {
      return;
    }

    //final List<dynamic> waypoints = result['waypoints']; TODO not implemented
    final MapBoxPlace startingLocation = result['startingLocation'];
    final MapBoxPlace endingLocation = result['endingLocation'];

    setState(() {
      _startingLocation = startingLocation;
    });

    annotationHelper?.deleteAllAnnotations();
    _onSelectPlace(endingLocation);

    setState(() {
      _fetchRouteOnNextUpdate = true;
    });
  }

  void _onStyleChanged(String newStyleId) async {
    setState(() {
      _mapStyleTouchContext = false;
    });

    String styleUri = '$kMapStyleUriPrefix/$newStyleId';

    if (await _mapboxMap.style.getStyleURI() == styleUri) {
      // Don't update if nothing changed.
      return;
    }

    await _mapboxMap.style.setStyleURI(styleUri);

    // Redraw routes to show them on top of the new style.
    for (var route in routesList) {
      if (route == _selectedRoute) {
        continue;
      }

      await _removeRouteLayer(route);
      _drawRoute(route);
    }

    if (_selectedRoute != null) {
      await _removeRouteLayer(_selectedRoute!);
      _drawRoute(_selectedRoute!);
    }

    if (_viewModeContext.viewMode == ViewMode.metricDetails &&
        _metricType != MetricType.elevation &&
        _metricKey != null) {
      _onMetricChanged(_metricType, _metricKey);
    }
  }

  void _onTapOutsideMapStyle(PointerDownEvent event) {
    setState(() {
      _mapStyleTouchContext = false;
    });
  }

  void _onTapInsideMapStyle(PointerDownEvent event) {
    setState(() {
      _mapStyleTouchContext = true;
    });
  }

  void _onCollapseRouteControls() {
    setState(() {
      _routeControlsTouchContext = false;
    });
  }

  void _onExpandRouteControls() {
    setState(() {
      _routeControlsTouchContext = true;
    });
  }

  void _onDirectionsClicked() async {
    await _togglePanel(false);
    await _setViewMode(ViewMode.directions);

    if (_selectedMode == TransportationMode.none.value) {
      _onExpandRouteControls();
      return;
    }

    _getDirectionsFromSettings();
  }

  void _onMapOriginAction(bool isUpdate) {
    if (isUpdate) {
      setState(() {
        if (_nextOriginCoordinates != null) {
          _currentOriginCoordinates = _nextOriginCoordinates;
        }
        _isOriginChanged = false;
      });

      if (_viewModeContext.viewMode == ViewMode.shuffle) {
        _queryForRoundTrip();
      } else if (_viewModeContext.viewMode == ViewMode.parks) {
        _loadParks(_selectedDistanceMeters!);
      } else if (_viewModeContext.viewMode == ViewMode.multiFeatures) {
        _queryCategoryForBBox();
      }
    } else {
      setState(() {
        annotationHelper?.deleteOriginAnnotation();
        _isOriginChanged = false;
      });
    }
  }

  Future<void> _toggleParksMode() async {
    if (_viewModeContext.viewMode == ViewMode.parks) {
      await _setViewMode(ViewMode.search);

      // Reset previous ViewMode state.
      setState(() {
        _previousViewModeContext = _viewModeContext;
      });
      await annotationHelper?.deleteAllAnnotations();
      _onSelectPlace(null);
    } else {
      FirebaseHelper.logScreen("NearbyParks");
      _loadParks(kDefaultFeatureDistanceMeters);
    }
  }

  Future<void> _toggleShuffleMode() async {
    if (_viewModeContext.viewMode == ViewMode.shuffle) {
      await _setViewMode(ViewMode.search);
      await annotationHelper?.deleteAllAnnotations();
      _onSelectPlace(null);
    } else {
      FirebaseHelper.logScreen("Shuffle");
      await _setViewMode(ViewMode.shuffle);
      setState(() {
        _pauseUiCallbacks = true;
        if (_selectedPlace != null && _selectedPlace!.center != null) {
          _currentOriginCoordinates = [
            _selectedPlace!.center!.long,
            _selectedPlace!.center!.lat
          ];
        }
      });

      _onSelectPlace(null);
      await _togglePanel(false);
      setState(() {
        _pauseUiCallbacks = false;
      });

      if (_selectedMode == TransportationMode.none.value) {
        setState(() {
          _selectedMode = TransportationMode.walking.value;
        });
      }
      _queryForRoundTrip();
    }
  }

  void _onMapControlChanged(bool isEditingAvoidArea) {
    setState(() {
      _isEditingAvoidArea = isEditingAvoidArea;
    });

    if (_isEditingAvoidArea) {
      annotationHelper
          ?.showAvoidAnnotations(annotationHelper?.avoidAnnotations ?? []);
    } else {
      annotationHelper?.hideAvoidAnnotations();
      _getDirectionsFromSettings();
      setState(() {
        _routeControlsTouchContext = false;
      });
    }
  }

  Future<void> _togglePanel(bool isOpen, {bool toSnapPoint = false}) async {
    if (!_panelController.isAttached) {
      return;
    }

    if (isOpen && !toSnapPoint) {
      await _panelController.open();
    } else if (isOpen && toSnapPoint) {
      await _panelController.animatePanelToSnapPoint();
    } else if (!isOpen) {
      await _panelController.close();
    }
  }

  double _getMaxPanelHeight() {
    if (_viewModeContext.viewMode == ViewMode.search &&
        _selectedPlace != null) {
      return kPanelMaxHeight;
    } else if (_viewModeContext.viewMode == ViewMode.search) {
      return 0;
    } else if (_viewModeContext.viewMode == ViewMode.metricDetails) {
      return 0;
    } else if (_viewModeContext.viewMode == ViewMode.parks ||
        _viewModeContext.viewMode == ViewMode.multiFeatures) {
      final size = MediaQuery.sizeOf(context);
      final double screenHeight =
          size.height - kAppPadding - kMapExtraWidgetsHeight;
      return screenHeight;
    } else if (_viewModeContext.viewMode == ViewMode.directions ||
        _viewModeContext.viewMode == ViewMode.shuffle) {
      final padding = MediaQuery.paddingOf(context);
      final size = MediaQuery.sizeOf(context);
      final topPadding = padding.top;
      final screenHeight = size.height;
      if (screenHeight - kAppBarHeight < _panelHeight + kPanelGrabberHeight) {
        return screenHeight -
            topPadding -
            kAppBarHeight -
            kPanelOverflowMarginTop;
      } else {
        return _panelHeight + kPanelGrabberHeight;
      }
    } else {
      return kPanelFeaturesMaxHeight;
    }
  }

  double _getMinPanelHeight() {
    if (_viewModeContext.viewMode == ViewMode.search &&
        _selectedPlace != null) {
      return kPanelMinContentHeight;
    } else if (_viewModeContext.viewMode == ViewMode.search ||
        (_viewModeContext.viewMode == ViewMode.directions &&
            _selectedRoute == null)) {
      return 0;
    } else if (_viewModeContext.viewMode == ViewMode.metricDetails) {
      return 0;
    } else if ((_viewModeContext.viewMode == ViewMode.directions ||
            _viewModeContext.viewMode == ViewMode.shuffle) &&
        _selectedRoute != null) {
      return kPanelRouteInfoMinHeight;
    } else {
      return kPanelMinContentHeight;
    }
  }

  bool _isPanelBackdrop() {
    // In the directions view, the panel appears over
    //  top of the map thus not affecting padding.
    return _viewModeContext.viewMode == ViewMode.directions ||
        _viewModeContext.viewMode == ViewMode.shuffle;
  }

  bool _shouldShowDirectionsTopBar() {
    return widget.isInteractiveMap &&
        (_viewModeContext.viewMode == ViewMode.search ||
            _viewModeContext.viewMode == ViewMode.directions) &&
        _viewModeContext.viewMode != ViewMode.multiFeatures &&
        _viewModeContext.viewMode != ViewMode.parks &&
        _viewModeContext.viewMode != ViewMode.metricDetails;
  }

  Future<void> _clearCameraPadding() async {
    return await _mapboxMap.setCamera(
      mbm.CameraOptions(
        padding: mbm.MbxEdgeInsets(
          top: 0,
          left: 0,
          bottom: 0,
          right: 0,
        ),
      ),
    );
  }

  Future<void> _setViewMode(
    ViewMode newViewMode, {
    String? categoryId,
    List<tb.Feature>? features,
  }) async {
    setState(() {
      _previousViewModeContext = _viewModeContext;
      _viewModeContext = ViewModeContext(
        viewMode: newViewMode,
        categoryId: categoryId,
        features: features,
      );
    });

    // Perform actions based on previous ViewMode (usually cleaning up).
    if (_previousViewModeContext.viewMode == ViewMode.parks ||
        _previousViewModeContext.viewMode == ViewMode.multiFeatures) {
      setState(() {
        _previousViewModeContext = ViewModeContext(
          viewMode: _previousViewModeContext.viewMode,
          categoryId: _previousViewModeContext.categoryId,
          features: _previousViewModeContext.features,
        );
        _isOriginChanged = false;

        // Don't reset selected place if going to directions view from parks/multi features.
        if (_viewModeContext.viewMode != ViewMode.directions) {
          _selectedPlace = null;
        }
      });
      annotationHelper?.clearPointAnnotations();
    } else if ((_previousViewModeContext.viewMode == ViewMode.directions ||
            _previousViewModeContext.viewMode == ViewMode.shuffle) &&
        _viewModeContext.viewMode != ViewMode.metricDetails) {
      await _removeRouteLayers();
    } else if (_previousViewModeContext.viewMode == ViewMode.search) {
      annotationHelper?.deletePointAnnotations();
    }

    // Perform actions based on new ViewMode
    if (_viewModeContext.viewMode == ViewMode.parks ||
        _viewModeContext.viewMode == ViewMode.multiFeatures) {
      if (_viewModeContext.features != null) {
        _togglePanel(false);
      } else {
        _togglePanel(true, toSnapPoint: true);
      }
      setState(() {
        _selectedPlace = null;
      });
      _updateFeatures();
    } else if (_viewModeContext.viewMode == ViewMode.search) {
      _togglePanel(false);
    }

    _setMapControlSettings();
  }

  void _setParks(List<tb.Feature>? features) async {
    await _setViewMode(
      ViewMode.parks,
      categoryId: 'park',
      features: features,
    );
  }

  void _setMultiFeatures(String categoryId, List<tb.Feature> features) async {
    await _setViewMode(
      ViewMode.multiFeatures,
      categoryId: categoryId,
      features: features,
    );
  }

  void _onReturnToFeatures() async {
    await _setViewMode(
      _previousViewModeContext.viewMode,
      categoryId: _previousViewModeContext.categoryId,
      features: _previousViewModeContext.features,
    );
  }

  void _onPreviewMetric(MetricType type) async {
    await _togglePanel(false);
    await _setViewMode(ViewMode.metricDetails);

    setState(() {
      _metricType = type;
      _metricKey = null;
    });

    _onFlyToRoute();
  }

  void _onMetricChanged(MetricType type, String? key) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        _metricType = type;
        _metricKey = key;
      });

      if (_metricKey == null) {
        // Type has changed
        _cleanMetricAnnotations();
        _flyToRoute(_selectedRoute!);
      } else {
        _drawMetric(_metricType, _metricKey!);
      }
    });
  }

  void _closeMetricView() {
    _setViewMode(_previousViewModeContext.viewMode);
    _cleanMetricAnnotations();
    setState(() {
      _isCameraLocked = false;
    });
    _togglePanel(true);
  }

  void _cleanMetricAnnotations() {
    _deleteMetricLines();
    annotationHelper?.deleteMetricAnnotation();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bottomOffset = _getBottomOffset();
    final bool isParksButtonVisible = (widget.isInteractiveMap &&
            _viewModeContext.viewMode != ViewMode.shuffle &&
            _viewModeContext.viewMode != ViewMode.metricDetails &&
            _viewModeContext.viewMode != ViewMode.multiFeatures &&
            _viewModeContext.viewMode != ViewMode.directions) ||
        _viewModeContext.viewMode == ViewMode.parks;
    final bool isShuffleButtonVisible = (widget.isInteractiveMap &&
        _viewModeContext.viewMode != ViewMode.shuffle &&
        _viewModeContext.viewMode != ViewMode.metricDetails &&
        _viewModeContext.viewMode != ViewMode.multiFeatures &&
        _viewModeContext.viewMode != ViewMode.directions);
    final bool isDirectionsButtonVisible =
        _viewModeContext.viewMode != ViewMode.directions &&
            _viewModeContext.viewMode != ViewMode.shuffle &&
            _viewModeContext.viewMode != ViewMode.parks &&
            _viewModeContext.viewMode != ViewMode.metricDetails &&
            _viewModeContext.viewMode != ViewMode.multiFeatures &&
            _selectedPlace != null &&
            !_isOriginChanged;

    final bool isRefreshButtonVisible =
        _viewModeContext.viewMode == ViewMode.shuffle && !_isContentLoading;

    final bool shouldShowShuffleTopBar = widget.isInteractiveMap &&
        _viewModeContext.viewMode == ViewMode.shuffle;
    final bool shouldShowMetricsTopBar =
        _viewModeContext.viewMode == ViewMode.metricDetails;
    final bool shouldShowMultiFeatureTopBar =
        _viewModeContext.viewMode == ViewMode.multiFeatures;

    final bool isPanelClosedAndNotAnimating = _panelController.isAttached &&
        _panelController.isPanelClosed &&
        !_panelController.isPanelAnimating;

    final bool isPanelCoveringScreen =
        _panelController.isAttached && _panelController.panelPosition >= 0.6;

    if (_mapInitializedCompleter.isCompleted) {
      _setMapControlSettings();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Stack(
        children: [
          SlidingUpPanel(
            panelSnapping: true,
            snapPoint: _viewModeContext.viewMode == ViewMode.parks ||
                    _viewModeContext.viewMode == ViewMode.multiFeatures
                ? 0.5
                : null,
            maxHeight: _getMaxPanelHeight(),
            minHeight: _getMinPanelHeight(),
            backdropEnabled: _isPanelBackdrop(),
            controller: _panelController,
            onPanelSlide: (double pos) {
              setState(() {
                _panelPos = pos;
              });
              if (_viewModeContext.viewMode == ViewMode.parks ||
                  _viewModeContext.viewMode == ViewMode.multiFeatures) {
                return;
              }
            },
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16.0), bottom: Radius.zero),
            panelBuilder: (scrollController) {
              return GestureDetector(
                onTap: () {
                  _togglePanel(true);
                },
                child: Container(
                  color: Colors.transparent,
                  child: widget.forceTopBottomPadding
                      ? SafeArea(
                          child: Column(
                            children: _panels(
                                isPanelClosedAndNotAnimating, scrollController),
                          ),
                        )
                      : GestureDetector(
                          child: Column(
                            children: _panels(
                                isPanelClosedAndNotAnimating, scrollController),
                          ),
                        ),
                ),
              );
            },
            body: Stack(
              children: [
                Scaffold(
                  body: MapLightWidget(
                    onMapCreated: _onMapCreated,
                    onMapTapListener: _onMapTapListener,
                    onScrollListener: _onMapScrollListener,
                    onCameraChangeListener: _onMapCameraChangeListener,
                  ),
                ),
                SafeArea(
                  child: Stack(
                    children: [
                      Positioned(
                        top: _getTopOffset(),
                        left: 0,
                        right: 0,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.zero,
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ClipRRect(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              child: Row(
                                children: <Widget>[
                                  Visibility(
                                    visible: isParksButtonVisible,
                                    child: IconButtonSmall(
                                      icon: _viewModeContext.viewMode ==
                                              ViewMode.parks
                                          ? Icons.close_rounded
                                          : Icons.forest_rounded,
                                      onTap: _toggleParksMode,
                                      text: 'Nearby Parks',
                                      backgroundColor:
                                          _viewModeContext.viewMode ==
                                                  ViewMode.parks
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Colors.white,
                                      foregroundColor:
                                          _viewModeContext.viewMode ==
                                                  ViewMode.parks
                                              ? Colors.white
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Visibility(
                                    visible: isShuffleButtonVisible,
                                    child: IconButtonSmall(
                                      icon: _viewModeContext.viewMode ==
                                              ViewMode.shuffle
                                          ? Icons.close_rounded
                                          : Icons.route_outlined,
                                      onTap: _toggleShuffleMode,
                                      text: 'Route Explorer',
                                      backgroundColor:
                                          _viewModeContext.viewMode ==
                                                  ViewMode.shuffle
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Colors.white,
                                      foregroundColor:
                                          _viewModeContext.viewMode ==
                                                  ViewMode.shuffle
                                              ? Colors.white
                                              : Colors.brown,
                                      isNew: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: (widget.forceTopBottomPadding == true)
                            ? 8
                            : kAndroidTopOffset,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            // Top bar widgets
                            Visibility(
                              maintainState: true, // Preserve Blend state.
                              visible: _shouldShowDirectionsTopBar(),
                              child: _showDirectionsTopBar(),
                            ),
                            if (shouldShowShuffleTopBar)
                              _showShuffleWidget()
                            else if (shouldShowMetricsTopBar)
                              _showMetricsTopBar()
                            else if (shouldShowMultiFeatureTopBar)
                              _showMultiFeatureTopBar()
                            else
                              const SizedBox(),
                            SizedBox(
                                height: isParksButtonVisible &&
                                        isShuffleButtonVisible
                                    ? 54
                                    : 0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Visibility(
                                  visible: _isEditingAvoidArea,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(32, 12, 0, 0),
                                    child: Row(
                                      children: [
                                        IconButtonSmall(
                                          icon: Icons.undo_rounded,
                                          onTap: _undoAvoidArea,
                                          isEnabled: _isAvoidActionUndoable,
                                        ),
                                        const SizedBox(width: 4),
                                        IconButtonSmall(
                                          icon: Icons.redo_rounded,
                                          onTap: _redoAvoidArea,
                                          isEnabled: _isAvoidActionRedoable,
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Visibility(
                                      visible: _isEditingAvoidArea,
                                      child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              16, 8, 16, 0),
                                          child: IconButtonSmall(
                                            text: 'Clear Area',
                                            icon: Icons.delete_outline,
                                            onTap: _clearAvoidArea,
                                            isEnabled:
                                                _numAvoidAnnotations != 0,
                                            foregroundColor: Colors.red,
                                          )),
                                    ),
                                    _showMapControlButtons(),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isContentLoading)
            Positioned(
              bottom: bottomOffset + kPanelFabPadding,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 200,
                  height: 70,
                  padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Theme.of(context).colorScheme.tertiary,
                      size: 50,
                    ),
                  ),
                ),
              ),
            )
          else if (_isOriginChanged && !isPanelCoveringScreen)
            Positioned(
              bottom: bottomOffset + kPanelFabPadding,
              left: 0,
              right: 0,
              child: Center(
                child: SetOriginButton(
                  onAction: _onMapOriginAction,
                ),
              ),
            )
          else if (isRefreshButtonVisible && isPanelClosedAndNotAnimating)
            Positioned(
              bottom: bottomOffset + kPanelFabPadding,
              left: 0,
              right: 0,
              child: Center(
                child: IconButtonSmall(
                  text: "Shuffle",
                  icon: Icons.shuffle,
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  onTap: () {
                    _queryForRoundTrip();
                  },
                ),
              ),
            )
          else if (isDirectionsButtonVisible)
            Positioned(
              bottom: bottomOffset + kPanelFabPadding,
              right: 16,
              child: IconButtonSmall(
                text: 'Directions',
                icon: Icons.directions,
                iconFontSize: 28.0,
                textFontSize: 17,
                onTap: _onDirectionsClicked,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
            )
          else if (_viewModeContext.viewMode == ViewMode.parks)
            Positioned(
              bottom: bottomOffset + kPanelFabPadding,
              right: 16,
              child: IconButtonSmall(
                text:
                    'Distance ${FormatHelper.formatDistance(_selectedDistanceMeters, noRemainder: true)}',
                icon: Icons.edit,
                iconFontSize: 28.0,
                textFontSize: 17,
                onTap: () async {
                  FirebaseHelper.logScreen("DistanceSelectorScreen(Features)");
                  final distanceKm = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DistanceSelectorScreen(
                        center: [
                          _currentOriginCoordinates?[0] ??
                              _userLocation!.lng.toDouble(),
                          _currentOriginCoordinates?[1] ??
                              _userLocation!.lat.toDouble()
                        ],
                        initialDistanceMeters: _selectedDistanceMeters ??
                            kDefaultFeatureDistanceMeters,
                        minDistanceKm: kMinFeatureDistanceMeters / 1000,
                        maxDistanceKm: kMaxFeatureDistanceMeters / 1000,
                        minZoom: kMinFeatureFilterCameraZoom,
                        maxZoom: kMaxFeatureFilterCameraZoom,
                      ),
                    ),
                  );

                  _onFeatureDistanceChanged(distanceKm * 1000);
                },
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.white,
              ),
            ),
          if (_selectedRoute != null &&
                  _viewModeContext.viewMode == ViewMode.directions ||
              _viewModeContext.viewMode == ViewMode.shuffle)
            Positioned(
              right: 4,
              bottom: bottomOffset - 50,
              child: PopupMenuButton(
                key: _shareWidgetKey,
                enabled: _selectedRoute?.coordinates?.length ==
                    _selectedRoute?.elevationMetrics?.length,
                icon: const Icon(Icons.ios_share),
                itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      onTap: _onExportRoute,
                      child: const Text("Export to GPX"),
                    )
                  ];
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _showMapControlButtons() {
    final List<Widget> buttons = [];
    if (!_panelController.isAttached ||
        (_getMaxPanelHeight() <
            MediaQuery.sizeOf(context).height / 2 - 2 * kOptionsPillHeight) ||
        (_getMaxPanelHeight() >=
                MediaQuery.sizeOf(context).height / 2 -
                    2 * kOptionsPillHeight &&
            _panelPos <= 0.7)) {
      buttons.addAll(
        [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TapRegion(
              onTapOutside: _onTapOutsideMapStyle,
              onTapInside: _onTapInsideMapStyle,
              child: MapStyleSelector(
                onStyleChanged: _onStyleChanged,
                hasTouchContext: _mapStyleTouchContext,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: IconButtonSmall(
              icon: Icons.navigation_rounded,
              onTap: _onGpsButtonPressed,
            ),
          ),
        ],
      );
    }

    if (_selectedRoute != null && !_isCameraLocked) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: IconButtonSmall(
            icon: Icons.crop_free_rounded,
            onTap: _onFlyToRoute,
          ),
        ),
      );
    }

    return buttons.isNotEmpty ? Column(children: buttons) : const SizedBox();
  }

  Widget _showDirectionsTopBar() {
    return AnimatedContainer(
      key: _directionsWidgetKey,
      duration: const Duration(milliseconds: 300),
      child: AnimatedCrossFade(
        duration: const Duration(milliseconds: 300),
        crossFadeState: _viewModeContext.viewMode == ViewMode.directions
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: PlaceSearchBar(
          onSelected: (place) async {
            await annotationHelper?.deletePointAnnotations();
            Future.delayed(const Duration(milliseconds: 100), () {
              _onSelectPlace(place);
            });
          },
          onSearchBarTap: _updateCameraState,
          onSelectFeatures: _setMultiFeatures,
          selectedPlace: _selectedPlace,
          showBackButton: _previousViewModeContext.viewMode == ViewMode.parks ||
              _previousViewModeContext.viewMode == ViewMode.multiFeatures,
          onBackClick: _onReturnToFeatures,
        ),
        secondChild: TapRegion(
          onTapOutside: (_) {
            _onCollapseRouteControls();
          },
          child: PickedLocationsWidget(
            onBackClicked: _onDirectionsBackClicked,
            onOptionsChanged: _onRouteSettingsChanged,
            onMapControlChanged: _onMapControlChanged,
            onEditWaypoints: _showEditDirectionsScreen,
            onClearAvoidArea: _clearAvoidArea,
            onExpand: _onExpandRouteControls,
            onCollapse: _onCollapseRouteControls,
            startingLocation: _startingLocation,
            endingLocation: _selectedPlace,
            hasTouchContext: _routeControlsTouchContext,
            avoidArea: _area,
            waypoints: const [],
            selectedMode: getTransportationModeFromString(_selectedMode),
          ),
        ),
      ),
    );
  }

  Widget _showShuffleWidget() {
    return AnimatedContainer(
      key: _topWidgetKey,
      duration: const Duration(milliseconds: 300),
      child: ShuffleTopBar(
        onBackClicked: _onDirectionsBackClicked,
        onModeChanged: (TransportationMode mode, double? distance) {
          _onRouteSettingsChanged(mode, distance, false);
        },
        selectedMode: getTransportationModeFromString(_selectedMode),
        selectedDistanceMeters: _selectedDistanceMeters,
        onDistanceChanged: _queryForRoundTrip,
        center: _currentOriginCoordinates,
      ),
    );
  }

  Widget _showMetricsTopBar() {
    return AnimatedContainer(
      key: _topWidgetKey,
      duration: const Duration(milliseconds: 300),
      child: MetricsTopBar(
        route: _selectedRoute,
        metricType: _metricType,
        metricKey: _metricKey,
        onBackClicked: _closeMetricView,
        onMetricChanged: _onMetricChanged,
        onDrawPoint: (coordinates) {
          annotationHelper?.drawSingleMetricAnnotation(
              context, mbm.Position(coordinates[0], coordinates[1]));
        },
      ),
    );
  }

  Widget _showMultiFeatureTopBar() {
    return AnimatedContainer(
      key: _topWidgetKey,
      duration: const Duration(milliseconds: 300),
      child: MultiFeatureTopBar(
        startingLocation: _startingLocation,
        selectedPlace: _selectedPlace,
        onBackClick: () {
          _setViewMode(ViewMode.search);
          setState(() {
            _previousViewModeContext =
                ViewModeContext(viewMode: ViewMode.search);
          });
        },
        onSelected: (place) async {
          await _setViewMode(ViewMode.search);
          await annotationHelper?.deletePointAnnotations();
          Future.delayed(const Duration(milliseconds: 100), () {
            _onSelectPlace(place);
          });
        },
        onSearchBarTap: _updateCameraState,
        onSelectFeatures: _setMultiFeatures,
      ),
    );
  }

  List<Widget> _panels(bool panel, ScrollController scrollController) {
    List<Widget>? panels;

    switch (_viewModeContext.viewMode) {
      case ViewMode.parks:
        panels = [
          PanelWidgets.panelGrabber(scrollController),
          FeaturesPanel(
            scrollController: scrollController,
            categoryName: 'Park',
            features: _viewModeContext.features,
            userLocation: _userLocation,
            panelPos: _panelPos,
            onSelectFeature: _onManuallySelectFeature,
            onDirectionsClick: _onFeatureDirectionsClick,
          ),
        ];
        break;
      case ViewMode.multiFeatures:
        panels = [
          PanelWidgets.panelGrabber(scrollController),
          FeaturesPanel(
            scrollController: scrollController,
            categoryName: _viewModeContext.categoryId ?? '',
            features: _viewModeContext.features,
            userLocation: _userLocation,
            panelPos: _panelPos,
            onSelectFeature: _onManuallySelectFeature,
            onDirectionsClick: _onFeatureDirectionsClick,
          ),
        ];
        break;
      default:
        if (_selectedRoute != null) {
          panels = [
            PanelWidgets.panelGrabber(scrollController),
            RouteInfoPanel(
              route: _selectedRoute,
              hideSaveRoute: !widget.isInteractiveMap,
              isPanelFullyOpen:
                  _panelController.isAttached && _panelController.isPanelOpen,
              panelHeight: _panelHeight,
              onPreviewMetric: _onPreviewMetric,
              onSetHeight: (height) {
                setState(() {
                  _panelHeight = height;
                });
              },
            ),
          ];
        } else if (_selectedPlace != null) {
          panels = [
            PanelWidgets.panelGrabber(scrollController),
            PlaceInfoPanel(
              selectedPlace: _selectedPlace,
              userLocation: _userLocation,
            ),
          ];
        }
        break;
    }

    return panels ?? [];
  }

  @override
  bool get wantKeepAlive => true;
}
