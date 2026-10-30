import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated procedural audio equalizer visualizer bars.
class AudioVisualizerWidget extends StatefulWidget {
  /// Creates an [AudioVisualizerWidget].
  const AudioVisualizerWidget({
    super.key,
    this.isPlaying = true,
    this.color = const Color(0xFF00E676),
    this.barCount = 4,
    this.width = 18.0,
    this.height = 16.0,
  });

  /// Whether the audio is currently playing and bars should bounce.
  final bool isPlaying;

  /// Color of the equalizer bars.
  final Color color;

  /// Number of visualizer bars.
  final int barCount;

  /// Bounding width of the visualizer.
  final double width;

  /// Bounding height of the visualizer.
  final double height;

  @override
  State<AudioVisualizerWidget> createState() => _AudioVisualizerWidgetState();
}

class _AudioVisualizerWidgetState extends State<AudioVisualizerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AudioVisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _VisualizerPainter(
              progress: _controller.value,
              isPlaying: widget.isPlaying,
              color: widget.color,
              barCount: widget.barCount,
            ),
          );
        },
      ),
    );
  }
}

class _VisualizerPainter extends CustomPainter {
  _VisualizerPainter({
    required this.progress,
    required this.isPlaying,
    required this.color,
    required this.barCount,
  });

  final double progress;
  final bool isPlaying;
  final Color color;
  final int barCount;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.fill;

    final barWidth = size.width / (barCount * 1.8);
    final gap =
        (size.width - (barWidth * barCount)) / (barCount - 1).clamp(1, 10);

    for (int i = 0; i < barCount; i++) {
      final double normalizedHeight;
      if (!isPlaying) {
        normalizedHeight = 0.25;
      } else {
        final phase = (i * 0.35) + (progress * 2 * math.pi);
        final sinVal = (math.sin(phase) + 1.0) / 2.0;
        normalizedHeight = 0.2 + (sinVal * 0.8);
      }

      final barH = size.height * normalizedHeight;
      final x = i * (barWidth + gap);
      final y = size.height - barH;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barH),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.color != color;
  }
}
