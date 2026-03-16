// App Constants
class AppConstants {
  // API
  static const String apiBaseUrl = 'https://api.onlineradio.com/v1';
  static const int apiTimeout = 10000; // milliseconds
  
  // Audio
  static const int defaultBitrate = 128;
  static const int highQualityBitrate = 320;
  static const int lowQualityBitrate = 64;
  
  // Cache
  static const int maxCacheSizeMB = 100;
  static const Duration cacheMaxAge = Duration(hours: 24);
  
  // UI
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Recording
  static const int maxRecordingDuration = 60; // seconds
  static const String recordingsDirectory = 'recordings';
}

// Error Messages
class ErrorMessages {
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String playbackError = 'Unable to play this station. Please try another one.';
  static const String notFound = 'Station not found.';
  static const String unknownError = 'An unexpected error occurred.';
}

// Success Messages
class SuccessMessages {
  static const String addedToFavorites = 'Added to favorites';
  static const String removedFromFavorites = 'Removed from favorites';
  static const String recordingStarted = 'Recording started';
  static const String recordingSaved = 'Recording saved';
  static const String sleepTimerSet = 'Sleep timer set';
  static const String cacheCleared = 'Cache cleared successfully';
}

// Categories with icons
class CategoryIcons {
  static const Map<String, String> icons = {
    'pop': '🎵',
    'rock': '🎸',
    'jazz': '🎷',
    'classical': '🎹',
    'electronic': '🎛️',
    'hiphop': '🎤',
    'country': '🤠',
    'rnb': '🎶',
    'reggae': '🌴',
    'latin': '💃',
    'world': '🌍',
    'news': '📰',
    'sports': '⚽',
    'talk': '🗣️',
    'comedy': '😂',
    'religious': '⛪',
    'kids': '🧸',
  };
}

// Countries with flags
class CountryFlags {
  static const Map<String, String> flags = {
    'us': '🇺🇸',
    'gb': '🇬🇧',
    'de': '🇩🇪',
    'fr': '🇫🇷',
    'es': '🇪🇸',
    'it': '🇮🇹',
    'br': '🇧🇷',
    'jp': '🇯🇵',
    'in': '🇮🇳',
    'ng': '🇳🇬',
    'za': '🇿🇦',
    'au': '🇦🇺',
    'ca': '🇨🇦',
    'mx': '🇲🇽',
    'ru': '🇷🇺',
    'cn': '🇨🇳',
    'kr': '🇰🇷',
    'gh': '🇬🇭',
    'ke': '🇰🇪',
    'tz': '🇹🇿',
  };
}

// Shared Preferences Keys
class PrefKeys {
  static const String themeMode = 'theme_mode';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String autoPlayEnabled = 'auto_play_enabled';
  static const String highQualityEnabled = 'high_quality_enabled';
  static const String dataSaverEnabled = 'data_saver_enabled';
  static const String cacheSize = 'cache_size';
  static const String lastStation = 'last_station';
  static const String volume = 'volume';
  static const String userId = 'user_id';
  static const String firstLaunch = 'first_launch';
}

// Hive Box Names
class HiveBoxes {
  static const String favorites = 'favorites';
  static const String cache = 'cache';
  static const String settings = 'settings';
  static const String history = 'history';
}

// Animation Durations
class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

// Audio Formats
class AudioFormats {
  static const List<String> supportedFormats = [
    'mp3',
    'aac',
    'ogg',
    'm3u',
    'pls',
    'xspf',
  ];
  
  static const Map<String, String> mimeTypes = {
    'mp3': 'audio/mpeg',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg',
    'm3u': 'audio/x-mpegurl',
    'pls': 'audio/x-scpls',
  };
}
