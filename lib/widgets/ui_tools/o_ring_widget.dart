import 'package:flutter/material.dart';

class ORing extends StatelessWidget {
  const ORing({super.key, required this.size, required this.difference});

  final double size;
  final double difference;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, difference),
      painter: ORingPainter(),
    );
  }
}

class ORingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.black26;
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()
          ..addOval(
            Rect.fromCircle(
                center: Offset(size.width / 2, size.height / 2),
                radius: (size.width - 50) / 2),
          ),
        Path()
          ..addOval(
            Rect.fromCircle(
                center: Offset(size.width / 2, size.height / 2),
                radius: size.height * (size.width - 70) / 2),
          )
          ..close(),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
