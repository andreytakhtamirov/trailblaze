import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/constants/route_info_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/util/chart_helper.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/buttons/dropdown_button.dart';

class MetricsWidget extends StatefulWidget {
  final TrailblazeRoute? route;
  final MetricType metricType;
  final String? metricKey;
  final Function(MetricType metricType, String? metricKey) onMetricChanged;
  final Function() onBackClicked;
  final Function(List<num> coordinates)? onDrawPoint;

  const MetricsWidget({
    super.key,
    required this.route,
    required this.metricType,
    required this.metricKey,
    required this.onMetricChanged,
    required this.onBackClicked,
    this.onDrawPoint,
  });

  @override
  State<MetricsWidget> createState() => _MetricsWidgetState();
}

class _MetricsWidgetState extends State<MetricsWidget> {
  late List<String> _keys;
  bool _isExpanded = false;
  double? _gridItemHeight;
  double aspectRatio = kScreenWidth / 200;

  @override
  void initState() {
    super.initState();
    setState(() {
      _keys = _getKeysForType();
    });
  }

  @override
  void didUpdateWidget(covariant MetricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.metricType != oldWidget.metricType ||
        widget.route != oldWidget.route) {
      setState(() {
        _keys = _getKeysForType();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 8, 48, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: DropdownListButton(
                        choices: kAllMetricTypes,
                        icons: kAllMetricTypeIcons,
                        selected: widget.metricType.value,
                        onChanged: (type) {
                          widget.onMetricChanged(
                              MetricType.fromValue(type ?? ''), null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.metricType == MetricType.elevation)
                const Padding(
                  padding: EdgeInsets.only(left: 64, right: 48),
                  child: Text(
                    'Scrub on graph to see elevation along route.',
                  ),
                ),
              Visibility(
                visible: widget.metricType == MetricType.elevation ||
                    (widget.metricType != MetricType.elevation),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      16,
                      widget.metricType == MetricType.elevation ? 16 : 4,
                      16,
                      widget.metricType == MetricType.elevation ? 0 : 10),
                  child: SizedBox(
                    height:
                        widget.metricType == MetricType.elevation ? 100 : 40,
                    child: Container(
                        child: _buildChart(widget.route!, widget.metricType)),
                  ),
                ),
              ),
              if (widget.metricType != MetricType.elevation)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: SizedBox(
                    height: _isExpanded
                        ? ((_keys.length / 3).ceil()) *
                            (_gridItemHeight ?? 50.0)
                        : (_keys.length / 3).ceil().clamp(0, 2) *
                            (_gridItemHeight ?? 50.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _keys.length,
                      itemBuilder: (BuildContext context, int index) {
                        final key = _keys[index];
                        final percentDistance =
                            _distanceForKey(widget.metricType, key);
                        final isSelected = widget.metricKey == key;
                        final accentColor = ChartHelper.colorForMetricKey(
                            widget.route!, widget.metricType, key);
                        return LayoutBuilder(builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final width = constraints.maxWidth;
                          if (_gridItemHeight == null ||
                              _gridItemHeight != constraints.maxHeight) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                setState(() {
                                  _gridItemHeight = constraints.maxHeight;
                                });
                              }
                            });
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 3, vertical: 4),
                            child: InkWell(
                              onTap: () {
                                widget.onMetricChanged(widget.metricType, key);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? accentColor.withOpacity(0.7)
                                        : Colors.grey.withOpacity(0.3),
                                    width: 3,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 8),
                                    Container(
                                      height: 15,
                                      width: 15,
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    SizedBox(
                                      width: width - 54,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Flexible(
                                            flex: 3,
                                            child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                FormatHelper.toCapitalizedText(
                                                    key),
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Flexible(
                                              flex: 2,
                                              child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                  percentDistance,
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                      },
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        childAspectRatio: aspectRatio,
                      ),
                    ),
                  ),
                ),
              // Show "More" button if there are more than 2 rows of items.
              if (((_keys.length / 3).ceil() * (_gridItemHeight ?? 50)) >
                  (_gridItemHeight ?? 50) * 2)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.blue.shade700.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            _isExpanded ? 'Less ▲' : 'More ▼',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            child: IconButton(
              padding: const EdgeInsets.all(16),
              iconSize: 32,
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: widget.onBackClicked,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(TrailblazeRoute route, MetricType metricType) {
    switch (metricType) {
      case MetricType.elevation:
        return ChartHelper.buildElevationChart(
          route,
          TrackballBehavior(
            shouldAlwaysShow: true,
            enable: true,
            builder: (BuildContext context, TrackballDetails trackballDetails) {
              final coordinates =
                  route.coordinates![trackballDetails.pointIndex!];
              if (widget.onDrawPoint != null) {
                widget.onDrawPoint!(coordinates);
              }
              return Container(
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    textAlign: TextAlign.center,
                    FormatHelper.formatDistancePrecise(
                        route.elevationMetrics?[trackballDetails.pointIndex!]),
                  ),
                ),
              );
            },
          ),
        );
      case MetricType.surface:
        return ChartHelper.buildSurfaceChart(
          route,
          showLegend: false,
        );

      case MetricType.roadClass:
        return ChartHelper.buildRoadClassChart(
          route,
          showLegend: false,
        );
      default:
        return const SizedBox();
    }
  }

  String _distanceForKey(MetricType type, String key) {
    final num distance;

    switch (type) {
      case MetricType.surface:
        distance = widget.route!.surfaceMetrics![key] ?? 0;
        break;
      case MetricType.roadClass:
        distance = widget.route!.roadClassMetrics![key] ?? 0;
        break;
      default:
        distance = 0;
    }

    return FormatHelper.formatDistancePrecise(distance);
  }

  List<String> _getKeysForType() {
    switch (widget.metricType) {
      case MetricType.surface:
        return widget.route!.surfaceMetrics!.keys.toList(growable: false);
      case MetricType.roadClass:
        return widget.route!.roadClassMetrics!.keys.toList(growable: false);
      default:
        return [''];
    }
  }
}