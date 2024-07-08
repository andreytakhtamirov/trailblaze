import 'package:country_codes/country_codes.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trailblaze/constants/settings_constants.dart';

class AppSettings {
  static bool _isMetric = true;

  static bool get isMetric => _isMetric;

  static Future<void> init() async {
    FlutterSecureStorage storage = const FlutterSecureStorage();
    String? storedUnits = await storage.read(key: kUnitsIsMetricKey);
    if (storedUnits == null) {
      await _inferMetricFromSystem();
    } else {
      _isMetric = bool.parse(storedUnits);
    }
  }

  static Future<void> _inferMetricFromSystem() async {
    await CountryCodes.init();
    final countryCode = CountryCodes.getDeviceLocale()?.countryCode;
    _isMetric = countryCode != 'US';
    writeIsMetric(_isMetric);
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
