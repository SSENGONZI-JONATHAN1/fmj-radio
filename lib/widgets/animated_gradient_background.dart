import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated gradient background for professional radio app UI
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  
  const AnimatedGradientBackground({
    Key? key,
    required this.child,
    this.colors,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  
  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    
    _controller2 = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Detect system theme mode
    final isDarkMode = MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    // Light mode colors - clean white/light theme
    final lightModeColors = [
      const Color(0xFFF8F9FA),  // Light gray-white
      const Color(0xFFE9ECEF),  // Soft gray
      const Color(0xFFDEE2E6),  // Light blue-gray
      const Color(0xFFADB5BD),  // Medium gray
    ];
    
    // Dark mode colors - existing dark gradient
    final darkModeColors = [
      const Color(0xFF1a1a2e),  // Deep purple
      const Color(0xFF16213e),  // Navy blue
      const Color(0xFF0f3460),  // Royal blue
      const Color(0xFFe94560),  // Coral red
    ];
    
    final colors = widget.colors ?? (isDarkMode ? darkModeColors : lightModeColors);


    return AnimatedBuilder(
      animation: Listenable.merge([_controller1, _controller2]),
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
              stops: [
                0.0,
                0.3 + 0.1 * math.sin(_controller1.value * 2 * math.pi),
                0.6 + 0.1 * math.cos(_controller2.value * 2 * math.pi),
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated overlay circles
              // Animated overlay circles - only show in dark mode
              if (isDarkMode) ...[
                Positioned(
                  top: -100 + 50 * math.sin(_controller1.value * 2 * math.pi),
                  left: -100 + 50 * math.cos(_controller2.value * 2 * math.pi),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.purple.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150 + 80 * math.cos(_controller1.value * 2 * math.pi),
                  right: -100 + 60 * math.sin(_controller2.value * 2 * math.pi),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue.withOpacity(0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              // Main content
              widget.child,
            ],
          ),
        );
      },
    );
  }
}

/// Animated wave background for player screen
class WaveBackground extends StatefulWidget {
  final Widget child;
  final Color color;
  
  const WaveBackground({
    Key? key,
    required this.child,
    this.color = Colors.blue,
  }) : super(key: key);

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
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
        return CustomPaint(
          painter: WavePainter(
            animation: _controller.value,
            color: widget.color,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double animation;
  final Color color;

  WavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final width = size.width;
    final height = size.height;

    path.moveTo(0, height * 0.7);

    for (double x = 0; x <= width; x++) {
      final y = height * 0.7 +
          math.sin((x / width * 2 * math.pi) + (animation * 2 * math.pi)) * 30;
      path.lineTo(x, y);
    }

    path.lineTo(width, height);
    path.lineTo(0, height);
    path.close();

    canvas.drawPath(path, paint);

    // Second wave
    final paint2 = Paint()
      ..color = color.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, height * 0.8);

    for (double x = 0; x <= width; x++) {
      final y = height * 0.8 +
          math.sin((x / width * 2 * math.pi) + (animation * 2 * math.pi) + 1) * 40;
      path2.lineTo(x, y);
    }

    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Pulsing glow effect for playing indicator
class PulsingGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;
  
  const PulsingGlow({
    Key? key,
    required this.child,
    this.color = Colors.green,
    this.size = 20,
  }) : super(key: key);

  @override
  State<PulsingGlow> createState() => _PulsingGlowState();
}

class _PulsingGlowState extends State<PulsingGlow>
    with SingleTickerProviderStateMixin {
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
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3 + 0.3 * _controller.value),
                blurRadius: widget.size * (0.5 + 0.5 * _controller.value),
                spreadRadius: widget.size * 0.3 * _controller.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
