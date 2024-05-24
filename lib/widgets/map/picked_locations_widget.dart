import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/util/blend_helper.dart';
import 'package:trailblaze/widgets/map/transportation_mode_widget.dart';

import '../../data/transportation_mode.dart';

class PickedLocationsWidget extends StatefulWidget {
  final MapBoxPlace? startingLocation;
  final MapBoxPlace? endingLocation;
  final List<String> waypoints;
  final TransportationMode selectedMode;
  final void Function() onBackClicked;
  final void Function(TransportationMode, num) onOptionsChanged;

  const PickedLocationsWidget(
      {super.key,
      this.startingLocation,
      this.endingLocation,
      required this.selectedMode,
      required this.waypoints,
      required this.onBackClicked,
      required this.onOptionsChanged});

  @override
  State<PickedLocationsWidget> createState() => _PickedLocationsWidgetState();
}

class _PickedLocationsWidgetState extends State<PickedLocationsWidget> {
  final BlendHelper _blendHelper = BlendHelper();

  double _selectedDistance = 0;
  double? _minDistanceBounds;
  double? _maxDistanceBounds;
  double _selectedValue = 1;

  double _minDistance = 0;
  double _maxDistance = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant PickedLocationsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startingLocation != null &&
        widget.endingLocation != null &&
        (!listEquals(widget.startingLocation?.center,
                oldWidget.startingLocation?.center) ||
            !listEquals(widget.endingLocation?.center,
                oldWidget.endingLocation?.center))) {
      _calculateControlBounds();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _blendHelper.release();
  }

  void _calculateControlBounds() async {
    final minMaxList = await _blendHelper.getMinMaxInfluences(
        widget.startingLocation, widget.endingLocation);
    _minDistance = minMaxList[0].toDouble();
    _maxDistance = minMaxList[1].toDouble();

    setState(() {
      _minDistanceBounds =
          -(math.log(_minDistance) / math.log(10)).ceilToDouble();
      _maxDistanceBounds =
          -(math.log(_maxDistance) / math.log(10)).ceilToDouble();
      _selectedValue = ((_minDistanceBounds! + _maxDistanceBounds!) / 2)
          .floorToDouble(); // Initially select the mean of the min and max.
    });
    _onSliderChanged(_selectedValue);
  }

  void _onSliderChanged(double value) {
    setState(() {
      _selectedValue = value;
      _selectedDistance = math.pow(10, value.abs()).toDouble();
    });
  }

  void _onSliderChangeEnd(value) async {
    widget.onOptionsChanged(widget.selectedMode, _selectedDistance);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: widget.selectedMode == TransportationMode.none
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 8, 48, 0),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildLocationTile(
                              title: widget.startingLocation!.placeName ??
                                  "Select origin"),
                          Visibility(
                            visible: widget.waypoints.isNotEmpty,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${widget.waypoints.length} waypoints",
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildLocationTile(
                              title: widget.endingLocation?.placeName ??
                                  widget.endingLocation?.center.toString() ??
                                  "Select destination"),
                        ],
                      ),
                    ),
                  ],
                ),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 8, 48, 4),
                      child: ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildLocationTile(
                              title: 'Starting Location',
                              subtitle: widget.startingLocation!.placeName ??
                                  "Select origin"),
                          Visibility(
                            visible: widget.waypoints.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${widget.waypoints.length} waypoints",
                                    style: const TextStyle(
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _buildLocationTile(
                              title: 'Ending Location',
                              subtitle: widget.endingLocation?.placeName ??
                                  widget.endingLocation?.center.toString() ??
                                  "Select destination"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TransportationModeWidget(
                  onSelected: (mode) =>
                      {widget.onOptionsChanged(mode, _selectedDistance)},
                  initialMode: widget.selectedMode,
                  isMinifiedView:
                      widget.selectedMode == TransportationMode.none),
              Visibility(
                visible: widget.selectedMode != TransportationMode.none,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.timer_sharp),
                          Expanded(
                              child: Slider(
                            value: _selectedValue,
                            onChanged: _onSliderChanged,
                            onChangeEnd: _onSliderChangeEnd,
                            min: _minDistanceBounds ?? 0,
                            max: _maxDistanceBounds ?? 10,
                            divisions: _minDistanceBounds == null ||
                                    _maxDistanceBounds == null
                                ? 1
                                : (_minDistanceBounds!.abs() -
                                        _maxDistanceBounds!.abs())
                                    .toInt(),
                          )),
                          const Icon(Icons.forest_outlined),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("min ${_minDistance.toStringAsExponential(0)}"),
                        Text(
                            "curr ${_selectedDistance.toStringAsExponential(0)}"),
                        Text("max ${_maxDistance.toStringAsExponential(0)}"),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              padding: const EdgeInsets.all(16),
              iconSize: 32,
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBackClicked,
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Icon(
                Icons.edit_location_alt_outlined,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile({required String title, String? subtitle}) {
    bool isDense = subtitle == null;
    return ListTile(
        dense: isDense,
        visualDensity:
            isDense ? VisualDensity.compact : VisualDensity.comfortable,
        title: Text(
          title,
          maxLines: widget.selectedMode == TransportationMode.none ? 5 : 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: !isDense ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: !isDense
            ? Padding(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
                child: Text(
                  subtitle,
                  maxLines:
                      widget.selectedMode == TransportationMode.none ? 5 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              )
            : null);
  }
}
