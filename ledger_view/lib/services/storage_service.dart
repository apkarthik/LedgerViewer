import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _excelFilePathKey = 'excel_file_path';
  static const String _lastSearchKey = 'last_search';
  static const String _csvUrlKey = 'csv_url';
  static const String _masterSheetUrlKey = 'master_sheet_url';
  static const String _ledgerSheetUrlKey = 'ledger_sheet_url';
  static const String _migrationCompleteKey = 'migration_complete';

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

  /// Save the Master sheet URL
  static Future<void> saveMasterSheetUrl(String url) async {
    final prefs = await _getPrefs();
    await prefs.setString(_masterSheetUrlKey, url);
  }

  /// Get the Master sheet URL
  static Future<String?> getMasterSheetUrl() async {
    final prefs = await _getPrefs();
    return prefs.getString(_masterSheetUrlKey);
  }

  /// Save the Ledger sheet URL
  static Future<void> saveLedgerSheetUrl(String url) async {
    final prefs = await _getPrefs();
    await prefs.setString(_ledgerSheetUrlKey, url);
  }

  /// Get the Ledger sheet URL
  static Future<String?> getLedgerSheetUrl() async {
    await _migrateIfNeeded();  // Ensure migration runs before getting URL
    final prefs = await _getPrefs();
    return prefs.getString(_ledgerSheetUrlKey);
  }

  /// Clear all settings (reset)
  static Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
