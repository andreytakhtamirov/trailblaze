import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:trailblaze/firebase_options.dart';

class FirebaseHelper {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String? packageName = packageInfo.packageName;
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'app_version', value: packageName);
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'os_name', value: Platform.operatingSystem);
    await FirebaseAnalytics.instance.setUserProperty(
        name: 'os_version', value: Platform.operatingSystemVersion);
    return logAppOpen();
  }

  static Future<void> logAppOpen() {
    return FirebaseAnalytics.instance.logAppOpen();
  }

  static Future<void> logScreen(String screenName) {
    return FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  static Future<void> logEvent(String name, Map<String, Object> params) {
    return FirebaseAnalytics.instance.logEvent(name: name, parameters: params);
  }

  static Future<void> logLogin(String method) {
    return FirebaseAnalytics.instance.logLogin(loginMethod: method);
  }

  static Future<void> resetData() {
    return FirebaseAnalytics.instance.resetAnalyticsData();
  }
}
