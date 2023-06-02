import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/util/format_helper.dart';

class RouteInfo extends StatefulWidget {
  const RouteInfo({Key? key, required this.route}) : super(key: key);
  final TrailblazeRoute? route;

  @override
  State<RouteInfo> createState() => _RouteInfoState();
}

class _RouteInfoState extends State<RouteInfo> {
  bool _isExpanded = false;

  List<StackedBarSeries<dynamic, String>> _getStackedBarSeries() {
    final surfaceMetrics = widget.route!.surfaceMetrics;
    final List<dynamic> dataPoints = surfaceMetrics.entries.toList();

    List<StackedBarSeries<dynamic, String>> series =
        <StackedBarSeries<dynamic, String>>[];

    for (var point in dataPoints) {
      series.add(StackedBarSeries<dynamic, String>(
        dataSource: [point],
        xValueMapper: (p, _) => "",
        yValueMapper: (p, _) => p.value,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  List<StackedBarSeries<dynamic, String>> _getStackedBarHighway() {
    final surfaceMetrics = widget.route!.highwayMetrics;
    final List<dynamic> dataPoints = surfaceMetrics.entries.toList();

    List<StackedBarSeries<dynamic, String>> series =
        <StackedBarSeries<dynamic, String>>[];

    for (var point in dataPoints) {
      series.add(StackedBarSeries<dynamic, String>(
        dataSource: [point],
        xValueMapper: (p, _) => "",
        yValueMapper: (p, _) => p.value,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16.0),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Route Info",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 0),
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
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                title: ChartTitle(text: "Surface Types"),
                primaryXAxis: CategoryAxis(),
                series: _getStackedBarSeries(),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  alignment: ChartAlignment.center,
                  shouldAlwaysShowScrollbar: true,
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                title: ChartTitle(text: "Highway Types"),
                primaryXAxis: CategoryAxis(),
                series: _getStackedBarHighway(),
                palette: const <Color>[
                  Color.fromRGBO(73, 76, 162, 1),
                  Color.fromRGBO(255, 205, 96, 1),
                  Color.fromRGBO(0, 168, 181, 1),
                  Color.fromRGBO(246, 114, 128, 1),
                  Color.fromRGBO(75, 135, 185, 1),
                  Color.fromRGBO(192, 108, 132, 1),
                  Color.fromRGBO(248, 177, 149, 1),
                  Color.fromRGBO(116, 180, 155, 1),
                  Color.fromRGBO(255, 240, 219, 1),
                  Color.fromRGBO(238, 238, 238, 1)
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  alignment: ChartAlignment.center,
                  shouldAlwaysShowScrollbar: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
