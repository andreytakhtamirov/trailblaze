import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trailblaze/constants/route_info_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';

class ChartHelper {
  static SfCartesianChart buildElevationChart(
      TrailblazeRoute route, TrackballBehavior trackball) {
    final metrics = route.elevationMetrics!;
    final distance = route.distance;

    num maxElevation =
        metrics.reduce((value, value2) => value > value2 ? value : value2);
    num minElevation =
        metrics.reduce((value, value2) => value < value2 ? value : value2);

    // Add padding below/above for visibility.
    minElevation -= minElevation * 0.05;
    maxElevation += maxElevation * 0.05;

    return SfCartesianChart(
      trackballBehavior: trackball,
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
      palette: kChartPalette1,
      margin: const EdgeInsets.fromLTRB(0, 0, 24, 0),
    );
  }

  static SfCartesianChart buildSurfaceChart(TrailblazeRoute route,
      {Function(String)? onTapData}) {
    final series = _buildStackedBarSurface(route);
    return _buildChart(route, series, kChartPalette1, onTapData: onTapData);
  }

  static SfCartesianChart buildRoadClassChart(TrailblazeRoute route,
      {Function(String)? onTapData}) {
    final series = _buildStackedBarRoadClass(route);
    return _buildChart(route, series, kChartPalette2, onTapData: onTapData);
  }

  static SfCartesianChart _buildChart(TrailblazeRoute route,
      List<CartesianSeries<num, String>> series, List<Color> palette,
      {Function(String)? onTapData}) {
    return SfCartesianChart(
      onLegendTapped: (args) {
        final keyName = (args.series as StackedBarSeries).name;
        if (onTapData != null) {
          onTapData(keyName ?? '');
        }
      },
      onTooltipRender: (TooltipArgs args) async {
        if (onTapData != null) {
          onTapData(args.header ?? '');
        }
      },
      tooltipBehavior: TooltipBehavior(
        activationMode: ActivationMode.singleTap,
        enable: true,
        shouldAlwaysShow: false,
      ),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}m',
        numberFormat: NumberFormat.compact(),
        maximum: route.distance.toDouble() + route.distance.toDouble() * 0.05,
      ),
      series: series,
      palette: palette,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        alignment: ChartAlignment.center,
        shouldAlwaysShowScrollbar: true,
        toggleSeriesVisibility: onTapData == null ? true : false,
      ),
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    );
  }

  static List<CartesianSeries<num, String>> _buildStackedBarSurface(
      TrailblazeRoute route) {
    final surfaceMetrics = route.surfaceMetrics!;

    List<StackedBarSeries<num, String>> series =
        <StackedBarSeries<num, String>>[];

    for (var point in surfaceMetrics.entries) {
      series.add(StackedBarSeries<num, String>(
        dataSource: [point.value],
        name: point.key,
        xValueMapper: (p, _) => '',
        yValueMapper: (p, _) => p,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  static List<CartesianSeries<num, String>> _buildStackedBarRoadClass(
      TrailblazeRoute route) {
    final surfaceMetrics = route.roadClassMetrics!;

    List<StackedBarSeries<num, String>> series =
        <StackedBarSeries<num, String>>[];

    for (var point in surfaceMetrics.entries) {
      series.add(StackedBarSeries<num, String>(
        dataSource: [point.value],
        name: point.key,
        xValueMapper: (p, _) => '',
        yValueMapper: (p, _) => p,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  static Color colorForMetricKey(
    TrailblazeRoute route,
    MetricType type,
    String key,
  ) {
    switch (type) {
      case MetricType.surface:
        final index = route.surfaceMetrics?.keys.toList().indexOf(key);
        return kChartPalette1[index ?? 0];
      case MetricType.roadClass:
        final index = route.roadClassMetrics?.keys.toList().indexOf(key);
        return kChartPalette2[index ?? 0];
      default:
        return Colors.black;
    }
  }
}
