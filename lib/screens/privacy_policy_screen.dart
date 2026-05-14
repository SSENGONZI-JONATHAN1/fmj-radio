import 'package:flutter/material.dart';
import '../themes/jfm_themes.dart';

/// Privacy Policy Screen
class PrivacyPolicyScreen extends StatelessWidget {
  final JfmThemeData theme;

  const PrivacyPolicyScreen({
    Key? key,
    required this.theme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.text),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: theme.text,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect minimal information to provide you with the best radio streaming experience. This includes:\n\n'
                  '• Device information (model, OS version) for app optimization\n'
                  '• App usage statistics to improve our service\n'
                  '• Crash reports to fix bugs and improve stability\n\n'
                  'We do not collect personal information such as your name, email, or location without your explicit consent.',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'The information we collect is used solely for:\n\n'
                  '• Improving app performance and user experience\n'
                  '• Fixing technical issues and bugs\n'
                  '• Analyzing app usage to make better content decisions\n'
                  '• Sending push notifications (only if you opt-in)',
            ),
            _buildSection(
              title: '3. Data Storage and Security',
              content:
                  'We take your privacy seriously. All data is stored securely using industry-standard encryption. '
                  'We do not sell, trade, or transfer your information to third parties. '
                  'Your listening history and preferences are stored locally on your device only.',
            ),
            _buildSection(
              title: '4. Third-Party Services',
              content:
                  'Our app uses the following third-party services:\n\n'
                  '• Firebase Cloud Messaging for push notifications\n'
                  '• Analytics tools for app improvement\n\n'
                  'These services have their own privacy policies and may collect information as specified in their respective policies.',
            ),
            _buildSection(
              title: '5. Your Rights',
              content:
                  'You have the right to:\n\n'
                  '• Access the information we have about you\n'
                  '• Request deletion of your data\n'
                  '• Opt-out of analytics and notifications\n'
                  '• Contact us with privacy concerns\n\n'
                  'To exercise these rights, please contact us at privacy@jfmradio.com',
            ),
            _buildSection(
              title: '6. Children\'s Privacy',
              content:
                  'Our app is not intended for children under 13. We do not knowingly collect information from children under 13. '
                  'If you are a parent and believe your child has provided us with information, please contact us immediately.',
            ),
            _buildSection(
              title: '7. Changes to This Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new '
                  'Privacy Policy on this page and updating the "Last Updated" date.',
            ),
            _buildSection(
              title: '8. Contact Us',
              content:
                  'If you have any questions about this Privacy Policy, please contact us:\n\n'
                  'Email: privacy@jfmradio.com\n'
                  'Website: www.jfmradio.com/privacy\n'
                  'Address: Jfm Radio, 123 Music Street, Audio City, AC 12345',
            ),
            const SizedBox(height: 32),
            _buildLastUpdated(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primary.withOpacity(0.3),
            theme.secondary.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shield,
            size: 48,
            color: theme.accent,
          ),
          const SizedBox(height: 16),
          Text(
            'Your Privacy Matters',
            style: TextStyle(
              color: theme.text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'We are committed to protecting your personal information and being transparent about our data practices.',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.text,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.glassBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.glassBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update,
            color: theme.accent,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            'Last Updated: January 2024',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
