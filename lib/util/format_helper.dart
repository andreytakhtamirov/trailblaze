class FormatHelper {
  static String formatDuration(double? durationSeconds) {
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

  static String formatDistance(num? distance) {
    return "${(distance != null ? distance / 1000 : 0).toStringAsFixed(2)} km";
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
}
