import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../themes/jfm_themes.dart';

/// Premium Audio Visualizer
/// 
/// Custom audio visualization with multiple styles:
/// - Wave bars
/// - Circular waves
/// - Particles
class PremiumAudioVisualizer extends StatefulWidget {
  final JfmThemeData theme;
  final VisualizerStyle style;

  const PremiumAudioVisualizer({
    Key? key,
    required this.theme,
    this.style = VisualizerStyle.waveBars,
  }) : super(key: key);

  @override
  State<PremiumAudioVisualizer> createState() => _PremiumAudioVisualizerState();
}

class _PremiumAudioVisualizerState extends State<PremiumAudioVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (widget.style) {
          case VisualizerStyle.waveBars:
            return _buildWaveBars();
          case VisualizerStyle.circular:
            return _buildCircular();
          case VisualizerStyle.particles:
            return _buildParticles();
        }
      },
    );
  }

  Widget _buildWaveBars() {
    final barCount = 20;
    final bars = List.generate(barCount, (index) {
      final delay = index / barCount;
      final animation = Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            delay * 0.5,
            delay * 0.5 + 0.5,
            curve: Curves.easeInOut,
          ),
        ),
      );

      final height = 20 + (animation.value * 40 * math.sin(index * 0.5 + _controller.value * math.pi * 2));
      
      return Container(
        width: 6,
        height: height,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              widget.theme.accent.withOpacity(0.3),
              widget.theme.accent,
              widget.theme.primary,
            ],
          ),
          borderRadius: BorderRadius.circular(3),
          boxShadow: [
            BoxShadow(
              color: widget.theme.glowColor.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: bars,
    );
  }

  Widget _buildCircular() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(3, (index) {
        final delay = index * 0.3;
        final animation = Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              delay,
              delay + 0.7,
              curve: Curves.easeInOut,
            ),
          ),
        );

        return Container(
          width: 60 + (index * 30 * animation.value),
          height: 60 + (index * 30 * animation.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.theme.accent.withOpacity(
                0.3 - (index * 0.1) * animation.value,
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.theme.glowColor.withOpacity(
                  0.2 * animation.value,
                ),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildParticles() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(12, (index) {
        final angle = (index / 12) * 2 * math.pi;
        final delay = index / 12;
        final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              delay,
              delay + 0.5,
              curve: Curves.easeOut,
            ),
          ),
        );

        final distance = 30 + (20 * animation.value);
        final x = math.cos(angle) * distance;
        final y = math.sin(angle) * distance;

        return Transform.translate(
          offset: Offset(x, y),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.theme.accent.withOpacity(
                1.0 - animation.value * 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.theme.glowColor.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

enum VisualizerStyle {
  waveBars,
  circular,
  particles,
}
