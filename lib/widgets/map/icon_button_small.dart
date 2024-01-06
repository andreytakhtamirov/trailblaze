import 'package:flutter/material.dart';

class IconButtonSmall extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Color backgroundColor;
  final Color foregroundColor;
  final double iconFontSize;
  final double textFontSize;
  final Function() onTap;

  final kBorderRadius = 16.0;

  const IconButtonSmall({
    Key? key,
    required this.icon,
    required this.onTap,
    this.text,
    this.iconFontSize = 24.0, // Default material icon size.
    this.textFontSize = 14.0, // Default material text size.
    this.backgroundColor = Colors.white,
    this.foregroundColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return text != null ? textIconButton() : iconButton();
  }

  Widget textIconButton() {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(
          backgroundColor,
        ),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadius),
          ),
        ),
      ),
      icon: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Icon(
          icon,
          color: foregroundColor,
          size: iconFontSize,
        ),
      ),
      label: Text(
        text!,
        style: TextStyle(
          color: foregroundColor,
          fontSize: textFontSize,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget iconButton() {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: backgroundColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                icon,
                color: foregroundColor,
                size: iconFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
