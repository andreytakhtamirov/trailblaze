import 'dart:developer';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trailblaze/constants/route_info_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/requests/route_metrics.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:http/http.dart' as http;

class RouteInfoPanel extends StatefulWidget {
  const RouteInfoPanel({Key? key, required this.route}) : super(key: key);
  final TrailblazeRoute? route;

  @override
  State<RouteInfoPanel> createState() => _RouteInfoPanelState();
}

class _RouteInfoPanelState extends State<RouteInfoPanel> {
  http.Client _client = http.Client();
  bool _isFetchingMetrics = false;

  @override
  initState() {
    super.initState();
    setState(() {
      _isFetchingMetrics = false;
    });
    _fetchMetricsIfNeeded();
  }

  @override
  void didUpdateWidget(covariant RouteInfoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route?.geoJsonSource != oldWidget.route?.geoJsonSource) {
      _client.close();
      _client = http.Client();
      _fetchMetricsIfNeeded();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _client.close();
  }

  void _fetchMetricsIfNeeded() {
    if (widget.route?.surfaceMetrics == null &&
        widget.route?.elevationMetrics == null) {
      _fetchRouteMetrics();
    }
  }

  SfCartesianChart _buildElevationChart(List<Color> palette) {
    final metrics = widget.route!.elevationMetrics!;
    final distance = widget.route!.distance;

    num maxElevation =
        metrics.reduce((value, value2) => value > value2 ? value : value2);
    num minElevation =
        metrics.reduce((value, value2) => value < value2 ? value : value2);

    // Add padding below/above for visibility.
    minElevation -= minElevation * 0.01;
    maxElevation += maxElevation * 0.01;

    return SfCartesianChart(
      primaryXAxis: NumericAxis(
        minimum: 0,
        maximum: distance.toDouble(),
        labelFormat: '{value}m',
        numberFormat: NumberFormat.compact(),
      ),
      primaryYAxis: NumericAxis(
        minimum: minElevation.toDouble(),
        maximum: maxElevation.toDouble(),
        interval: (maxElevation - minElevation) / 3,
        numberFormat: NumberFormat.compact(),
        labelFormat: '{value}m',
      ),
      series: <CartesianSeries<num, num>>[
        AreaSeries<num, num>(
          dataSource: metrics,
          xValueMapper: (p, _) => distance / (metrics.length - 1) * _,
          yValueMapper: (p, _) => p,
          color: const Color.fromRGBO(8, 142, 255, 1),
        ),
      ],
      palette: palette,
      margin: const EdgeInsets.fromLTRB(0, 0, 24, 0),
    );
  }

  List<CartesianSeries<num, String>> _getStackedBarSurfaces() {
    final surfaceMetrics = widget.route!.surfaceMetrics!;

    List<StackedBarSeries<num, String>> series =
        <StackedBarSeries<num, String>>[];

    for (var point in surfaceMetrics.entries) {
      series.add(StackedBarSeries<num, String>(
        dataSource: [point.value],
        name: point.key,
        xValueMapper: (p, _) => "",
        yValueMapper: (p, _) => p,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  List<CartesianSeries<num, String>> _getStackedBarHighway() {
    final surfaceMetrics = widget.route!.highwayMetrics!;

    List<StackedBarSeries<num, String>> series =
        <StackedBarSeries<num, String>>[];

    for (var point in surfaceMetrics.entries) {
      series.add(StackedBarSeries<num, String>(
        dataSource: [point.value],
        name: point.key,
        xValueMapper: (p, _) => "",
        yValueMapper: (p, _) => p,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  SfCartesianChart _buildChart(
      List<CartesianSeries> series, List<Color> palette) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
        activationMode: ActivationMode.singleTap,
        enable: true,
      ),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}m',
        numberFormat: NumberFormat.compact(),
        maximum: widget.route!.distance.toDouble() +
            widget.route!.distance.toDouble() * 0.05,
      ),
      series: series,
      palette: palette,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        alignment: ChartAlignment.center,
        shouldAlwaysShowScrollbar: true,
      ),
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    );
  }

  ExpandableNotifier _buildExpandablePanel(
      String title, SfCartesianChart chart, bool isExpanded) {
    return ExpandableNotifier(
      initialExpanded: isExpanded,
      child: ScrollOnExpand(
        child: ExpandablePanel(
          theme: const ExpandableThemeData(
            tapHeaderToExpand: true,
            tapBodyToExpand: true,
            tapBodyToCollapse: true,
            hasIcon: true,
            iconPlacement: ExpandablePanelIconPlacement.right,
            iconColor: Colors.black,
            bodyAlignment: ExpandablePanelBodyAlignment.right,
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            alignment: Alignment.center,
            iconSize: 20,
            expandIcon: Icons.add_rounded,
            collapseIcon: Icons.close_rounded,
          ),
          header: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),
          collapsed: const SizedBox(),
          expanded: SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: chart,
            ),
          ),
        ),
      ),
    );
  }

  void _fetchRouteMetrics() async {
    setState(() {
      _isFetchingMetrics = true;
    });
    Map<String, dynamic>? metrics =
        await getRouteMetrics(_client, widget.route?.routeJson);

    // At this point this widget might be unmounted.
    if (mounted) {
      setState(() {
        _isFetchingMetrics = false;
      });
    }

    if (metrics == null) {
      log("Could not fetch metrics for route.");
      return;
    }

    // Only fetch surface metrics for now.
    List<dynamic>? elevationMetrics = metrics['elevationMetrics']['elevations'];
    Map<String, dynamic>? surfaceMetrics = metrics['surfaceMetrics'];
    if (mounted) {
      setState(() {
        widget.route?.elevationMetrics = elevationMetrics?.cast<num>();
        widget.route?.surfaceMetrics = surfaceMetrics?.cast<String, num>();
      });
    } else {
      // If the widget isn't mounted, update the metrics silently.
      widget.route?.elevationMetrics = elevationMetrics?.cast<num>();
      widget.route?.surfaceMetrics = surfaceMetrics?.cast<String, num>();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Column(
          children: [
            const Text(
              "Route Info",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Duration",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "Distance",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatHelper.formatDuration(widget.route!.duration),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        FormatHelper.formatDistance(widget.route!.distance),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            _isFetchingMetrics == false &&
                    widget.route!.elevationMetrics != null &&
                    widget.route!.surfaceMetrics != null
                ? Column(
                    children: [
                      _buildExpandablePanel(
                        "Elevation",
                        _buildElevationChart(kChartPalette1),
                        true,
                      ),
                      _buildExpandablePanel(
                        "Surface Types",
                        _buildChart(_getStackedBarSurfaces(), kChartPalette1),
                        false,
                      ),
                      // Not supported in every mode
                      widget.route!.highwayMetrics != null
                          ? _buildExpandablePanel(
                              "Highway Types",
                              _buildChart(
                                  _getStackedBarHighway(), kChartPalette2),
                              false,
                            )
                          : const SizedBox(),
                    ],
                  )
                : _isFetchingMetrics == true &&
                        widget.route!.elevationMetrics == null &&
                        widget.route!.surfaceMetrics == null
                    ? const Center(
                        child: Column(
                          children: [
                            Text("Fetching route metrics"),
                            SizedBox(
                              height: 24,
                            ),
                            CircularProgressIndicator(),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text("Could not fetch route metrics"),
                      ),
          ],
        ),
      ),
    );
  }
}
