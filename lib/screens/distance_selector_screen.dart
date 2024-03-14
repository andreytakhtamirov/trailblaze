import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/widgets/ui_tools/o_ring_widget.dart';

class DistanceSelectorScreen extends StatefulWidget {
  const DistanceSelectorScreen({
    Key? key,
    required this.initialDistanceMeters,
    this.center,
    required this.minDistanceKm,
    required this.maxDistanceKm,
    required this.minZoom,
    required this.maxZoom,
  }) : super(key: key);

  final List<double>? center;
  final double initialDistanceMeters;
  final double minDistanceKm;
  final double maxDistanceKm;
  final double minZoom;
  final double maxZoom;

  @override
  State<DistanceSelectorScreen> createState() => _DistanceSelectorScreenState();
}

class _DistanceSelectorScreenState extends State<DistanceSelectorScreen> {
  late MapboxMap _mapboxMap;
  double _selectedDistanceKm = 0;
  double _dragAmount = 0;

  final double kMinDragAmount = 150;
  final double kSliderPadding = 70;

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedDistanceKm = widget.initialDistanceMeters / 1000;
    });
  }

  _onMapCreated(MapboxMap mapboxMap) async {
    setState(() {
      _mapboxMap = mapboxMap;
    });

    _setMapControlSettings();

    if (widget.center != null) {
      await _mapboxMap.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(
              widget.center![0],
              widget.center![1],
            ),
          ).toJson(),
          zoom: kDefaultCameraState.zoom,
          bearing: kDefaultCameraState.bearing,
          pitch: kDefaultCameraState.pitch,
        ),
      );
    }

    _setInitialValues();
  }

  void _setMapControlSettings() async {
    final CompassSettings kCompassSettings = CompassSettings(
      position: OrnamentPosition.TOP_LEFT,
      marginLeft: 1000,
    );

    final ScaleBarSettings kScaleBarSettings = ScaleBarSettings(
      position: OrnamentPosition.TOP_LEFT,
      marginLeft: 1000,
    );

    final AttributionSettings kAttributionSettings = AttributionSettings(
      position: OrnamentPosition.TOP_LEFT,
      marginLeft: 1000,
    );

    final LogoSettings kLogoSettings = LogoSettings(
      position: OrnamentPosition.TOP_LEFT,
      marginLeft: 1000,
    );

    final GesturesSettings kGesturesSettings = GesturesSettings(
      rotateEnabled: false,
      pinchToZoomEnabled: false,
      scrollEnabled: false,
      simultaneousRotateAndPinchToZoomEnabled: false,
      pitchEnabled: false,
      doubleTapToZoomInEnabled: false,
      doubleTouchToZoomOutEnabled: false,
      quickZoomEnabled: false,
      pinchToZoomDecelerationEnabled: false,
      rotateDecelerationEnabled: false,
      scrollDecelerationEnabled: false,
      increaseRotateThresholdWhenPinchingToZoom: false,
      increasePinchToZoomThresholdWhenRotating: false,
      pinchPanEnabled: false,
    );

    _mapboxMap.compass.updateSettings(kCompassSettings);
    _mapboxMap.scaleBar.updateSettings(kScaleBarSettings);
    _mapboxMap.attribution.updateSettings(kAttributionSettings);
    _mapboxMap.logo.updateSettings(kLogoSettings);
    _mapboxMap.gestures.updateSettings(kGesturesSettings);
  }

  void _setInitialValues() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final size = MediaQuery.of(context).size.width;
      setState(() {
        _dragAmount = calculateDragAmount(_selectedDistanceKm, size);
      });

      await _updateCamera(MediaQuery.of(context).size.width);
    });
  }

  double calculateSelectedDistance(double dragAmount, double size) {
    double maxDragAmount = size - kMinDragAmount - kSliderPadding;
    return widget.minDistanceKm +
        (dragAmount - kMinDragAmount) /
            (maxDragAmount) *
            (widget.maxDistanceKm - widget.minDistanceKm);
  }

  double calculateDragAmount(double selectedDistance, double size) {
    double maxDragAmount = size - kMinDragAmount - kSliderPadding;
    return (selectedDistance - widget.minDistanceKm) *
            (maxDragAmount) /
            (widget.maxDistanceKm - widget.minDistanceKm) +
        kMinDragAmount;
  }

  double _zoomForDistance(double max, double distance) {
    return lerpDouble(widget.minZoom,
        widget.maxZoom, (_dragAmount) / (max))!;
  }

  Future<void> _updateCamera(double max) {
    return _mapboxMap.flyTo(
      CameraOptions(
        center: Point(
          coordinates: Position(
            widget.center![0],
            widget.center![1],
          ),
        ).toJson(),
        zoom: _zoomForDistance(max, _dragAmount),
        bearing: kDefaultCameraState.bearing,
        pitch: kDefaultCameraState.pitch,
      ),
      MapAnimationOptions(duration: 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Distance'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.question_mark_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            double size = constraints.maxWidth < constraints.maxHeight
                ? constraints.maxWidth
                : constraints.maxHeight;
            return Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(36.0),
                  child: Text(
                    "Choose a distance for your journey",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(1000),
                        // Adjust the radius as needed
                        child: Stack(
                          children: [
                            MapWidget(
                              onMapCreated: _onMapCreated,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ClipOval(
                    child: Container(
                      height: _dragAmount,
                      width: _dragAmount,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 3,
                          color: Colors.white,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0),
                            offset: Offset.zero,
                            blurRadius: 10,
                            blurStyle: BlurStyle.inner,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ORing(
                    size: size,
                    difference: _dragAmount / (size - kSliderPadding),
                  ),
                ),
                Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(
                          width: 0.1,
                          color: Theme.of(context).colorScheme.primary),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _selectedDistanceKm.toStringAsFixed(0),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "km",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(left: _dragAmount),
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        setState(() {
                          final sum = _dragAmount + details.delta.dx * 1.5;
                          _dragAmount =
                              sum.clamp(kMinDragAmount, size - kSliderPadding);
                          _selectedDistanceKm =
                              calculateSelectedDistance(_dragAmount, size);
                        });

                        _updateCamera(size);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              width: 0.1,
                              color: Theme.of(context).colorScheme.primary),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              offset: const Offset(0, 3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back_ios_new),
                              Icon(Icons.arrow_forward_ios_rounded)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MaterialButton(
                          color: Theme.of(context).colorScheme.primary,
                          onPressed: () {
                            Navigator.of(context)
                                .pop(_selectedDistanceKm.floorToDouble());
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 36,
                              vertical: 8,
                            ),
                            child: Text(
                              "Let's Go!",
                              style: TextStyle(
                                fontSize: 30,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
