import 'package:flutter/material.dart';

class MoreButton extends StatelessWidget {
  const MoreButton({
    super.key,
    required this.label,
    required this.axisAlignment,
  });

  final String label;
  final MainAxisAlignment axisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: axisAlignment,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.keyboard_double_arrow_right,
          color: Colors.blue.shade700,
          size: 20,
        ),
      ],
    );
  }
}
