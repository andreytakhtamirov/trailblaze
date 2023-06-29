import 'dart:developer';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trailblaze/constants/route_info_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:http/http.dart' as http;

import '../requests/route_metrics.dart';

class RouteInfo extends StatefulWidget {
  const RouteInfo({Key? key, required this.route}) : super(key: key);
  final TrailblazeRoute? route;

  @override
  State<RouteInfo> createState() => _RouteInfoState();
}

class _RouteInfoState extends State<RouteInfo> {
  TrailblazeRoute? _route;
  final http.Client _client = http.Client();

  @override
  initState() {
    super.initState();

    if (widget.route?.surfaceMetrics == null) {
      _fetchRouteMetrics();
    }
  }

  @override
  void didUpdateWidget(covariant RouteInfo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _client.close();

    if (_route != widget.route && widget.route?.surfaceMetrics == null) {
      _fetchRouteMetrics();
    }

    _route = widget.route;
  }

  List<StackedBarSeries<dynamic, String>> _getStackedBarSurfaces() {
    final surfaceMetrics = widget.route!.surfaceMetrics;
    final List<dynamic> dataPoints = surfaceMetrics.entries.toList();

    List<StackedBarSeries<dynamic, String>> series =
        <StackedBarSeries<dynamic, String>>[];

    for (var point in dataPoints) {
      series.add(StackedBarSeries<dynamic, String>(
        dataSource: [point],
        name: point.key,
        xValueMapper: (p, _) => "",
        yValueMapper: (p, _) => p.value,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  List<StackedBarSeries<dynamic, String>> _getStackedBarHighway() {
    final highwayMetrics = widget.route!.highwayMetrics;
    final List<dynamic> dataPoints = highwayMetrics.entries.toList();

    List<StackedBarSeries<dynamic, String>> series =
        <StackedBarSeries<dynamic, String>>[];

    for (var point in dataPoints) {
      series.add(StackedBarSeries<dynamic, String>(
        dataSource: [point],
        name: point.key,
        xValueMapper: (p, _) => "",
        yValueMapper: (p, _) => p.value,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  SfCartesianChart _buildChart(
      List<StackedBarSeries> series, List<Color> palette) {
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
      String title, SfCartesianChart chart) {
    return ExpandableNotifier(
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
          expanded: SizedBox(height: 100, child: chart),
        ),
      ),
    );
  }

  void _fetchRouteMetrics() async {
    Map<String, dynamic>? metrics =
        await getRouteMetrics(_client, widget.route?.routeJson);

    if (metrics == null) {
      log("Could not fetch metrics for route.");
      return;
    }

    // Only fetch surface metrics for now.
    Map<String, dynamic>? surfaceMetrics = metrics['surfaceMetrics'];
    if (mounted) {
      setState(() {
        widget.route?.surfaceMetrics = surfaceMetrics;
      });
    } else {
      // If the widget isn't mounted, update the metrics silently.
      widget.route?.surfaceMetrics = surfaceMetrics;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 0,
        maxHeight: MediaQuery.of(context).size.height - 450,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Route Info",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
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
                          "Duration:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Distance:",
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
                        ),
                        Text(
                          FormatHelper.formatDistance(widget.route!.distance),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  widget.route!.surfaceMetrics != null
                      ? _buildExpandablePanel(
                          "Surface Types",
                          _buildChart(_getStackedBarSurfaces(), kChartPalette1),
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                  widget.route!.highwayMetrics != null
                      ? _buildExpandablePanel(
                          "Highway Types",
                          _buildChart(_getStackedBarHighway(), kChartPalette2),
                        )
                      : const SizedBox(),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
