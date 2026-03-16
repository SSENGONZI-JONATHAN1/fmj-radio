import 'package:flutter/material.dart';
import 'station.dart';

/// Jfm Station - Single Station Singleton
/// 
/// This class manages the single Jfm Radio station.
/// It provides the station data and handles the single-station architecture.
class JfmStation {
  static final JfmStation _instance = JfmStation._internal();
  factory JfmStation() => _instance;
  JfmStation._internal();

  /// Default Jfm Radio Station
  Station get station => Station(
        id: 'jfm_radio_001',
        name: 'Jfm Radio',
        streamUrl: 'https://stream.zeno.fm/0r0xapr5mceuv',
        logoUrl: 'https://i.imgur.com/JfmRadioLogo.png',
        description: 'Your favorite music, 24/7',
        category: 'Music',
        country: 'International',
        language: 'English',
        tags: ['music', 'hits', 'entertainment', 'live'],
        isFavorite: true, // Always favorite since it's the only station
      );

  /// Station metadata
  String get name => 'Jfm Radio';
  String get tagline => 'Your Music, Your Way';
  String get description => '24/7 non-stop music streaming';
  
  /// Social links (can be updated from AppConfig)
  String get website => 'https://jfmradio.com';
  String get whatsapp => 'https://wa.me/1234567890';
  String get instagram => 'https://instagram.com/jfmradio';
  String get facebook => 'https://facebook.com/jfmradio';
  String get email => 'contact@jfmradio.com';
  
  /// Check if stream URL is valid
  bool isValidStreamUrl(String url) {
    if (url.isEmpty) return false;
    return Uri.tryParse(url)?.hasAbsolutePath ?? false;
  }

  /// Update stream URL (called from AppConfig)
  Station updateStreamUrl(String newUrl) {
    return station.copyWith(streamUrl: newUrl);
  }

  /// Update logo URL (called from AppConfig)
  Station updateLogoUrl(String newUrl) {
    return station.copyWith(logoUrl: newUrl);
  }
}

/// Station Status
enum StationStatus {
  idle,
  connecting,
  buffering,
  playing,
  paused,
  error,
}

/// Station Status Extension
extension StationStatusX on StationStatus {
  String get label {
    switch (this) {
      case StationStatus.idle:
        return 'Ready';
      case StationStatus.connecting:
        return 'Connecting...';
      case StationStatus.buffering:
        return 'Buffering...';
      case StationStatus.playing:
        return 'LIVE';
      case StationStatus.paused:
        return 'Paused';
      case StationStatus.error:
        return 'Error';
    }
  }

  Color get color {
    switch (this) {
      case StationStatus.idle:
        return Colors.grey;
      case StationStatus.connecting:
        return Colors.orange;
      case StationStatus.buffering:
        return Colors.yellow;
      case StationStatus.playing:
        return Colors.green;
      case StationStatus.paused:
        return Colors.orange;
      case StationStatus.error:
        return Colors.red;
    }
  }

  bool get isLive => this == StationStatus.playing;
  bool get isLoading => this == StationStatus.connecting || this == StationStatus.buffering;
}
