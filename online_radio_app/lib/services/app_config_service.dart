import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/jfm_station.dart';

/// AppConfigService
///
/// Minimal service that provides `AppConfig` to the app. It tries to
/// load a local `assets/app_config.json` if present, otherwise falls
/// back to `AppConfig.defaultConfig()`.
class AppConfigService {
  AppConfig _currentConfig = AppConfig.defaultConfig();

  AppConfigService();

  AppConfig get currentConfig => _currentConfig;
  AppLinks get links => _currentConfig.links;

  /// Initialize the service. Attempts to load `assets/app_config.json`.
  Future<void> initialize() async {
    try {
      final jsonString = await rootBundle.loadString('assets/app_config.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      _currentConfig = AppConfig.fromJson(jsonMap);
    } catch (e) {
      // Asset not present or failed to parse — keep default config
      _currentConfig = AppConfig.defaultConfig();
    }
  }

  /// Replace current config at runtime
  void updateConfig(AppConfig config) {
    _currentConfig = config;
  }
}
