import 'package:flutter/material.dart';

class SizeAnimatedIcon extends StatefulWidget {
  const SizeAnimatedIcon({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.minSize,
    required this.maxSize,
    required this.size,
    required this.duration,
    required this.curve,
  });

  final IconData icon;
  final Color iconColor;
  final double minSize;
  final double maxSize;
  final double size;
  final Duration duration;
  final Curve curve;

  @override
  State<SizeAnimatedIcon> createState() => _AnimatedIconState();
}

class _AnimatedIconState extends State<SizeAnimatedIcon>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.minSize,
    );
    _animation = Tween<double>(
      begin: widget.minSize,
      end: widget.maxSize,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.size;

    if (value == widget.minSize) {
      _controller.reverse();
    } else {
      _controller.forward();
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Icon(
          widget.icon,
          color: widget.iconColor,
          size: _animation.value,
        );
      },
    );
  }
}
