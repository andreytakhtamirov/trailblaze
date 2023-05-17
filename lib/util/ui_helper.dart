import 'package:flutter/material.dart';

class UiHelper {
  static showSnackBar(BuildContext context, String message,
      {int durationSeconds = 2}) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: durationSeconds),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
