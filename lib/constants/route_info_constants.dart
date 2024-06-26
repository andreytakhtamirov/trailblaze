import 'package:flutter/material.dart';

List<Color> kChartPalette1 = const <Color>[
  Color.fromRGBO(75, 135, 185, 1),
  Color.fromRGBO(192, 108, 132, 1),
  Color.fromRGBO(246, 114, 128, 1),
  Color.fromRGBO(248, 177, 149, 1),
  Color.fromRGBO(116, 180, 155, 1),
  Color.fromRGBO(0, 168, 181, 1),
  Color.fromRGBO(73, 76, 162, 1),
  Color.fromRGBO(255, 205, 96, 1),
  Color.fromRGBO(159, 106, 217, 1.0),
  Color.fromRGBO(255, 142, 230, 1.0),
  Color.fromRGBO(248, 103, 22, 1.0),
  Color.fromRGBO(131, 225, 121, 1.0),
];

List<Color> kChartPalette2 = const <Color>[
  Color.fromRGBO(73, 76, 162, 1),
  Color.fromRGBO(255, 205, 96, 1),
  Color.fromRGBO(0, 168, 181, 1),
  Color.fromRGBO(246, 114, 128, 1),
  Color.fromRGBO(75, 135, 185, 1),
  Color.fromRGBO(192, 108, 132, 1),
  Color.fromRGBO(248, 177, 149, 1),
  Color.fromRGBO(131, 225, 121, 1.0),
  Color.fromRGBO(255, 142, 230, 1.0),
  Color.fromRGBO(116, 180, 155, 1),
  Color.fromRGBO(248, 103, 22, 1.0),
  Color.fromRGBO(159, 106, 217, 1.0),
];

enum MetricType {
  elevation('Elevation'),
  surface('Surface'),
  roadClass('Road Class');

  final String value;

  static MetricType fromValue(String value) {
    switch (value) {
      case 'Elevation':
        return MetricType.elevation;
      case 'Surface':
        return MetricType.surface;
      case 'Road Class':
        return MetricType.roadClass;
      default:
        throw ArgumentError('Unknown MetricType');
    }
  }

  const MetricType(this.value);
}

final kAllMetricTypes = [
  MetricType.elevation.value,
  MetricType.surface.value,
  MetricType.roadClass.value,
];

final kAllMetricTypeIcons = [
  Icons.show_chart,
  Icons.travel_explore,
  Icons.location_city,
];
