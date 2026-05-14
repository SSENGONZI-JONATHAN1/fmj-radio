import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../blocs/player_bloc.dart';
import '../models/jfm_station.dart';
import '../models/announcement.dart';
import '../themes/jfm_themes.dart';
import '../services/announcement_service.dart';
import '../services/app_config_service.dart';
import '../widgets/premium_audio_visualizer.dart';
import '../widgets/announcement_banner.dart';
import 'side_menu_screen.dart';
import 'theme_selector_screen.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';


class MainPlayerScreen extends StatefulWidget {
  const MainPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MainPlayerScreen> createState() => _MainPlayerScreenState();
}

class _MainPlayerScreenState extends State<MainPlayerScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _playButtonController;
  late AnimationController _glowController;
  
  final JfmStation _jfmStation = JfmStation();
  final AnnouncementService _announcementService = AnnouncementService();
  final AppConfigService _appConfigService = AppConfigService();
  
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
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('selected_theme') ?? 'purpleDream';
    _currentTheme = JfmThemeData.fromName(themeName);
    setState(() {});
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

  void _onThemeChanged(JfmThemeData theme) {
    setState(() {
      _currentTheme = theme;
    });
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
              
              _buildStationLogo(),
              
              const SizedBox(height: 30),
              
              _buildStationInfo(),
              
              const SizedBox(height: 20),
              
              SizedBox(
                height: 80,
                child: PremiumAudioVisualizer(theme: _currentTheme),
              ),
              
              const SizedBox(height: 30),
              
              if (_currentAnnouncement != null)
                AnnouncementBanner(
                  announcement: _currentAnnouncement!,
                  theme: _currentTheme,
                  onDismiss: () => setState(() => _currentAnnouncement = null),
                ),
              
              const Spacer(),
              
              _buildPlayButton(),
              
              const Spacer(),
              
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
        'Jfm Radio',
        style: TextStyle(
          color: _currentTheme.text,
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 1.5,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.info_outline, color: _currentTheme.text),
          onPressed: _showStationInfo,
        ),
      ],
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.5), width: 1),
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
                color: _currentTheme.glowColor.withOpacity(0.3 + (_glowController.value * 0.2)),
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
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

        // Animate the play/pause icon to match state
        if (isPlaying) {
          if (!_playButtonController.isAnimating) _playButtonController.forward();
        } else {
          if (!_playButtonController.isAnimating) _playButtonController.reverse();
        }

        return GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            if (isPlaying) {
              context.read<PlayerBloc>().add(PausePlayback());
            } else if (state is PlayerPaused) {
              context.read<PlayerBloc>().add(ResumePlayback());
            } else {
              context.read<PlayerBloc>().add(PlayStation(_jfmStation.station));
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
            icon: Icons.volunteer_activism,
            label: 'Donate',
            onTap: () => _launchUrl('https://www.zeffy.com/en-CA/donation-form/donate-sponsor-our-projects'),
          ),

          _buildActionButton(
            icon: Icons.chat,
            label: 'WhatsApp',
            onTap: () => _launchUrl(_appConfigService.links.whatsapp),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
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
              'About Jfm Radio',
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
    if (url == null) return;
    var sanitized = url.trim();
    // Remove accidental trailing or surrounding single/double quotes
    sanitized = sanitized.replaceAll("'", '');
    sanitized = sanitized.replaceAll('"', '');
    if (sanitized.isEmpty) return;
    Uri uri;
    try {
      uri = Uri.parse(sanitized);
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$sanitized');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback to in-app web view
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link')),
      );
    }
  }

  Future<void> _shareApp() async {
    await Share.share(
      '🎵 Listen to Jfm Radio - Your favorite music 24/7!\n\n'
      'Download the app: https://jfmradio.com/app',
      subject: 'Jfm Radio',
    );
  }

  Future<void> _rateApp() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    } else {
      await inAppReview.openStoreListing(appStoreId: 'jfm-radio');
    }
  }
}
