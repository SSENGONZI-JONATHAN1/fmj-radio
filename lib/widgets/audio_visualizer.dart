import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Audio Visualizer Widget
/// 
/// Displays animated audio waveforms that react to music playback.
/// Supports multiple visualizer types: wave, bars, circular.
enum VisualizerType {
  wave,
  bars,
  circular,
}

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final VisualizerType visualizerType;
  final Color? color;

  const AudioVisualizer({
    Key? key,
    required this.isPlaying,
    this.visualizerType = VisualizerType.wave,
    this.color,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _barHeights;
  final int _barCount = 20;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
        if (widget.isPlaying) {
          _updateBarHeights();
        }
      });

    _barHeights = List.filled(_barCount, 0.5);
    
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
        setState(() {
          _barHeights = List.filled(_barCount, 0.1);
        });
      }
    }
  }

  void _updateBarHeights() {
    setState(() {
      for (int i = 0; i < _barCount; i++) {
        // Simulate audio levels with some randomness and smoothing
        final targetHeight = 0.1 + _random.nextDouble() * 0.9;
        _barHeights[i] = _barHeights[i] * 0.7 + targetHeight * 0.3;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visualizerColor = widget.color ?? Theme.of(context).colorScheme.primary;

    switch (widget.visualizerType) {
      case VisualizerType.wave:
        return _buildWaveVisualizer(visualizerColor);
      case VisualizerType.bars:
        return _buildBarVisualizer(visualizerColor);
      case VisualizerType.circular:
        return _buildCircularVisualizer(visualizerColor);
    }
  }

  Widget _buildWaveVisualizer(Color color) {
    return CustomPaint(
      size: Size.infinite,
      painter: _WaveVisualizerPainter(
        barHeights: _barHeights,
        color: color,
      ),
    );
  }

  Widget _buildBarVisualizer(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: _barHeights.map((height) {
        return Container(
          width: 8,
          height: 100 * height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCircularVisualizer(Color color) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: _CircularVisualizerPainter(
        barHeights: _barHeights,
        color: color,
      ),
    );
  }
}

class _WaveVisualizerPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;

  _WaveVisualizerPainter({
    required this.barHeights,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    path.moveTo(0, centerY);

    for (int i = 0; i < barHeights.length; i++) {
      final x = (i / (barHeights.length - 1)) * width;
      final y = centerY - (barHeights[i] - 0.5) * height * 0.8;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw mirror wave
    final mirrorPath = Path();
    mirrorPath.moveTo(0, centerY);

    for (int i = 0; i < barHeights.length; i++) {
      final x = (i / (barHeights.length - 1)) * width;
      final y = centerY + (barHeights[i] - 0.5) * height * 0.8;
      
      if (i == 0) {
        mirrorPath.moveTo(x, y);
      } else {
        mirrorPath.lineTo(x, y);
      }
    }

    final mirrorPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawPath(mirrorPath, mirrorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CircularVisualizerPainter extends CustomPainter {
  final List<double> barHeights;
  final Color color;

  _CircularVisualizerPainter({
    required this.barHeights,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 3;
    final barWidth = 8.0;

    for (int i = 0; i < barHeights.length; i++) {
      final angle = (i / barHeights.length) * 2 * math.pi;
      final barHeight = barHeights[i] * 50;

      final paint = Paint()
        ..color = color.withOpacity(0.6 + barHeights[i] * 0.4)
        ..strokeWidth = barWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final startX = center.dx + (radius - barHeight) * math.cos(angle);
      final startY = center.dy + (radius - barHeight) * math.sin(angle);
      final endX = center.dx + radius * math.cos(angle);
      final endY = center.dy + radius * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 20, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Random {
  final _mathRandom = math.Random();

  double nextDouble() => _mathRandom.nextDouble();
}
