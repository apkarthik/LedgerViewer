import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _csvUrlKey = 'csv_url';
  static const String _masterSheetUrlKey = 'master_sheet_url';
  static const String _ledgerSheetUrlKey = 'ledger_sheet_url';
  static const String _lastSearchKey = 'last_search';

  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  /// Save the CSV URL to persistent storage (legacy - kept for backward compatibility)
  static Future<void> saveCsvUrl(String url) async {
    final prefs = await _getPrefs();
    await prefs.setString(_csvUrlKey, url);
  }

  /// Get the saved CSV URL from persistent storage (legacy - kept for backward compatibility)
  static Future<String?> getCsvUrl() async {
    final prefs = await _getPrefs();
    return prefs.getString(_csvUrlKey);
  }

  /// Save the Master sheet URL to persistent storage
  static Future<void> saveMasterSheetUrl(String url) async {
    final prefs = await _getPrefs();
    await prefs.setString(_masterSheetUrlKey, url);
  }

  /// Get the saved Master sheet URL from persistent storage
  static Future<String?> getMasterSheetUrl() async {
    final prefs = await _getPrefs();
    return prefs.getString(_masterSheetUrlKey);
  }

  /// Save the Ledger sheet URL to persistent storage
  static Future<void> saveLedgerSheetUrl(String url) async {
    final prefs = await _getPrefs();
    await prefs.setString(_ledgerSheetUrlKey, url);
  }

  /// Get the saved Ledger sheet URL from persistent storage
  static Future<String?> getLedgerSheetUrl() async {
    final prefs = await _getPrefs();
    return prefs.getString(_ledgerSheetUrlKey);
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
