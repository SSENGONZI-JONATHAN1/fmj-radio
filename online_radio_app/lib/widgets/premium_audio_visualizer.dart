import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/audio_player_service.dart';
import '../../themes/jfm_themes.dart';

class PremiumAudioVisualizer extends StatefulWidget {
  final JfmThemeData theme;

  const PremiumAudioVisualizer({
    Key? key,
    required this.theme,
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        final nowPlaying = audioService.nowPlayingInfo;
        final position = audioService.position.inMilliseconds / 1000.0;
        final isPlaying = audioService.isPlaying;

        // Start/stop breathing animation based on playback
        if (isPlaying) {
          if (!_controller.isAnimating) _controller.repeat(reverse: true);
        } else {
          if (_controller.isAnimating) _controller.stop();
        }

        // Estimate an "energy" value per track so the visualizer reacts
        // more when music is playing. This is an approximation (not a
        // true FFT/pitch detector) — for real pitch analysis a native
        // audio capture/FFT plugin is required.
        final trackSeed = (nowPlaying.title + (nowPlaying.artist ?? '')).hashCode;
        final baseEnergy = ((trackSeed & 0xFF) / 255.0).clamp(0.1, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Song Info
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: widget.theme.primary,
                      child: nowPlaying.artworkUrl != null && nowPlaying.artworkUrl!.isNotEmpty
                          ? Image.network(
                              nowPlaying.artworkUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.music_note,
                                color: widget.theme.text,
                                size: 24,
                              ),
                            )
                          : Icon(
                              Icons.music_note,
                              color: widget.theme.text,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nowPlaying.title,
                          style: TextStyle(
                            color: widget.theme.text,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          nowPlaying.artist,
                          style: TextStyle(
                            color: widget.theme.textSecondary,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Visualizer Bars
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(24, (index) {
                  // Realistic audio visualization simulation
                  final time = position + _controller.value * 2;
                  
                  // Frequency band simulation (low/mid/high frequencies)
                  final freq = index / 24.0; // 0.0 (bass) to 1.0 (treble)
                  final baseHeight = 20 + freq * 30 * baseEnergy; // Higher freq = taller potential
                  
                  // Beat detection simulation (peaks every ~1-2 seconds)
                  final beatTime = (time * (0.8 + baseEnergy)).remainder(2.0);
                  final beatIntensity = isPlaying && beatTime < 0.2 ? (1.0 - beatTime / 0.2) * (1.5 * baseEnergy) : 0.0;
                  
                  // Position sweep effect (wave moves left to right)
                  final sweep = ((time * 0.3 + index * 0.2).remainder(2.0) - 1.0).abs();
                  final sweepEffect = 1.0 + (1.0 - sweep) * 0.8;
                  
                  // Breathing animation
                  final breath = 0.8 + _controller.value * 0.4 * (isPlaying ? 1.0 : 0.1);
                  
                  // Final height calculation
                  double height = baseHeight * breath * sweepEffect * (1.0 + beatIntensity);
                  if (!isPlaying) height *= 0.12; // Nearly still when paused
                  
                  height = height.clamp(8.0, 70.0);
                  
                  // Color intensity based on beat/energy
                  final intensity = (beatIntensity + sweepEffect * 0.5).clamp(0.0, 1.0);
                  
                  return Container(
                    width: 4 + freq * 2, // Thinner bass, thicker treble
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 1.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          widget.theme.primary.withOpacity(0.4 + intensity * 0.4),
                          widget.theme.accent.withOpacity(0.6 + intensity * 0.3),
                          widget.theme.glowColor.withOpacity(intensity),
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(3 + freq * 2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.theme.glowColor.withOpacity(intensity * 0.6),
                          blurRadius: 12 + beatIntensity * 12,
                          spreadRadius: beatIntensity * 2,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

          ],
        );
      },
    );
  }
}
