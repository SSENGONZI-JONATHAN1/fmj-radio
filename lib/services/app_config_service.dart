import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';

/// App Config Service
/// 
/// Manages fetching and caching of app configuration from API.
/// Allows owner to change stream URL, logo, theme, and links without app updates.
class AppConfigService {
  static const String _cacheKey = 'app_config_cache';
  static const String _lastFetchKey = 'app_config_last_fetch';
  static const Duration _cacheDuration = Duration(hours: 1);

  static final AppConfigService _instance = AppConfigService._internal();
  factory AppConfigService() => _instance;
  AppConfigService._internal();

  AppConfig _currentConfig = AppConfig.defaultConfig();
  AppConfig get currentConfig => _currentConfig;

  /// Initialize and load cached config
  Future<void> initialize() async {
    await _loadCachedConfig();
  }

  /// Fetch app config from API
  /// Endpoint: GET /app-config
  Future<AppConfig> fetchConfig() async {
    try {
      // Check if we should use cached version
      if (await _isCacheValid()) {
        return _currentConfig;
      }

      // TODO: Replace with actual API call
      // final response = await dio.get('/app-config');
      // final config = AppConfig.fromJson(response.data);
      
      // For now, use default config
      final config = AppConfig.defaultConfig();
      
      // Cache the config
      await _cacheConfig(config);
      _currentConfig = config;
      
      return config;
    } catch (e) {
      print('Error fetching app config: $e');
      // Return cached or default config on error
      return _currentConfig;
    }
  }

  /// Load config from cache
  Future<void> _loadCachedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      
      if (cachedJson != null) {
        final json = jsonDecode(cachedJson) as Map<String, dynamic>;
        _currentConfig = AppConfig.fromJson(json);
      }
    } catch (e) {
      print('Error loading cached config: $e');
    }
  }

  /// Cache config locally
  Future<void> _cacheConfig(AppConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(config.toJson()));
      await prefs.setInt(_lastFetchKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching config: $e');
    }
  }

  /// Check if cache is still valid
  Future<bool> _isCacheValid() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetch = prefs.getInt(_lastFetchKey);
      
      if (lastFetch == null) return false;
      
      final lastFetchTime = DateTime.fromMillisecondsSinceEpoch(lastFetch);
      return DateTime.now().difference(lastFetchTime) < _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  /// Force refresh config from API
  Future<AppConfig> forceRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastFetchKey);
    return fetchConfig();
  }

  /// Update stream URL (for testing or admin override)
  Future<void> updateStreamUrl(String newUrl) async {
    _currentConfig = _currentConfig.copyWith(streamUrl: newUrl);
    await _cacheConfig(_currentConfig);
  }

  /// Update logo URL
  Future<void> updateLogoUrl(String newUrl) async {
    _currentConfig = _currentConfig.copyWith(logoUrl: newUrl);
    await _cacheConfig(_currentConfig);
  }

  /// Get stream URL
  String get streamUrl => _currentConfig.streamUrl;

  /// Get logo URL
  String get logoUrl => _currentConfig.logoUrl;

  /// Get station name
  String get stationName => _currentConfig.stationName;

  /// Get social links
  AppLinks get links => _currentConfig.links;

  /// Check if in maintenance mode
  bool get isMaintenanceMode => _currentConfig.maintenanceMode;

  /// Get maintenance message
  String? get maintenanceMessage => _currentConfig.maintenanceMessage;
}
