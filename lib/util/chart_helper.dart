import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trailblaze/constants/route_info_constants.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/util/format_helper.dart';

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
    minElevation -= minElevation * 0.01;
    maxElevation += maxElevation * 0.01;

    return SfCartesianChart(
      trackballBehavior: trackball,
      primaryXAxis: NumericAxis(
          minimum: 0,
          maximum: distance.toDouble(),
          axisLabelFormatter: (axisLabelRenderArgs) {
            final d = axisLabelRenderArgs.value;
            return ChartAxisLabel(
                FormatHelper.formatDistancePrecise(d, noRemainder: true),
                const TextStyle());
          }),
      primaryYAxis: NumericAxis(
          minimum: minElevation.toDouble(),
          maximum: maxElevation.toDouble(),
          interval: (maxElevation - minElevation) / 3,
          axisLabelFormatter: (axisLabelRenderArgs) {
            final d = axisLabelRenderArgs.value;
            return ChartAxisLabel(
                FormatHelper.formatElevationDistance(d, noRemainder: true),
                const TextStyle());
          }),
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
      {bool showLegend = true}) {
    final series = _buildStackedBarSurface(route);
    return _buildChart(route, series, kChartPalette1, showLegend: showLegend);
  }

  static SfCartesianChart buildRoadClassChart(TrailblazeRoute route,
      {bool showLegend = true}) {
    final series = _buildStackedBarRoadClass(route);
    return _buildChart(route, series, kChartPalette2, showLegend: showLegend);
  }

  static SfCartesianChart _buildChart(TrailblazeRoute route,
      List<CartesianSeries<num, String>> series, List<Color> palette,
      {bool showLegend = true}) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
        builder: (data, point, s, pointIndex, seriesIndex) {
          return Container(
            width: 150,
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 15,
                  width: 15,
                  decoration: BoxDecoration(
                    color: palette[seriesIndex],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  children: [
                    Expanded(
                      child: AutoSizeText(
                        FormatHelper.toCapitalizedText(
                            series[seriesIndex].name ?? ''),
                        minFontSize: 12,
                        maxFontSize: 12,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Expanded(
                      child: AutoSizeText(
                        minFontSize: 12,
                        maxFontSize: 12,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        FormatHelper.formatDistancePrecise(data),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        elevation: 100,
        activationMode: ActivationMode.singleTap,
        enable: true,
        shouldAlwaysShow: false,
      ),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        isVisible: showLegend,
        labelFormat: '{value}m',
        numberFormat: NumberFormat.compact(),
        maximum: route.distance.toDouble() + route.distance.toDouble() * 0.05,
      ),
      series: series,
      palette: palette,
      legend: Legend(
        isVisible: showLegend,
        position: LegendPosition.bottom,
        alignment: ChartAlignment.center,
        shouldAlwaysShowScrollbar: true,
        toggleSeriesVisibility: true,
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
        return kChartPalette1.length > index! && index != -1
            ? kChartPalette1[index]
            : Colors.black;
      case MetricType.roadClass:
        final index = route.roadClassMetrics?.keys.toList().indexOf(key);
        return kChartPalette2.length > index! && index != -1
            ? kChartPalette2[index]
            : Colors.black;
      default:
        return Colors.black;
    }
  }

  static Widget trackballBuilder(BuildContext context, num? distance) {
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
          FormatHelper.formatElevationDistance(distance),
        ),
      ),
    );
  }
}
