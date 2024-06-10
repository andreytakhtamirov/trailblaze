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
  final bool isEnabled;
  final bool iconBeforeText;

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
    this.isEnabled = true,
    this.iconBeforeText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return text != null ? _textIconButton(isEnabled) : _iconButton(isEnabled);
  }

  Widget _textIconButton(bool isEnabled) {
    return Stack(
      children: [
        Opacity(
          opacity: isEnabled ? 1.0 : 0.9,
          child: ElevatedButton.icon(
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
            icon: iconBeforeText ? _icon() : _label(),
            label: iconBeforeText ? _label() : _icon(),
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

  Widget _icon() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Icon(
        icon,
        color: isEnabled ? foregroundColor : foregroundColor.withOpacity(0.4),
        size: iconFontSize,
      ),
    );
  }

  Widget _label() {
    return Text(
      text!,
      style: TextStyle(
          color: isEnabled ? foregroundColor : foregroundColor.withOpacity(0.4),
          fontSize: textFontSize,
          fontWeight: FontWeight.bold),
    );
  }

  Widget _iconButton(bool isEnabled) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.9,
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
                  color: isEnabled ? foregroundColor : foregroundColor.withOpacity(0.4),
                  size: iconFontSize,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
