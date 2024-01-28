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

  static Future<bool?> showConfirmationDialog(
    BuildContext context,
    String title,
    String content,
    String positiveAction,
    String negativeAction,
    Color positiveColor,
    Color negativeColor,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          alignment: Alignment.center,
          actions: <Widget>[
            MaterialButton(
              color: negativeColor,
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                negativeAction,
                style: TextStyle(
                    // Since we expose options for button colours, we must
                    //  automatically adjust the font colour to be visible
                    //  against any background colour.
                    color: textColorForBackgroundColor(negativeColor)),
              ),
            ),
            MaterialButton(
              color: positiveColor,
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                positiveAction,
                style: TextStyle(
                    color: textColorForBackgroundColor(positiveColor)),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<String?> showStringInputDialog(
    BuildContext context,
    String title,
    String prompt,
  ) async {
    TextEditingController controller = TextEditingController();
    String? errorMessage;

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text(title),
              content: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: prompt,
                  errorText: errorMessage,
                ),
              ),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              alignment: Alignment.center,
              actions: <Widget>[
                MaterialButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                MaterialButton(
                  color: const Color(0xFF7FBE76),
                  onPressed: () {
                    String userInput = controller.text;

                    if (userInput.trim().isEmpty) {
                      setState(() {
                        errorMessage = 'Route name must not be empty.';
                      });
                      return;
                    }

                    setState(() {
                      errorMessage = null;
                    });

                    Navigator.of(context).pop(userInput);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Color textColorForBackgroundColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
