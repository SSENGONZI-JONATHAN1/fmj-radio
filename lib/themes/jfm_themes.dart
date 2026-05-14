import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Jfm Premium Theme System
/// 
/// 6 unique gradient themes with glassmorphism effects:
/// 1. Purple Dream - Deep purple to violet
/// 2. Ocean Blue - Deep blue to cyan
/// 3. Sunset Glow - Orange to pink
/// 4. Midnight Dark - Deep black to dark blue
/// 5. Emerald Forest - Green to teal
/// 6. Rose Gold - Rose to gold

enum JfmTheme {
  purpleDream,
  oceanBlue,
  sunsetGlow,
  midnightDark,
  emeraldForest,
  roseGold,
}

/// Theme Extension for easy access
extension JfmThemeX on JfmTheme {
  String get name {
    switch (this) {
      case JfmTheme.purpleDream:
        return 'Purple Dream';
      case JfmTheme.oceanBlue:
        return 'Ocean Blue';
      case JfmTheme.sunsetGlow:
        return 'Sunset Glow';
      case JfmTheme.midnightDark:
        return 'Midnight Dark';
      case JfmTheme.emeraldForest:
        return 'Emerald Forest';
      case JfmTheme.roseGold:
        return 'Rose Gold';
    }
  }

  String get description {
    switch (this) {
      case JfmTheme.purpleDream:
        return 'Mystical purple vibes';
      case JfmTheme.oceanBlue:
        return 'Deep ocean serenity';
      case JfmTheme.sunsetGlow:
        return 'Warm sunset colors';
      case JfmTheme.midnightDark:
        return 'Elegant dark mode';
      case JfmTheme.emeraldForest:
        return 'Fresh nature tones';
      case JfmTheme.roseGold:
        return 'Luxury rose gold';
    }
  }

  IconData get icon {
    switch (this) {
      case JfmTheme.purpleDream:
        return Icons.nightlight_round;
      case JfmTheme.oceanBlue:
        return Icons.water;
      case JfmTheme.sunsetGlow:
        return Icons.wb_sunny;
      case JfmTheme.midnightDark:
        return Icons.dark_mode;
      case JfmTheme.emeraldForest:
        return Icons.forest;
      case JfmTheme.roseGold:
        return Icons.diamond;
    }
  }
}

/// Premium Theme Data
class JfmThemeData {
  final List<Color> gradientColors;
  final List<Color> accentGradient;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color glassBackground;
  final Color glassBorder;
  final Color glowColor;
  final Color buttonGradientStart;
  final Color buttonGradientEnd;

  const JfmThemeData({
    required this.gradientColors,
    required this.accentGradient,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.glassBackground,
    required this.glassBorder,
    required this.glowColor,
    required this.buttonGradientStart,
    required this.buttonGradientEnd,
  });

  /// Purple Dream Theme
  static JfmThemeData get purpleDream => const JfmThemeData(
        gradientColors: [
          Color(0xFF1A0A2E),
          Color(0xFF2D1B4E),
          Color(0xFF4A148C),
          Color(0xFF6D28D9),
        ],
        accentGradient: [
          Color(0xFF8B5CF6),
          Color(0xFFA78BFA),
          Color(0xFFC4B5FD),
        ],
        primary: Color(0xFF6D28D9),
        secondary: Color(0xFF8B5CF6),
        accent: Color(0xFFF59E0B),
        background: Color(0xFF0F0F1A),
        surface: Color(0xFF1A1A2E),
        text: Colors.white,
        textSecondary: Color(0xFFB8B8D1),
        glassBackground: Color(0x1AFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        glowColor: Color(0xFF8B5CF6),
        buttonGradientStart: Color(0xFF6D28D9),
        buttonGradientEnd: Color(0xFF8B5CF6),
      );

  /// Ocean Blue Theme
  static JfmThemeData get oceanBlue => const JfmThemeData(
        gradientColors: [
          Color(0xFF0A1628),
          Color(0xFF0D2847),
          Color(0xFF1565C0),
          Color(0xFF0EA5E9),
        ],
        accentGradient: [
          Color(0xFF38BDF8),
          Color(0xFF7DD3FC),
          Color(0xFFBAE6FD),
        ],
        primary: Color(0xFF1565C0),
        secondary: Color(0xFF0EA5E9),
        accent: Color(0xFF22D3EE),
        background: Color(0xFF0A1628),
        surface: Color(0xFF0D2847),
        text: Colors.white,
        textSecondary: Color(0xFFA3C9E2),
        glassBackground: Color(0x1AFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        glowColor: Color(0xFF38BDF8),
        buttonGradientStart: Color(0xFF1565C0),
        buttonGradientEnd: Color(0xFF0EA5E9),
      );

  /// Sunset Glow Theme
  static JfmThemeData get sunsetGlow => const JfmThemeData(
        gradientColors: [
          Color(0xFF2D1B2E),
          Color(0xFF4A192C),
          Color(0xFFE11D48),
          Color(0xFFFB923C),
        ],
        accentGradient: [
          Color(0xFFFDBA74),
          Color(0xFFFCA5A5),
          Color(0xFFFECACA),
        ],
        primary: Color(0xFFE11D48),
        secondary: Color(0xFFFB923C),
        accent: Color(0xFFFCD34D),
        background: Color(0xFF2D1B2E),
        surface: Color(0xFF4A192C),
        text: Colors.white,
        textSecondary: Color(0xFFFECDD3),
        glassBackground: Color(0x1AFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        glowColor: Color(0xFFFB923C),
        buttonGradientStart: Color(0xFFE11D48),
        buttonGradientEnd: Color(0xFFFB923C),
      );

  /// Midnight Dark Theme
  static JfmThemeData get midnightDark => const JfmThemeData(
        gradientColors: [
          Color(0xFF000000),
          Color(0xFF0A0A0A),
          Color(0xFF1A1A2E),
          Color(0xFF2D2D44),
        ],
        accentGradient: [
          Color(0xFF3B3B5C),
          Color(0xFF4A4A6A),
          Color(0xFF6B6B8A),
        ],
        primary: Color(0xFF1A1A2E),
        secondary: Color(0xFF2D2D44),
        accent: Color(0xFF6B7280),
        background: Color(0xFF000000),
        surface: Color(0xFF0A0A0A),
        text: Colors.white,
        textSecondary: Color(0xFF9CA3AF),
        glassBackground: Color(0x1AFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        glowColor: Color(0xFF6B7280),
        buttonGradientStart: Color(0xFF1A1A2E),
        buttonGradientEnd: Color(0xFF3B3B5C),
      );

  /// Emerald Forest Theme
  static JfmThemeData get emeraldForest => const JfmThemeData(
        gradientColors: [
          Color(0xFF064E3B),
          Color(0xFF065F46),
          Color(0xFF059669),
          Color(0xFF10B981),
        ],
        accentGradient: [
          Color(0xFF34D399),
          Color(0xFF6EE7B7),
          Color(0xFFA7F3D0),
        ],
        primary: Color(0xFF059669),
        secondary: Color(0xFF10B981),
        accent: Color(0xFF34D399),
        background: Color(0xFF064E3B),
        surface: Color(0xFF065F46),
        text: Colors.white,
        textSecondary: Color(0xFFA7F3D0),
        glassBackground: Color(0x1AFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        glowColor: Color(0xFF34D399),
        buttonGradientStart: Color(0xFF059669),
        buttonGradientEnd: Color(0xFF10B981),
      );

  /// Rose Gold Theme
  static JfmThemeData get roseGold => const JfmThemeData(
        gradientColors: [
          Color(0xFF4C1D3D),
          Color(0xFF831843),
          Color(0xFFBE185D),
          Color(0xFFF59E0B),
        ],
        accentGradient: [
          Color(0xFFFBBF24),
          Color(0xFFFCD34D),
          Color(0xFFFDE68A),
        ],
        primary: Color(0xFFBE185D),
        secondary: Color(0xFFF59E0B),
        accent: Color(0xFFFBBF24),
        background: Color(0xFF4C1D3D),
        surface: Color(0xFF831843),
        text: Colors.white,
        textSecondary: Color(0xFFFBCFE8),
        glassBackground: Color(0x1AFFFFFF),
        glassBorder: Color(0x33FFFFFF),
        glowColor: Color(0xFFF59E0B),
        buttonGradientStart: Color(0xFFBE185D),
        buttonGradientEnd: Color(0xFFF59E0B),
      );

  /// Get theme by enum
  static JfmThemeData fromEnum(JfmTheme theme) {
    switch (theme) {
      case JfmTheme.purpleDream:
        return purpleDream;
      case JfmTheme.oceanBlue:
        return oceanBlue;
      case JfmTheme.sunsetGlow:
        return sunsetGlow;
      case JfmTheme.midnightDark:
        return midnightDark;
      case JfmTheme.emeraldForest:
        return emeraldForest;
      case JfmTheme.roseGold:
        return roseGold;
    }
  }
}

/// Glassmorphism Decoration Helper
class GlassmorphismDecoration {
  static BoxDecoration getDecoration(JfmThemeData theme) {
    return BoxDecoration(
      color: theme.glassBackground,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: theme.glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.glowColor.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 5,
        ),
      ],
    );
  }

  static BoxDecoration getCardDecoration(JfmThemeData theme) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.glassBackground,
          theme.glassBackground.withOpacity(0.5),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: theme.glassBorder,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: theme.glowColor.withOpacity(0.15),
          blurRadius: 30,
          spreadRadius: 8,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}

/// Animated Gradient Background
class AnimatedGradientBackground extends StatefulWidget {
  final JfmThemeData theme;
  final Widget child;

  const AnimatedGradientBackground({
    Key? key,
    required this.theme,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.theme.gradientColors,
              stops: [
                0.0,
                0.3 + (_controller.value * 0.1),
                0.6 + (_controller.value * 0.1),
                1.0,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Glowing Effect Widget
class GlowingEffect extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double intensity;

  const GlowingEffect({
    Key? key,
    required this.child,
    required this.glowColor,
    this.intensity = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(intensity),
            blurRadius: 30,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: glowColor.withOpacity(intensity * 0.5),
            blurRadius: 60,
            spreadRadius: 20,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Premium Button Style
class PremiumButtonStyle {
  static ButtonStyle getPlayButtonStyle(JfmThemeData theme) {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: const CircleBorder(),
    );
  }

  static BoxDecoration getPlayButtonDecoration(JfmThemeData theme) {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          theme.buttonGradientStart,
          theme.buttonGradientEnd,
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: theme.glowColor.withOpacity(0.5),
          blurRadius: 30,
          spreadRadius: 5,
        ),
        BoxShadow(
          color: theme.glowColor.withOpacity(0.3),
          blurRadius: 60,
          spreadRadius: 15,
        ),
      ],
    );
  }
}
