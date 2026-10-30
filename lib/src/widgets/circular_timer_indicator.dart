import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Circular progress ring with an inner icon or timer countdown value.
class CircularTimerIndicator extends StatelessWidget {
  /// Creates a [CircularTimerIndicator].
  const CircularTimerIndicator({
    super.key,
    required this.progress,
    this.size = 24.0,
    this.strokeWidth = 2.5,
    this.color = const Color(0xFF00E676),
    this.backgroundColor = const Color(0x3300E676),
    this.child,
  });

  /// Progress from 0.0 (empty) to 1.0 (completed).
  final double progress;

  /// Outer diameter of the circular ring.
  final double size;

  /// Width of the circular stroke.
  final double strokeWidth;

  /// Color of the active ring stroke.
  final Color color;

  /// Color of the background ring track.
  final Color backgroundColor;

  /// Optional center widget (e.g., small icon or text).
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              color: color,
              backgroundColor: backgroundColor,
            ),
          ),
          if (child != null) Center(child: child),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
