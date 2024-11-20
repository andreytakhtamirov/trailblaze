import 'package:flutter/material.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';

class SetOriginButton extends StatelessWidget {
  const SetOriginButton({Key? key, required this.onAction}) : super(key: key);

  final void Function(bool isUpdate) onAction;

  ButtonStyle _getElevatedStyle(BuildContext context) {
    return ButtonStyle(
      elevation: WidgetStateProperty.all<double>(11),
      shadowColor: WidgetStateProperty.all<Color>(Colors.black),
      backgroundColor: WidgetStateProperty.all<Color>(
        Colors.blueAccent.withOpacity(0.95),
      ),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButtonSmall(
          iconFontSize: 28,
          backgroundColor: Colors.white.withOpacity(0.85),
          foregroundColor: Theme.of(context).colorScheme.primary,
          icon: Icons.close_rounded,
          onTap: () => {onAction(false)},
        ),
        const SizedBox(width: 4),
        ElevatedButton(
          onPressed: () => {onAction(true)},
          style: _getElevatedStyle(context),
          child: const SizedBox(
            height: 45,
            width: 100,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Search Here",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 42),
      ],
    );
  }
}
