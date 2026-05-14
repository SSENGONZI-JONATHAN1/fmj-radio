import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

class SetLightThemeEvent extends ThemeEvent {}

class SetDarkThemeEvent extends ThemeEvent {}

class SetSystemThemeEvent extends ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

// States
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

class ThemeInitialState extends ThemeState {}

class ThemeLoadedState extends ThemeState {
  final ThemeMode themeMode;
  final bool isDarkMode;

  const ThemeLoadedState({
    required this.themeMode,
    required this.isDarkMode,
  });

  @override
  List<Object?> get props => [themeMode, isDarkMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme_mode';

  ThemeBloc() : super(ThemeInitialState()) {
    on<LoadThemeEvent>(_onLoadTheme);
    on<SetLightThemeEvent>(_onSetLightTheme);
    on<SetDarkThemeEvent>(_onSetDarkTheme);
    on<SetSystemThemeEvent>(_onSetSystemTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(
    LoadThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey) ?? 'system';
    
    ThemeMode themeMode;
    bool isDarkMode;
    
    switch (savedTheme) {
      case 'light':
        themeMode = ThemeMode.light;
        isDarkMode = false;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        isDarkMode = true;
        break;
      default:
        themeMode = ThemeMode.system;
        isDarkMode = false; // Will be determined by system
    }
    
    emit(ThemeLoadedState(themeMode: themeMode, isDarkMode: isDarkMode));
  }

  Future<void> _onSetLightTheme(
    SetLightThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _saveTheme('light');
    emit(const ThemeLoadedState(themeMode: ThemeMode.light, isDarkMode: false));
  }

  Future<void> _onSetDarkTheme(
    SetDarkThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _saveTheme('dark');
    emit(const ThemeLoadedState(themeMode: ThemeMode.dark, isDarkMode: true));
  }

  Future<void> _onSetSystemTheme(
    SetSystemThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    await _saveTheme('system');
    emit(const ThemeLoadedState(themeMode: ThemeMode.system, isDarkMode: false));
  }

  Future<void> _onToggleTheme(
    ToggleThemeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoadedState) {
      final currentState = state as ThemeLoadedState;
      
      if (currentState.isDarkMode) {
        add(SetLightThemeEvent());
      } else {
        add(SetDarkThemeEvent());
      }
    }
  }

  Future<void> _saveTheme(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }
}
