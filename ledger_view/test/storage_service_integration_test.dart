import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ledger_view/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService - URL Construction Integration', () {
    setUp(() async {
      // Clear shared preferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('getEffectiveMasterSheetUrl returns constructed URL from base + GID', () async {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      const gid = '0';
      
      await StorageService.savePublishedDocumentUrl(baseUrl);
      await StorageService.saveMasterSheetGid(gid);
      
      final effectiveUrl = await StorageService.getEffectiveMasterSheetUrl();
      
      expect(effectiveUrl, equals('$baseUrl&gid=$gid'));
    });

    test('getEffectiveMasterSheetUrl returns direct URL when available', () async {
      const directUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-direct/pub?gid=0&single=true&output=csv';
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      const gid = '0';
      
      await StorageService.saveMasterSheetUrl(directUrl);
      await StorageService.savePublishedDocumentUrl(baseUrl);
      await StorageService.saveMasterSheetGid(gid);
      
      final effectiveUrl = await StorageService.getEffectiveMasterSheetUrl();
      
      // Should return direct URL (backward compatibility)
      expect(effectiveUrl, equals(directUrl));
    });

    test('getEffectiveLedgerSheetUrl returns constructed URL from base + GID', () async {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      const gid = '123456789';
      
      await StorageService.savePublishedDocumentUrl(baseUrl);
      await StorageService.saveLedgerSheetGid(gid);
      
      final effectiveUrl = await StorageService.getEffectiveLedgerSheetUrl();
      
      expect(effectiveUrl, equals('$baseUrl&gid=$gid'));
    });

    test('getEffectiveLedgerSheetUrl returns direct URL when available', () async {
      const directUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-direct/pub?gid=123&single=true&output=csv';
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      const gid = '123456789';
      
      await StorageService.saveLedgerSheetUrl(directUrl);
      await StorageService.savePublishedDocumentUrl(baseUrl);
      await StorageService.saveLedgerSheetGid(gid);
      
      final effectiveUrl = await StorageService.getEffectiveLedgerSheetUrl();
      
      // Should return direct URL (backward compatibility)
      expect(effectiveUrl, equals(directUrl));
    });

    test('getEffectiveMasterSheetUrl returns null when no URLs configured', () async {
      final effectiveUrl = await StorageService.getEffectiveMasterSheetUrl();
      
      expect(effectiveUrl, isNull);
    });

    test('getEffectiveMasterSheetUrl uses base URL without GID when GID is empty', () async {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      
      await StorageService.savePublishedDocumentUrl(baseUrl);
      await StorageService.saveMasterSheetGid('');
      
      final effectiveUrl = await StorageService.getEffectiveMasterSheetUrl();
      
      expect(effectiveUrl, equals(baseUrl));
    });

    test('Integration: Complete workflow with provided example URL', () async {
      const exampleUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vTzfIpRjg7ALjbYM0P_Ueb0J2VXEG_ILPls-vCMhMxU8fiSZQYPeLu16OTBD6EYDQ/pub?output=csv';
      const masterGid = '0';
      const ledgerGid = '123456789';
      
      await StorageService.savePublishedDocumentUrl(exampleUrl);
      await StorageService.saveMasterSheetGid(masterGid);
      await StorageService.saveLedgerSheetGid(ledgerGid);
      
      final masterUrl = await StorageService.getEffectiveMasterSheetUrl();
      final ledgerUrl = await StorageService.getEffectiveLedgerSheetUrl();
      
      expect(masterUrl, equals('$exampleUrl&gid=$masterGid'));
      expect(ledgerUrl, equals('$exampleUrl&gid=$ledgerGid'));
    });
  });
}
