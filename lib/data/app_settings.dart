import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trailblaze/constants/settings_constants.dart';

class AppSettings {
  static bool _isMetric = true;

  static bool get isMetric => _isMetric;

  static Future<void> init(BuildContext context) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? storedUnits = await storage.read(key: kUnitsIsMetricKey);
    if (storedUnits == null) {
      if (context.mounted) {
        _inferMetricFromSystem(context);
      }
    } else {
      _isMetric = bool.parse(storedUnits);
    }
  }

  static void _inferMetricFromSystem(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Locale locale = Localizations.localeOf(context);
      _isMetric = locale.countryCode != 'US';
      writeIsMetric(_isMetric);
    });
  }

  static void setIsMetric(bool isMetric) {
    _isMetric = isMetric;
    writeIsMetric(isMetric);
  }

  static Future<void> writeIsMetric(bool isMetric) async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    await storage.write(key: kUnitsIsMetricKey, value: isMetric.toString());
  }
}
