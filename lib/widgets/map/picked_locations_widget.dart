import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/util/blend_helper.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';
import 'package:trailblaze/widgets/map/transportation_mode_small_widget.dart';
import 'package:trailblaze/widgets/map/transportation_mode_widget.dart';
import 'package:trailblaze/widgets/ui_tools/triple_cross_fade.dart';

import '../../data/transportation_mode.dart';

class PickedLocationsWidget extends StatefulWidget {
  final MapBoxPlace? startingLocation;
  final MapBoxPlace? endingLocation;
  final List<String> waypoints;
  final TransportationMode selectedMode;
  final bool hasTouchContext;
  final num avoidArea;
  final void Function() onEditWaypoints;
  final void Function() onClearAvoidArea;
  final void Function() onExpand;
  final void Function() onCollapse;
  final void Function() onBackClicked;
  final void Function(TransportationMode, num, bool isSilent) onOptionsChanged;
  final void Function(bool) onMapControlChanged;

  const PickedLocationsWidget({
    super.key,
    this.startingLocation,
    this.endingLocation,
    required this.selectedMode,
    required this.waypoints,
    required this.hasTouchContext,
    required this.avoidArea,
    required this.onEditWaypoints,
    required this.onClearAvoidArea,
    required this.onExpand,
    required this.onCollapse,
    required this.onBackClicked,
    required this.onOptionsChanged,
    required this.onMapControlChanged,
  });

  @override
  State<PickedLocationsWidget> createState() => _PickedLocationsWidgetState();
}

class _PickedLocationsWidgetState extends State<PickedLocationsWidget> {
  final BlendHelper _blendHelper = BlendHelper();
  bool _isEditingAvoidArea = false;

  double _selectedDistance = 0;
  double? _minDistanceBounds;
  double? _maxDistanceBounds;
  double _selectedValue = 1;

  double _minDistance = 0;
  double _maxDistance = 0;

  @override
  void initState() {
    super.initState();
    if (widget.startingLocation != null && widget.endingLocation != null) {
      _calculateControlBounds();
    }
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

    if (!mounted) {
      return;
    }

    setState(() {
      _minDistanceBounds =
          -(math.log(_minDistance) / math.log(10)).ceilToDouble();
      _maxDistanceBounds =
          -(math.log(_maxDistance) / math.log(10)).ceilToDouble();
      _selectedValue = ((_minDistanceBounds! + _maxDistanceBounds!) / 2)
          .floorToDouble(); // Initially select the mean of the min and max.
    });
    _onSliderChanged(_selectedValue);
    _onSliderChangeEnd(_selectedValue, isSilentUpdate: true);
  }

  void _onSliderChanged(double value) {
    setState(() {
      _selectedValue = value;
      _selectedDistance = math.pow(10, value.abs()).toDouble();
    });
  }

  void _onSliderChangeEnd(double value, {bool isSilentUpdate = false}) async {
    widget.onOptionsChanged(
        widget.selectedMode, _selectedDistance, isSilentUpdate);
  }

  int _determineCurrentState() {
    if (_isEditingAvoidArea) {
      return 2;
    } else if (widget.selectedMode == TransportationMode.none ||
        widget.hasTouchContext) {
      return 1;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.hasTouchContext) {
          widget.onCollapse();
        } else {
          widget.onExpand();
        }
      },
      child: Stack(
        children: [
          Visibility(
            visible: !_isEditingAvoidArea,
            child: Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 200,
                        height: 27,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(62.0),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -8,
                        right: 0,
                        left: 0,
                        child: Icon(
                          !widget.hasTouchContext
                              ? Icons.arrow_drop_down
                              : Icons.arrow_drop_up,
                          size: 44,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin:
                EdgeInsets.fromLTRB(16, 0, 16, !_isEditingAvoidArea ? 22 : 0),
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
                    TripleCrossFade(
                      duration: const Duration(milliseconds: 300),
                      currentState: _determineCurrentState(),
                      firstChild: _collapsedView(),
                      secondChild: _expandedView(),
                      thirdChild: _editingView(),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                Visibility(
                  visible: _determineCurrentState() != 2,
                  child: Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      padding: const EdgeInsets.all(16),
                      iconSize: 32,
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: widget.onBackClicked,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile({required String title}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        title,
        maxLines: widget.hasTouchContext ? 3 : 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  Widget _collapsedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 8, 16, 0),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildLocationTile(
                  title: widget.startingLocation!.placeName ?? "Select origin"),
              const SizedBox(height: 8),
              _buildLocationTile(
                  title: widget.endingLocation?.placeName ??
                      widget.endingLocation?.center.toString() ??
                      "Select destination"),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: _slider(),
              ),
              const SizedBox(width: 16),
              TransportationModeSmallWidget(
                selectedMode: widget.selectedMode,
              ),
            ],
          ),
        ),
        Visibility(
          visible: widget.avoidArea > 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _avoidingAreaText(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withAlpha(220),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _expandedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(60, 16, 32, 0),
          child: GestureDetector(
            onTap: widget.onEditWaypoints,
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildLocationTile(
                      title: widget.startingLocation!.placeName ??
                          "Select origin"),
                  const SizedBox(height: 8),
                  Divider(
                    height: 4,
                    thickness: 1,
                    indent: 16,
                    endIndent: 10,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  // TODO waypoints
                  _buildLocationTile(
                      title: widget.endingLocation?.placeName ??
                          widget.endingLocation?.center.toString() ??
                          "Select destination"),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: Column(
            children: [
              _showIgnoreArea(),
              _showBlendSlider(showTitle: true),
              TransportationModeWidget(
                  onSelected: (mode) =>
                      {widget.onOptionsChanged(mode, _selectedDistance, false)},
                  initialMode: widget.selectedMode,
                  isMinifiedView:
                      widget.selectedMode == TransportationMode.none),
            ],
          ),
        ),
      ],
    );
  }

  Widget _editingView() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, right: 24, left: 24),
      child: Column(
        children: [
          const Text(
            'Click to create/delete a point.\n\nAdd at least 3 points to create an area to avoid.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          _showIgnoreArea(),
        ],
      ),
    );
  }

  Widget _showBlendSlider({bool showTitle = false}) {
    return Visibility(
      visible: widget.selectedMode != TransportationMode.none,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: showTitle,
              child: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Route Directness',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _slider(),
            ),
            // For debugging bounds (Blend)
            // Visibility(
            //   visible: showTitle,
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     mainAxisAlignment: MainAxisAlignment.spaceAround,
            //     children: [
            //       Text("min ${_minDistance.toStringAsExponential(0)}"),
            //       Text("curr ${_selectedDistance.toStringAsExponential(0)}"),
            //       Text("max ${_maxDistance.toStringAsExponential(0)}"),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _slider() {
    return Row(
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
            divisions: _minDistanceBounds == null || _maxDistanceBounds == null
                ? 1
                : (_minDistanceBounds!.abs() - _maxDistanceBounds!.abs())
                    .toInt(),
          ),
        ),
        const Icon(Icons.forest_outlined),
      ],
    );
  }

  String _actionButtonLabel() {
    if (!_isEditingAvoidArea && widget.avoidArea == 0) {
      return 'Set Area to Avoid';
    } else if (_isEditingAvoidArea) {
      return 'Done';
    } else {
      return _avoidingAreaText();
    }
  }

  String _avoidingAreaText() {
    return 'Avoiding ${FormatHelper.formatSquareDistance(widget.avoidArea)}';
  }

  Widget _showIgnoreArea() {
    return Visibility(
      visible: widget.selectedMode != TransportationMode.none,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisAlignment: !_isEditingAvoidArea
              ? MainAxisAlignment.end
              : MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: IconButtonSmall(
                icon: !_isEditingAvoidArea
                    ? widget.avoidArea == 0
                        ? Icons.block
                        : Icons.edit
                    : Icons.check,
                text: _actionButtonLabel(),
                foregroundColor:
                    !_isEditingAvoidArea ? Colors.black : Colors.white,
                backgroundColor: !_isEditingAvoidArea
                    ? Colors.white
                    : Theme.of(context).colorScheme.tertiary,
                onTap: () => {
                  setState(() {
                    _isEditingAvoidArea = !_isEditingAvoidArea;
                  }),
                  widget.onMapControlChanged(_isEditingAvoidArea),
                },
                iconBeforeText: widget.avoidArea == 0 ? true : false,
                iconFontSize: widget.avoidArea == 0 ? 24 : 18,
                hasBorder: true,
              ),
            ),
            widget.avoidArea != 0 && !_isEditingAvoidArea
                ? Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: IconButtonSmall(
                    icon: Icons.delete,
                    foregroundColor: Colors.redAccent,
                    backgroundColor: Colors.white,
                    onTap: () => {
                      widget.onClearAvoidArea(),
                      widget.onMapControlChanged(false),
                    },
                    hasBorder: true,
                  ),
                )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
