import 'package:flutter/material.dart';

class IconButtonSmall extends StatelessWidget {
  final IconData icon;
  final String? text;
  final Color backgroundColor;
  final Color foregroundColor;
  final double iconFontSize;
  final double textFontSize;
  final bool isNew;
  final bool hasBorder;
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
    this.isNew = false,
    this.hasBorder = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return text != null ? textIconButton() : iconButton();
  }

  Widget textIconButton() {
    return Stack(
      children: [
        ElevatedButton.icon(
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
            side: MaterialStateProperty.resolveWith<BorderSide?>(
              (states) => hasBorder
                  ? const BorderSide(color: Colors.grey, width: 1.0)
                  : null,
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
                fontWeight: FontWeight.bold),
          ),
        ),
        if (isNew)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'New',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget iconButton() {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kBorderRadius),
          color: backgroundColor,
          border: hasBorder ? Border.all(color: Colors.grey, width: 1.0) : null,
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
