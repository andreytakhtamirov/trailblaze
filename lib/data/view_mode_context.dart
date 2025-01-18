import 'package:trailblaze/data/feature.dart';

enum ViewMode {
  search,
  directions,
  parks,
  shuffle,
  metricDetails,
  multiFeatures,
  navigation,
}

class ViewModeContext {
  final ViewMode viewMode;
  final String? categoryId;
  final List<Feature>? features;

  ViewModeContext({
    required this.viewMode,
    this.categoryId,
    this.features,
  });
}
