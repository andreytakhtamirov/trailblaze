import 'package:trailblaze/data/feature.dart';

enum ViewMode {
  search,
  directions,
  parks,
  shuffle,
  metricDetails,
  multiFeatures,
}

class ViewModeContext {
  final ViewMode viewMode;
  final String? categoryId;
  final List<Feature>? features;
  final double? panelPos;

  ViewModeContext({
    required this.viewMode,
    this.categoryId,
    this.features,
    this.panelPos,
  });
}
