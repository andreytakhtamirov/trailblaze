import 'package:flutter/material.dart';

class TripleCrossFade extends StatelessWidget {
  final Widget firstChild;
  final Widget secondChild;
  final Widget thirdChild;
  final int currentState;
  final Duration duration;
  final Curve curve;

  const TripleCrossFade({
    super.key,
    required this.firstChild,
    required this.secondChild,
    required this.thirdChild,
    required this.currentState,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.linear,
  });

  @override
  Widget build(BuildContext context) {
    Widget currentChild;
    switch (currentState) {
      case 0:
        currentChild = firstChild;
        break;
      case 1:
        currentChild = secondChild;
        break;
      case 2:
      default:
        currentChild = thirdChild;
        break;
    }

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: currentChild,
    );
  }
}
