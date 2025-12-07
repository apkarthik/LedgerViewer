import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _excelFilePathKey = 'excel_file_path';
  static const String _lastSearchKey = 'last_search';

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Migrate legacy CSV URL to new Ledger sheet URL (one-time migration)
  static Future<void> _migrateIfNeeded() async {
    final prefs = await _getPrefs();
    final migrationComplete = prefs.getBool(_migrationCompleteKey) ?? false;
    
    if (!migrationComplete) {
      final legacyUrl = prefs.getString(_csvUrlKey);
      final ledgerUrl = prefs.getString(_ledgerSheetUrlKey);
      
      // If there's a legacy URL and no ledger URL set, migrate it
      if (legacyUrl != null && legacyUrl.isNotEmpty && (ledgerUrl == null || ledgerUrl.isEmpty)) {
        await prefs.setString(_ledgerSheetUrlKey, legacyUrl);
      }
      
      await prefs.setBool(_migrationCompleteKey, true);
    }
  }

  /// Save the Excel file path or URL to persistent storage
  static Future<void> saveExcelFilePath(String path) async {
    final prefs = await _getPrefs();
    await prefs.setString(_excelFilePathKey, path);
  }

  /// Get the saved Excel file path or URL from persistent storage
  static Future<String?> getExcelFilePath() async {
    final prefs = await _getPrefs();
    return prefs.getString(_excelFilePathKey);
  }

  /// Save the last search query
  static Future<void> saveLastSearch(String query) async {
    final prefs = await _getPrefs();
    await prefs.setString(_lastSearchKey, query);
  }

  /// Get the last search query
  static Future<String?> getLastSearch() async {
    final prefs = await _getPrefs();
    return prefs.getString(_lastSearchKey);
  }

  /// Clear all settings (reset)
  static Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
