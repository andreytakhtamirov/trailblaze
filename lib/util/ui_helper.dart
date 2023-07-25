import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UiHelper {
  static showSnackBar(BuildContext context, String message,
      {int durationSeconds = 2}) {
    SnackBar snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: durationSeconds),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static showAlertDialog(BuildContext context, String message) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text('OK'),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        message,
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  static openUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      log('Could not launch $uri');
    }
  }
}
