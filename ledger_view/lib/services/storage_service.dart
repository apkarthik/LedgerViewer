import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _excelFilePathKey = 'excel_file_path';
  static const String _lastSearchKey = 'last_search';
  static const String _csvUrlKey = 'csv_url';
  static const String _masterSheetUrlKey = 'master_sheet_url';
  static const String _ledgerSheetUrlKey = 'ledger_sheet_url';
  static const String _migrationCompleteKey = 'migration_complete';
  static const String _publishedDocumentUrlKey = 'published_document_url';
  static const String _masterSheetGidKey = 'master_sheet_gid';
  static const String _ledgerSheetGidKey = 'ledger_sheet_gid';

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

  /// Save the published document base URL
  static Future<void> savePublishedDocumentUrl(String url) async {
    final prefs = await _getPrefs();
    await prefs.setString(_publishedDocumentUrlKey, url);
  }

  /// Get the published document base URL
  static Future<String?> getPublishedDocumentUrl() async {
    final prefs = await _getPrefs();
    return prefs.getString(_publishedDocumentUrlKey);
  }

  /// Save the Master sheet GID
  static Future<void> saveMasterSheetGid(String gid) async {
    final prefs = await _getPrefs();
    await prefs.setString(_masterSheetGidKey, gid);
  }

  /// Get the Master sheet GID
  static Future<String?> getMasterSheetGid() async {
    final prefs = await _getPrefs();
    return prefs.getString(_masterSheetGidKey);
  }

  /// Save the Ledger sheet GID
  static Future<void> saveLedgerSheetGid(String gid) async {
    final prefs = await _getPrefs();
    await prefs.setString(_ledgerSheetGidKey, gid);
  }

  /// Get the Ledger sheet GID
  static Future<String?> getLedgerSheetGid() async {
    final prefs = await _getPrefs();
    return prefs.getString(_ledgerSheetGidKey);
  }

  /// Build full sheet URL from published document URL and GID
  /// If GID is empty, returns the base URL
  static String buildSheetUrl(String baseUrl, String? gid) {
    final trimmedUrl = baseUrl.trim();
    
    if (gid == null || gid.trim().isEmpty) {
      return trimmedUrl;
    }
    
    final trimmedGid = gid.trim();
    
    // Check if URL already has query parameters
    if (trimmedUrl.contains('?')) {
      // Check if gid parameter already exists
      // Match gid parameter more precisely: at start of query string or after &
      if (RegExp(r'[?&]gid=').hasMatch(trimmedUrl)) {
        // Replace existing gid parameter
        // Uses pattern to match gid= at query string boundaries
        // Matches: ?gid=... or &gid=... followed by value until next & or end
        return trimmedUrl.replaceAllMapped(
          RegExp(r'([?&])gid=[^&]*'),
          (match) => '${match.group(1)}gid=$trimmedGid',
        );
      } else {
        // Add gid parameter
        return '$trimmedUrl&gid=$trimmedGid';
      }
    } else {
      // Add query parameters
      return '$trimmedUrl?output=csv&gid=$trimmedGid';
    }
  }

  /// Get the effective Master sheet URL
  /// Returns either the direct URL or constructed URL from published document URL + GID
  static Future<String?> getEffectiveMasterSheetUrl() async {
    // First check if there's a direct master sheet URL (backward compatibility)
    final directUrl = await getMasterSheetUrl();
    if (directUrl != null && directUrl.trim().isNotEmpty) {
      return directUrl;
    }
    
    // Otherwise, construct from published document URL + GID
    final baseUrl = await getPublishedDocumentUrl();
    final gid = await getMasterSheetGid();
    
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return null;
    }
    
    return buildSheetUrl(baseUrl, gid);
  }

  /// Get the effective Ledger sheet URL
  /// Returns either the direct URL or constructed URL from published document URL + GID
  static Future<String?> getEffectiveLedgerSheetUrl() async {
    await _migrateIfNeeded();  // Ensure migration runs before getting URL
    
    // First check if there's a direct ledger sheet URL (backward compatibility)
    final directUrl = await getLedgerSheetUrl();
    if (directUrl != null && directUrl.trim().isNotEmpty) {
      return directUrl;
    }
    
    // Otherwise, construct from published document URL + GID
    final baseUrl = await getPublishedDocumentUrl();
    final gid = await getLedgerSheetGid();
    
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return null;
    }
    
    return buildSheetUrl(baseUrl, gid);
  }

  /// Clear all settings (reset)
  static Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
