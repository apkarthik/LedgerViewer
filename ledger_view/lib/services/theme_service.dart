import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Available theme options for the app
enum AppTheme {
  light,
  dark,
  blue,
  green,
  purple,
}

/// Service to manage app themes
class ThemeService {
  /// Common text theme to be used across all themes for consistency
  static TextTheme get _baseTextTheme => GoogleFonts.poppinsTextTheme();
  
  /// Get theme data based on the selected theme option
  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return _getLightTheme();
      case AppTheme.dark:
        return _getDarkTheme();
      case AppTheme.blue:
        return _getBlueTheme();
      case AppTheme.green:
        return _getGreenTheme();
      case AppTheme.purple:
        return _getPurpleTheme();
    }
  }

  /// Get theme name for display
  static String getThemeName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.blue:
        return 'Ocean Blue';
      case AppTheme.green:
        return 'Nature Green';
      case AppTheme.purple:
        return 'Royal Purple';
    }
  }

  /// Get theme icon for display
  static IconData getThemeIcon(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.blue:
        return Icons.water;
      case AppTheme.green:
        return Icons.nature;
      case AppTheme.purple:
        return Icons.diamond;
    }
  }

  /// Get primary gradient colors for ledger header based on theme
  static List<Color> getLedgerHeaderGradient(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
      case AppTheme.dark:
        return [const Color(0xFF1E293B), const Color(0xFF334155)];
      case AppTheme.blue:
        return [const Color(0xFF0EA5E9), const Color(0xFF0284C7)];
      case AppTheme.green:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case AppTheme.purple:
        return [const Color(0xFF9333EA), const Color(0xFF7E22CE)];
    }
  }

  /// Get debit color for ledger entries based on theme
  static Color getLedgerDebitColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFF991B1B); // Red
      case AppTheme.dark:
        return const Color(0xFFEF4444); // Lighter red for dark theme
      case AppTheme.blue:
        return const Color(0xFFDC2626); // Red
      case AppTheme.green:
        return const Color(0xFFDC2626); // Red
      case AppTheme.purple:
        return const Color(0xFFDC2626); // Red
    }
  }

  /// Get credit color for ledger entries based on theme
  static Color getLedgerCreditColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFF065F46); // Green
      case AppTheme.dark:
        return const Color(0xFF10B981); // Lighter green for dark theme
      case AppTheme.blue:
        return const Color(0xFF047857); // Green
      case AppTheme.green:
        return const Color(0xFF047857); // Green
      case AppTheme.purple:
        return const Color(0xFF047857); // Green
    }
  }

  /// Get table header background color for ledger based on theme
  static Color getLedgerTableHeaderColor(AppTheme theme, Brightness brightness) {
    switch (theme) {
      case AppTheme.light:
        return Colors.grey.shade100;
      case AppTheme.dark:
        return const Color(0xFF334155);
      case AppTheme.blue:
        return Colors.blue.shade50;
      case AppTheme.green:
        return Colors.green.shade50;
      case AppTheme.purple:
        return Colors.purple.shade50;
    }
  }

  /// Get print button color based on theme
  static Color getLedgerPrintButtonColor(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return const Color(0xFF6366F1);
      case AppTheme.dark:
        return const Color(0xFF6366F1);
      case AppTheme.blue:
        return const Color(0xFF0EA5E9);
      case AppTheme.green:
        return const Color(0xFF10B981);
      case AppTheme.purple:
        return const Color(0xFF9333EA);
    }
  }

  static ThemeData _getLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.light,
      ),
      textTheme: _baseTextTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData _getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6366F1),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData _getBlueTheme() {
    const primaryColor = Color(0xFF0EA5E9);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: _baseTextTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData _getGreenTheme() {
    const primaryColor = Color(0xFF10B981);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: _baseTextTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.green.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.green.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static ThemeData _getPurpleTheme() {
    const primaryColor = Color(0xFF9333EA);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      textTheme: _baseTextTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.purple.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
