import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import '../themes/jfm_themes.dart';
import '../services/app_config_service.dart';
import 'about_screen.dart';
import 'privacy_policy_screen.dart';
import 'theme_selector_screen.dart';

/// Side Menu Screen - Premium Glassmorphism Drawer
/// 
/// Menu Items:
/// - Live Radio (current screen)
/// - Rate App
/// - Share App
/// - About Us
/// - Privacy Policy
/// - Theme Settings
class SideMenuScreen extends StatelessWidget {
  final JfmThemeData currentTheme;
  final Function(JfmThemeData) onThemeChanged;

  const SideMenuScreen({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentTheme.background.withOpacity(0.95),
              currentTheme.background.withOpacity(0.98),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with Logo
              _buildHeader(context),
              
              // Menu Items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.radio,
                      title: 'Live Radio',
                      subtitle: 'Listen now',
                      isActive: true,
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.star_rounded,
                      title: 'Rate App',
                      subtitle: 'Love FmJ? Rate us!',
                      onTap: () {
                        Navigator.pop(context);
                        _rateApp();
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.share_rounded,
                      title: 'Share App',
                      subtitle: 'Share with friends',
                      onTap: () {
                        Navigator.pop(context);
                        _shareApp();
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'About Us',
                      subtitle: 'Learn more about FmJ',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AboutScreen(theme: currentTheme),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      subtitle: 'Your privacy matters',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen(theme: currentTheme),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      context,
                      icon: Icons.color_lens,
                      title: 'Theme Settings',
                      subtitle: 'Customize your experience',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ThemeSelectorScreen(
                              currentTheme: currentTheme,
                              onThemeChanged: onThemeChanged,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Footer
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            currentTheme.primary.withOpacity(0.3),
            currentTheme.secondary.withOpacity(0.2),
          ],
        ),
        border: Border(
          bottom: BorderSide(
            color: currentTheme.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo Container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  currentTheme.buttonGradientStart,
                  currentTheme.buttonGradientEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: currentTheme.glowColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.radio,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'FmJ Radio',
            style: TextStyle(
              color: currentTheme.text,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your Music, Your Way',
            style: TextStyle(
              color: currentTheme.textSecondary,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? currentTheme.primary.withOpacity(0.3)
              : currentTheme.glassBackground,
          border: Border.all(
            color: isActive
                ? currentTheme.primary.withOpacity(0.5)
                : currentTheme.glassBorder,
            width: 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: currentTheme.glowColor.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: isActive ? currentTheme.accent : currentTheme.text,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? currentTheme.accent : currentTheme.text,
          fontSize: 16,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: currentTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: isActive ? currentTheme.accent : currentTheme.textSecondary,
        size: 16,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Divider(
        color: currentTheme.glassBorder,
        height: 1,
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final appConfig = AppConfigService();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: currentTheme.glassBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Social Links
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialButton(
                icon: Icons.language,
                url: appConfig.links.website,
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                icon: Icons.chat,
                url: appConfig.links.whatsapp,
              ),
              const SizedBox(width: 16),
              _buildSocialButton(
                icon: Icons.alternate_email,
                url: appConfig.links.instagram,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Version ${appConfig.currentConfig.version}',
            style: TextStyle(
              color: currentTheme.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2026 FmJ Radio. All rights reserved.',
            style: TextStyle(
              color: currentTheme.textSecondary.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String? url,
  }) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: currentTheme.glassBackground,
          border: Border.all(
            color: currentTheme.glassBorder,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: currentTheme.textSecondary,
          size: 20,
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
