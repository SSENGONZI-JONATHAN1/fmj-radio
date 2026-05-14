import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
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
        id: 'fmj_radio',
        name: 'Radio FmJ',
      streamUrl: 'http://165.245.232.129/listen/fmj_radio/radio.mp3',
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

/// App Configuration Model (merged from models/app_config.dart)
class AppConfig extends Equatable {
  final String stationName;
  final String streamUrl;
  final String logoUrl;
  final AppThemeConfig theme;
  final AppLinks links;
  final String version;
  final bool maintenanceMode;
  final String? maintenanceMessage;

  const AppConfig({
    required this.stationName,
    required this.streamUrl,
    required this.logoUrl,
    required this.theme,
    required this.links,
    this.version = '1.0.0',
    this.maintenanceMode = false,
    this.maintenanceMessage,
  });

  /// configuration for Jfm Radio
  factory AppConfig.defaultConfig() {
    return AppConfig(
      stationName: 'Jfm Radio',
      streamUrl: 'http://165.245.232.129/listen/fmj_radio/radio.mp3',
      logoUrl: 'https://i.imgur.com/JfmRadioLogo.png',
      theme: AppThemeConfig.defaultTheme(),
      links: AppLinks.defaultLinks(),
      version: '1.0.0',
    );
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      stationName: json['stationName'] as String? ?? 'Jfm Radio',
      streamUrl: json['streamUrl'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      theme: json['theme'] != null
          ? AppThemeConfig.fromJson(json['theme'] as Map<String, dynamic>)
          : AppThemeConfig.defaultTheme(),
      links: json['links'] != null
          ? AppLinks.fromJson(json['links'] as Map<String, dynamic>)
          : AppLinks.defaultLinks(),
      version: json['version'] as String? ?? '1.0.0',
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
      maintenanceMessage: json['maintenanceMessage'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'streamUrl': streamUrl,
      'logoUrl': logoUrl,
      'theme': theme.toJson(),
      'links': links.toJson(),
      'version': version,
      'maintenanceMode': maintenanceMode,
      'maintenanceMessage': maintenanceMessage,
    };
  }

  AppConfig copyWith({
    String? stationName,
    String? streamUrl,
    String? logoUrl,
    AppThemeConfig? theme,
    AppLinks? links,
    String? version,
    bool? maintenanceMode,
    String? maintenanceMessage,
  }) {
    return AppConfig(
      stationName: stationName ?? this.stationName,
      streamUrl: streamUrl ?? this.streamUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      theme: theme ?? this.theme,
      links: links ?? this.links,
      version: version ?? this.version,
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
    );
  }

  @override
  List<Object?> get props => [
        stationName,
        streamUrl,
        logoUrl,
        theme,
        links,
        version,
        maintenanceMode,
        maintenanceMessage,
      ];

  @override
  String toString() => 'AppConfig(stationName: $stationName, version: $version)';
}

/// Theme Configuration
class AppThemeConfig extends Equatable {
  final String primary;
  final String secondary;
  final String accent;
  final String background;
  final String text;

  const AppThemeConfig({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.text,
  });

  factory AppThemeConfig.defaultTheme() {
    return const AppThemeConfig(
      primary: '#6D28D9', // Purple
      secondary: '#8B5CF6',
      accent: '#F59E0B',
      background: '#0F0F1A',
      text: '#FFFFFF',
    );
  }

  factory AppThemeConfig.fromJson(Map<String, dynamic> json) {
    return AppThemeConfig(
      primary: json['primary'] as String? ?? '#6D28D9',
      secondary: json['secondary'] as String? ?? '#8B5CF6',
      accent: json['accent'] as String? ?? '#F59E0B',
      background: json['background'] as String? ?? '#0F0F1A',
      text: json['text'] as String? ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary,
      'secondary': secondary,
      'accent': accent,
      'background': background,
      'text': text,
    };
  }

  @override
  List<Object?> get props => [primary, secondary, accent, background, text];
}

/// App Links Configuration
class AppLinks extends Equatable {
  final String? website;
  final String? instagram;
  final String? whatsapp;
  final String? facebook;
  final String? twitter;
  final String? youtube;
  final String? email;
  final String? phone;

  const AppLinks({
    this.website,
    this.instagram,
    this.whatsapp,
    this.facebook,
    this.twitter,
    this.youtube,
    this.email,
    this.phone,
  });

  factory AppLinks.defaultLinks() {
    return const AppLinks(
      website: 'https://jfmradio.com',
      instagram: 'https://instagram.com/jfmradio',
      whatsapp: 'https://wa.me/1234567890',
      facebook: 'https://facebook.com/jfmradio',
      email: 'contact@jfmradio.com',
    );
  }

  factory AppLinks.fromJson(Map<String, dynamic> json) {
    return AppLinks(
      website: json['website'] as String?,
      instagram: json['instagram'] as String?,
      whatsapp: json['whatsapp'] as String?,
      facebook: json['facebook'] as String?,
      twitter: json['twitter'] as String?,
      youtube: json['youtube'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'website': website,
      'instagram': instagram,
      'whatsapp': whatsapp,
      'facebook': facebook,
      'twitter': twitter,
      'youtube': youtube,
      'email': email,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [
        website,
        instagram,
        whatsapp,
        facebook,
        twitter,
        youtube,
        email,
        phone,
      ];
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
