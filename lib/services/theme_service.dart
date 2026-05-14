import 'package:shared_preferences/shared_preferences.dart';
import '../themes/jfm_themes.dart';

/// Theme Service - Handles saving and loading theme preferences
class ThemeService {
  static const String _themeKey = 'selected_theme';
  
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  /// Save the selected theme
  Future<void> saveTheme(JfmTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);
  }

  /// Load the saved theme, returns null if no theme is saved
  Future<JfmTheme?> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeKey);
    
    if (themeName == null) return null;
    
    // Find the theme by name
    for (final theme in JfmTheme.values) {
      if (theme.name == themeName) {
        return theme;
      }
    }
    return null;
  }

  /// Get the default theme (Purple Dream)
  JfmTheme get defaultTheme => JfmTheme.purpleDream;
}
