import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_view/services/theme_service.dart';

void main() {
  group('ThemeService', () {
    test('getThemeName returns correct names for all themes', () {
      expect(ThemeService.getThemeName(AppTheme.light), equals('Light'));
      expect(ThemeService.getThemeName(AppTheme.dark), equals('Dark'));
      expect(ThemeService.getThemeName(AppTheme.blue), equals('Ocean Blue'));
      expect(ThemeService.getThemeName(AppTheme.green), equals('Nature Green'));
      expect(ThemeService.getThemeName(AppTheme.purple), equals('Royal Purple'));
    });

    testWidgets('getThemeData returns non-null ThemeData for all themes', (WidgetTester tester) async {
      for (var theme in AppTheme.values) {
        final themeData = ThemeService.getThemeData(theme);
        expect(themeData, isNotNull);
        expect(themeData.useMaterial3, isTrue);
      }
    });

    testWidgets('light theme has correct brightness', (WidgetTester tester) async {
      final themeData = ThemeService.getThemeData(AppTheme.light);
      expect(themeData.brightness, equals(Brightness.light));
    });

    testWidgets('dark theme has correct brightness', (WidgetTester tester) async {
      final themeData = ThemeService.getThemeData(AppTheme.dark);
      expect(themeData.brightness, equals(Brightness.dark));
    });

    testWidgets('all themes have app bar configuration', (WidgetTester tester) async {
      for (var theme in AppTheme.values) {
        final themeData = ThemeService.getThemeData(theme);
        expect(themeData.appBarTheme, isNotNull);
        expect(themeData.appBarTheme.centerTitle, isTrue);
        expect(themeData.appBarTheme.elevation, equals(0));
      }
    });

    testWidgets('all themes have card theme configuration', (WidgetTester tester) async {
      for (var theme in AppTheme.values) {
        final themeData = ThemeService.getThemeData(theme);
        expect(themeData.cardTheme, isNotNull);
        expect(themeData.cardTheme.elevation, equals(2));
      }
    });

    testWidgets('all themes have input decoration theme', (WidgetTester tester) async {
      for (var theme in AppTheme.values) {
        final themeData = ThemeService.getThemeData(theme);
        expect(themeData.inputDecorationTheme, isNotNull);
        expect(themeData.inputDecorationTheme.filled, isTrue);
      }
    });
  });
}
