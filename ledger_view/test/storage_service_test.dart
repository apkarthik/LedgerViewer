import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_view/services/storage_service.dart';

void main() {
  group('StorageService - buildSheetUrl', () {
    test('returns base URL when GID is null', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      final result = StorageService.buildSheetUrl(baseUrl, null);
      
      expect(result, equals(baseUrl));
    });

    test('returns base URL when GID is empty', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      final result = StorageService.buildSheetUrl(baseUrl, '');
      
      expect(result, equals(baseUrl));
    });

    test('adds gid parameter to URL with existing query params', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      const gid = '123456789';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      expect(result, equals('$baseUrl&gid=$gid'));
    });

    test('replaces existing gid parameter in URL', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv&gid=0';
      const gid = '123456789';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      expect(result, equals('https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv&gid=$gid'));
    });

    test('adds query params and gid when URL has no query params', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub';
      const gid = '123456789';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      expect(result, equals('${baseUrl}?output=csv&gid=$gid'));
    });

    test('trims whitespace from URL and GID', () {
      const baseUrl = '  https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv  ';
      const gid = '  123456789  ';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      expect(result, equals('https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv&gid=123456789'));
    });

    test('handles GID 0 (first sheet)', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv';
      const gid = '0';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      expect(result, equals('$baseUrl&gid=0'));
    });

    test('replaces non-numeric GID in URL', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv&gid=sheet1';
      const gid = 'newsheet';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      expect(result, equals('https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv&gid=newsheet'));
    });

    test('trims baseUrl even when GID is null', () {
      const baseUrl = '  https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv  ';
      final result = StorageService.buildSheetUrl(baseUrl, null);
      
      expect(result, equals('https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv'));
    });

    test('trims baseUrl even when GID is empty', () {
      const baseUrl = '  https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv  ';
      final result = StorageService.buildSheetUrl(baseUrl, '  ');
      
      expect(result, equals('https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv'));
    });

    test('does not match partial parameter names like mygid', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv&mygid=123';
      const gid = '456';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      // Should add gid parameter, not replace mygid
      expect(result, equals('$baseUrl&gid=$gid'));
    });

    test('replaces gid at start of query string', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?gid=0&output=csv';
      const gid = '123';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      expect(result, equals('https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?gid=$gid&output=csv'));
    });

    test('replaces gid in middle of query string', () {
      const baseUrl = 'https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv&gid=0&single=true';
      const gid = '123';
      final result = StorageService.buildSheetUrl(baseUrl, gid);
      
      expect(result, equals('https://docs.google.com/spreadsheets/d/e/2PACX-abc/pub?output=csv&gid=$gid&single=true'));
    });
  });
}
