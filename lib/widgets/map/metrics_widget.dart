import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
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
  Color _keyColor = Colors.black;

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
              Padding(
                padding: const EdgeInsets.fromLTRB(48, 8, 24, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: DropdownListButton(
                        choices: kAllMetricTypes,
                        selected: widget.metricType.value,
                        onChanged: (type) {
                          widget.onMetricChanged(
                              MetricType.fromValue(type ?? ''), null);
                        },
                      ),
                    ),
                    Flexible(
                      child: widget.metricType != MetricType.elevation
                          ? DropdownListButton(
                              choices: _getDropdownKeyOptions(),
                              selected: widget.metricKey,
                              onChanged: (key) {
                                if (key != null) _setKeyColor(key);
                                widget.onMetricChanged(
                                    widget.metricType, key ?? '');
                              },
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ),
              if (widget.metricType == MetricType.elevation)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Scrub on graph to see elevation along route.',
                  ),
                ),
              Visibility(
                visible:
                    widget.metricKey != null && widget.metricKey!.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 20, 48, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          color: _keyColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.metricKey}: ${_getDistanceForKey()}',
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
                child: SizedBox(
                  height: 100,
                  child: Focus(
                    autofocus: true,
                    child: _buildChart(widget.route!, widget.metricType),
                  ),
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
          onTapData: (key) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              _setKeyColor(key);
            });
            widget.onMetricChanged(metricType, key);
          },
        );

      case MetricType.roadClass:
        return ChartHelper.buildRoadClassChart(
          route,
          onTapData: (key) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              setState(() {
                _setKeyColor(key);
              });
            });
            widget.onMetricChanged(metricType, key);
          },
        );
      default:
        return const SizedBox();
    }
  }

  String _getDistanceForKey() {
    final num? distance;

    switch (widget.metricType) {
      case MetricType.surface:
        distance = widget.route!.surfaceMetrics![widget.metricKey];
        break;
      case MetricType.roadClass:
        distance = widget.route!.roadClassMetrics![widget.metricKey];
        break;
      default:
        distance = 0;
    }

    return FormatHelper.formatDistance(distance);
  }

  List<String> _getDropdownKeyOptions() {
    final List<String> list;
    switch (widget.metricType) {
      case MetricType.surface:
        list = widget.route?.surfaceMetrics?.keys.toList() ?? [];
      case MetricType.roadClass:
        list = widget.route?.roadClassMetrics?.keys.toList() ?? [];
      default:
        list = [];
    }
    return list;
  }

  void _setKeyColor(String key) {
    setState(() {
      _keyColor =
          ChartHelper.colorForMetricKey(widget.route!, widget.metricType, key);
    });
  }
}
