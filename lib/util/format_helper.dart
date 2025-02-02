import 'dart:math';

import 'package:trailblaze/data/app_settings.dart';
import 'package:units_converter/units_converter.dart';

class FormatHelper {
  static String formatDuration(num? durationSeconds) {
    if (durationSeconds == null) {
      return "NaN";
    }

    int durationSecondsInt = durationSeconds.toInt();
    int hours = durationSecondsInt ~/ 3600;
    int minutes = (durationSecondsInt % 3600) ~/ 60;
    int seconds = durationSecondsInt % 60;

    String formattedDuration;
    if (hours > 0) {
      formattedDuration =
          "$hours hours ${minutes.toString().padLeft(2, '0')} minutes";
    } else if (minutes > 0) {
      formattedDuration = "$minutes minutes";
    } else {
      formattedDuration = "$seconds seconds";
    }

    return formattedDuration;
  }

  static String formatDistance(num? distanceMeters,
      {bool noRemainder = false}) {
    if (AppSettings.isMetric) {
      return _formatDistanceMetric(distanceMeters, noRemainder: noRemainder);
    } else {
      return _formatDistanceImperial(distanceMeters, noRemainder: noRemainder);
    }
  }

  static String formatDistancePrecise(num? distanceMeters,
      {bool noRemainder = false}) {
    if (AppSettings.isMetric) {
      return _formatDistancePreciseMetric(distanceMeters,
          noRemainder: noRemainder);
    } else {
      return _formatDistancePreciseImperial(distanceMeters,
          noRemainder: noRemainder);
    }
  }

  static String _formatDistanceMetric(num? distanceMeters,
      {bool noRemainder = false}) {
    return "${(distanceMeters != null ? distanceMeters / 1000 : 0).toStringAsFixed(!noRemainder ? 2 : 0)} km";
  }

  static String _formatDistancePreciseMetric(num? distanceMeters,
      {bool noRemainder = false}) {
    if (distanceMeters == null || distanceMeters == 0) {
      return "0 m";
    }

    if (distanceMeters < 1000) {
      return "${distanceMeters.toStringAsFixed(0)} m";
    } else {
      return "${(distanceMeters / 1000).toStringAsFixed(!noRemainder ? 2 : 0)} km";
    }
  }

  static String _formatDistanceImperial(num? distanceMeters,
      {bool noRemainder = false}) {
    final distanceMiles =
        distanceMeters?.convertFromTo(LENGTH.meters, LENGTH.miles);

    return "${(distanceMiles ?? 0).toStringAsFixed(!noRemainder ? 2 : 0)} mi";
  }

  static String _formatDistancePreciseImperial(num? distanceMeters,
      {bool noRemainder = false}) {
    if (distanceMeters == null || distanceMeters == 0) {
      return "0 ft";
    }

    final distanceFeet =
        distanceMeters.convertFromTo(LENGTH.meters, LENGTH.feet) ?? 0;

    if (distanceFeet < 500) {
      return "${distanceFeet.toStringAsFixed(0)} ft";
    } else {
      return "${(distanceFeet.convertFromTo(LENGTH.feet, LENGTH.miles))!.toStringAsFixed(!noRemainder ? 2 : 0)} mi";
    }
  }

  static String formatSpeed(num? speedMetersPerSecond,
      {bool noRemainder = false}) {
    if (AppSettings.isMetric) {
      return "${_formatSpeedMetric(speedMetersPerSecond, noRemainder: noRemainder)}\nkm/h";
    } else {
      return "${_formatSpeedImperial(speedMetersPerSecond,
          noRemainder: noRemainder)}\nmph";
    }
  }

  static String _formatSpeedMetric(num? speedMetersPerSecond,
      {bool noRemainder = false}) {
    if (speedMetersPerSecond == null) return '0';

    num speedKph = speedMetersPerSecond * 3.6;

    if (noRemainder) {
      return speedKph.toStringAsFixed(0);
    } else {
      return speedKph.toStringAsFixed(2);
    }
  }

  static String _formatSpeedImperial(num? speedMetersPerSecond,
      {bool noRemainder = false}) {
    if (speedMetersPerSecond == null) return '0';

    num speedMph = speedMetersPerSecond * 2.23694;

    if (noRemainder) {
      return speedMph.toStringAsFixed(0);
    } else {
      return speedMph.toStringAsFixed(2);
    }
  }

  static String formatElevationDistance(num? distanceMeters,
      {bool noRemainder = false}) {
    if (AppSettings.isMetric) {
      if (distanceMeters == null || distanceMeters == 0) {
        return "0 m";
      }
      return "${distanceMeters.toStringAsFixed(0)} m";
    } else {
      if (distanceMeters == null || distanceMeters == 0) {
        return "0 ft";
      }
      final distanceFeet =
          distanceMeters.convertFromTo(LENGTH.meters, LENGTH.feet) ?? 0;
      return "${distanceFeet.toStringAsFixed(0)} ft";
    }
  }

  static String formatSquareDistance(num? distanceMeters,
      {bool noRemainder = false}) {
    if (AppSettings.isMetric) {
      return _formatSquareDistanceMetric(distanceMeters,
          noRemainder: noRemainder);
    } else {
      return _formatSquareDistanceImperial(distanceMeters,
          noRemainder: noRemainder);
    }
  }

  static String _formatSquareDistanceMetric(num? distanceMeters,
      {bool noRemainder = false}) {
    return "${(distanceMeters != null ? distanceMeters / 1e6 : 0).toStringAsFixed(!noRemainder ? 2 : 0)} km\u00B2";
  }

  static String _formatSquareDistanceImperial(num? distanceMeters,
      {bool noRemainder = false}) {
    if (distanceMeters == null || distanceMeters <= 0) {
      return "0 mi\u00B2";
    }

    final sideMiles =
        sqrt(distanceMeters).convertFromTo(LENGTH.meters, LENGTH.miles) ?? 0;
    final distanceMiles = pow(sideMiles, 2);

    return "${(distanceMiles).toStringAsFixed(!noRemainder ? 2 : 0)} mi\u00B2";
  }

  static String formatLikesCount(int likes) {
    if (likes >= 1000000) {
      return "${(likes / 1000000).toStringAsFixed(1)}M";
    } else if (likes >= 1000) {
      return "${(likes / 1000).toStringAsFixed(1)}k";
    } else {
      return "$likes";
    }
  }

  static String toCapitalizedText(String s) {
    List<String> words = s.split('_');
    String capitalizedText = '';

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        String capitalizedWord = '${word[0].toUpperCase()}${word.substring(1)}';
        capitalizedText += capitalizedWord;
        if (i < words.length - 1) {
          capitalizedText += ' ';
        }
      }
    }

    return capitalizedText;
  }
}
