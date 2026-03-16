import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../blocs/player_bloc.dart';
import '../models/jfm_station.dart';
import '../models/announcement.dart';
import '../themes/jfm_themes.dart';
import '../services/announcement_service.dart';
import '../services/app_config_service.dart';
import '../services/theme_service.dart';
import '../widgets/premium_audio_visualizer.dart';
import '../widgets/announcement_banner.dart';
import 'side_menu_screen.dart';
import 'theme_selector_screen.dart';

/// Main Player Screen - Premium Single Station UI
/// 
/// Features:
/// - Animated gradient background
/// - Circular glowing station logo
/// - Large premium play button with ripple effects
/// - Audio visualizer with custom designs
/// - Announcement banner
/// - Bottom action row
/// - Glassmorphism effects throughout
class MainPlayerScreen extends StatefulWidget {
  const MainPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MainPlayerScreen> createState() => _MainPlayerScreenState();
}

class _MainPlayerScreenState extends State<MainPlayerScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _playButtonController;
  late AnimationController _glowController;
  
  final JfmStation _jfmStation = JfmStation();
  final AnnouncementService _announcementService = AnnouncementService();
  final AppConfigService _appConfigService = AppConfigService();
  final ThemeService _themeService = ThemeService();
  
  JfmThemeData _currentTheme = JfmThemeData.purpleDream;
  Announcement? _currentAnnouncement;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadTheme();
    _loadAnnouncements();
  }

  void _initAnimations() {
    _logoController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _playButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadTheme() async {
    final savedTheme = await _themeService.loadTheme();
    if (savedTheme != null) {
      setState(() {
        _currentTheme = JfmThemeData.fromEnum(savedTheme);
      });
    }
  }

  Future<void> _loadAnnouncements() async {
    await _announcementService.initialize();
    final announcements = await _announcementService.fetchAnnouncements();
    if (announcements.isNotEmpty) {
      setState(() {
        _currentAnnouncement = _announcementService.bannerAnnouncement;
      });
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _playButtonController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onThemeChanged(JfmThemeData theme) async {
    setState(() {
      _currentTheme = theme;
    });
    // Save the theme preference
    final themeEnum = JfmTheme.values.firstWhere(
      (t) => JfmThemeData.fromEnum(t) == theme,
      orElse: () => JfmTheme.purpleDream,
    );
    await _themeService.saveTheme(themeEnum);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      theme: _currentTheme,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        drawer: SideMenuScreen(
          currentTheme: _currentTheme,
          onThemeChanged: _onThemeChanged,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Station Logo with Glow
              _buildStationLogo(),
              
              const SizedBox(height: 30),
              
              // Station Name & Status
              _buildStationInfo(),
              
              const SizedBox(height: 20),
              
              // Audio Visualizer
              SizedBox(
                height: 80,
                child: PremiumAudioVisualizer(
                  theme: _currentTheme,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Announcement Banner
              if (_currentAnnouncement != null)
                AnnouncementBanner(
                  announcement: _currentAnnouncement!,
                  theme: _currentTheme,
                  onDismiss: () {
                    setState(() {
                      _currentAnnouncement = null;
                    });
                  },
                ),
              
              const Spacer(),
              
              // Play Button
              _buildPlayButton(),
              
              const Spacer(),
              
              // Bottom Actions
              _buildBottomActions(),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: _currentTheme.text),
      title: Text(
        'FmJ Radio',
        style: TextStyle(
          color: _currentTheme.text,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      actions: [
        // Info button
        IconButton(
          icon: Icon(Icons.info_outline, color: _currentTheme.text),
          onPressed: _showStationInfo,
        ),
      ],
    );
  }

  Widget _buildStationLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _currentTheme.glowColor.withOpacity(
                  0.3 + (_glowController.value * 0.2),
                ),
                blurRadius: 40 + (_glowController.value * 20),
                spreadRadius: 10 + (_glowController.value * 10),
              ),
              BoxShadow(
                color: _currentTheme.glowColor.withOpacity(0.1),
                blurRadius: 80,
                spreadRadius: 30,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              Transform.rotate(
                angle: _logoController.value * 2 * math.pi,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _currentTheme.accent.withOpacity(0.3),
                      width: 2,
                    ),
                    gradient: SweepGradient(
                      colors: [
                        _currentTheme.primary.withOpacity(0),
                        _currentTheme.accent.withOpacity(0.5),
                        _currentTheme.primary.withOpacity(0),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Inner glassmorphism container
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _currentTheme.glassBackground,
                      _currentTheme.glassBackground.withOpacity(0.5),
                    ],
                  ),
                  border: Border.all(
                    color: _currentTheme.glassBorder,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _currentTheme.glowColor.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    _jfmStation.station.logoUrl ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: _currentTheme.primary,
                        child: Icon(
                          Icons.radio,
                          size: 80,
                          color: _currentTheme.text,
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Live indicator
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStationInfo() {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        String statusText = 'Ready to Play';
        Color statusColor = _currentTheme.textSecondary;
        
        if (state is PlayerPlaying) {
          statusText = 'Now Playing';
          statusColor = _currentTheme.accent;
        } else if (state is PlayerLoading) {
          statusText = 'Connecting...';
          statusColor = Colors.orange;
        } else if (state is PlayerPaused) {
          statusText = 'Paused';
          statusColor = Colors.orange;
        } else if (state is PlayerError) {
          statusText = 'Connection Error';
          statusColor = Colors.red;
        }

        return Column(
          children: [
            Text(
              _jfmStation.name,
              style: TextStyle(
                color: _currentTheme.text,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _jfmStation.tagline,
              style: TextStyle(
                color: _currentTheme.textSecondary,
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayButton() {
    return BlocBuilder<PlayerBloc, PlayerState>(
      builder: (context, state) {
        final isPlaying = state is PlayerPlaying;
        final isLoading = state is PlayerLoading;

        if (isLoading) {
          return Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _currentTheme.buttonGradientStart,
                  _currentTheme.buttonGradientEnd,
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (isPlaying) {
              context.read<PlayerBloc>().add(PausePlayback());
            } else {
              if (state is PlayerPaused) {
                context.read<PlayerBloc>().add(ResumePlayback());
              } else {
                context.read<PlayerBloc>().add(PlayStation(_jfmStation.station));
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 120,
            height: 120,
            decoration: PremiumButtonStyle.getPlayButtonDecoration(_currentTheme),
            child: Center(
              child: AnimatedIcon(
                icon: isPlaying ? AnimatedIcons.pause_play : AnimatedIcons.play_pause,
                progress: _playButtonController,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: GlassmorphismDecoration.getCardDecoration(_currentTheme),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.language,
            label: 'Website',
            onTap: () => _launchUrl(_appConfigService.links.website),
          ),
          _buildActionButton(
            icon: Icons.favorite,
            label: 'Donate',
            onTap: _donate,
          ),
          _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: _shareApp,
          ),
          _buildActionButton(
            icon: Icons.star,
            label: 'Rate',
            onTap: _rateApp,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentTheme.glassBackground,
              border: Border.all(
                color: _currentTheme.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: _currentTheme.glowColor.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: _currentTheme.text,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: _currentTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showStationInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: GlassmorphismDecoration.getCardDecoration(_currentTheme),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'About FmJ Radio',
              style: TextStyle(
                color: _currentTheme.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _jfmStation.description,
              style: TextStyle(
                color: _currentTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Now Playing',
              style: TextStyle(
                color: _currentTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<PlayerBloc, PlayerState>(
              builder: (context, state) {
                String nowPlaying = 'Unknown';
                if (state is PlayerPlaying) {
                  nowPlaying = state.nowPlaying.title;
                } else if (state is PlayerPaused) {
                  nowPlaying = state.nowPlaying.title;
                }
                return Text(
                  nowPlaying,
                  style: TextStyle(
                    color: _currentTheme.accent,
                    fontSize: 14,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _donate() async {
    const donateUrl = 'https://www.zeffy.com/en-CA/donation-form/donate-sponsor-our-projects';
    final uri = Uri.parse(donateUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareApp() async {
    await Share.share(
      '🎵 Listen to FmJ Radio - Your favorite music 24/7!\n\n'
      'Download the app: https://fmjradio.com/app',
      subject: 'FmJ Radio',
    );
  }

  Future<void> _rateApp() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(appStoreId: 'fmj-radio');
    }
  }
}
