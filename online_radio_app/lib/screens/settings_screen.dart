import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/theme_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme settings
          ListTile(
            leading: const Icon(Icons.palette),
            title: const Text('Theme'),
            subtitle: const Text('Light / Dark / System'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showThemeDialog(context);
            },
          ),
          
          const Divider(),
          
          // Audio quality
          ListTile(
            leading: const Icon(Icons.high_quality),
            title: const Text('Audio Quality'),
            subtitle: const Text('High quality streaming'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showAudioQualityDialog(context);
            },
          ),
          
          const Divider(),
          
          // Sleep timer
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Sleep Timer'),
            subtitle: const Text('Auto-stop playback'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showSleepTimerDialog(context);
            },
          ),
          
          const Divider(),
          
          // About
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('Version 1.0.0'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Light'),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                // context.read<ThemeBloc>().add(SetLightTheme());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Dark'),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                // context.read<ThemeBloc>().add(SetDarkTheme());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('System'),
              leading: const Icon(Icons.settings_suggest),
              onTap: () {
                // context.read<ThemeBloc>().add(SetSystemTheme());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAudioQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audio Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Low (64 kbps)'),
              value: 'low',
              groupValue: 'high',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Medium (128 kbps)'),
              value: 'medium',
              groupValue: 'high',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('High (320 kbps)'),
              value: 'high',
              groupValue: 'high',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSleepTimerDialog(BuildContext context) {
    final List<int> minutes = [15, 30, 45, 60, 90, 120];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: minutes.map((min) {
            return ListTile(
              title: Text('$min minutes'),
              onTap: () {
                // Set sleep timer
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sleep timer set for $min minutes')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Online Radio'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('A professional online radio streaming application.'),
            SizedBox(height: 8),
            Text('Features:'),
            Text('• Live radio streaming'),
            Text('• Background playback'),
            Text('• Favorites management'),
            Text('• Sleep timer'),
            Text('• High quality audio'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
