import 'package:flutter/material.dart';

class AppSettings {
  static bool _isMetric = true;

  static bool get isMetric => _isMetric;

  static void init(BuildContext context) {
    _setMetricStatus(context);
  }

  static void _setMetricStatus(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Locale locale = Localizations.localeOf(context);
      _isMetric = locale.countryCode != 'US';
    });
  }
}
