import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/storage_service.dart';

/// Provider for managing app theme state
class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.light;

  AppTheme get currentTheme => _currentTheme;
  ThemeData get themeData => ThemeService.getThemeData(_currentTheme);

  ThemeProvider() {
    _loadTheme();
  }

  /// Load saved theme from storage
  Future<void> _loadTheme() async {
    final savedTheme = await StorageService.getTheme();
    if (savedTheme != null) {
      try {
        _currentTheme = AppTheme.values.firstWhere(
          (theme) => theme.name == savedTheme,
          orElse: () => AppTheme.light,
        );
        notifyListeners();
      } catch (e) {
        // If theme not found, use default
        _currentTheme = AppTheme.light;
      }
    }
  }

  /// Set new theme and save to storage
  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await StorageService.saveTheme(theme.name);
    notifyListeners();
  }
}
