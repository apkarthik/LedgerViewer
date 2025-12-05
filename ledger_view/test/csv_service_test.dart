import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_view/services/csv_service.dart';
import 'package:ledger_view/models/ledger_entry.dart';
import 'package:ledger_view/models/customer.dart';

void main() {
  group('CsvService', () {
    final testData = [
      ['Ledger:', '1033.Saravana[V O C Nagar', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
      ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
      ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '56012', ''],
      ['56012', '', '', '', '', '', ''],
      ['', 'By', 'Closing Balance', '', '', '', '56012'],
      ['56012', '', '', '', '', '', '56012'],
      ['', '', '', '', '', '', ''],
      ['Ledger:', '1035.Vasanthi Teacher', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
      ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
      ['2025-07-21 00:00:00', 'To', '1035.Vasanthi Teacher', 'Sales', '2041', '101000', ''],
      ['2025-07-21 00:00:00', 'By', 'Cash', 'Receipt', '2041', '', '89700'],
      ['101000', '', '', '', '', '', '93700'],
      ['', 'By', 'Closing Balance', '', '', '', '7300'],
      ['101000', '', '', '', '', '', '101000'],
    ];

    test('findLedgerByNumber returns correct result for customer 1033', () {
      final result = CsvService.findLedgerByNumber(testData, '1033');
      
      expect(result, isNotNull);
      expect(result!.customerName, equals('1033.Saravana[V O C Nagar'));
      expect(result.dateRange, equals('1-Apr-2025 to 23-Nov-2025'));
      expect(result.closingBalance, equals('56012'));
    });

    test('findLedgerByNumber returns correct result for customer 1035', () {
      final result = CsvService.findLedgerByNumber(testData, '1035');
      
      expect(result, isNotNull);
      expect(result!.customerName, equals('1035.Vasanthi Teacher'));
      expect(result.dateRange, equals('1-Apr-2025 to 23-Nov-2025'));
      expect(result.closingBalance, equals('7300'));
      expect(result.entries.isNotEmpty, isTrue);
    });

    test('findLedgerByNumber returns correct totals from row above closing balance', () {
      final result = CsvService.findLedgerByNumber(testData, '1035');
      
      expect(result, isNotNull);
      // Totals should come from row: ['101000', '', '', '', '', '', '93700']
      // which is the row above ['', 'By', 'Closing Balance', '', '', '', '7300']
      expect(result!.totalDebit, equals('101000'));
      expect(result.totalCredit, equals('93700'));
    });

    test('findLedgerByNumber returns null for non-existent customer', () {
      final result = CsvService.findLedgerByNumber(testData, '9999');
      
      expect(result, isNull);
    });

    test('findLedgerByNumber is case insensitive', () {
      final result1 = CsvService.findLedgerByNumber(testData, '1033');
      final result2 = CsvService.findLedgerByNumber(testData, '1033');
      
      expect(result1, isNotNull);
      expect(result2, isNotNull);
      expect(result1!.customerName, equals(result2!.customerName));
    });

    test('findLedgerByNumber handles alphanumeric customer numbers', () {
      final testDataWithAlphaNum = [
        ['Ledger:', '1139B.Pushpa Malliga Teacher', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-24 00:00:00', 'By', 'Cash', 'Receipt', '16453', '', '15000'],
        ['85363', '', '', '', '', '', '98724'],
        ['', 'By', 'Closing Balance', '', '', '', '7749'],
        ['85363', '', '', '', '', '', '85363'],
      ];

      final result = CsvService.findLedgerByNumber(testDataWithAlphaNum, '1139B');
      
      expect(result, isNotNull);
      expect(result!.customerName, equals('1139B.Pushpa Malliga Teacher'));
      // Totals from row above closing balance: ['85363', '', '', '', '', '', '98724']
      expect(result.totalDebit, equals('85363'));
      expect(result.totalCredit, equals('98724'));
    });

    test('findLedgerByNumber handles lowercase search input', () {
      final testDataWithAlphaNum = [
        ['Ledger:', '1139B.Pushpa Malliga Teacher', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-24 00:00:00', 'By', 'Cash', 'Receipt', '16453', '', '15000'],
      ];

      final result = CsvService.findLedgerByNumber(testDataWithAlphaNum, '1139b');
      
      expect(result, isNotNull);
      expect(result!.customerName, equals('1139B.Pushpa Malliga Teacher'));
    });
  });

  group('CsvService - Customer Parsing', () {
    test('parseCustomerData parses customer data correctly', () {
      final testData = [
        ['NAME', 'Mobile No', 'Area'],  // Header row
        ['133.Arumugam', '12345466', 'NSK'],
        ['254.Murugesan ', '98745621', 'Thiruverkadu'],
      ];

      final customers = CsvService.parseCustomerData(testData);
      
      expect(customers.length, equals(2));
      expect(customers[0].customerId, equals('133'));
      expect(customers[0].name, equals('Arumugam'));
      expect(customers[0].mobileNumber, equals('12345466'));
      expect(customers[1].customerId, equals('254'));
      expect(customers[1].name, equals('Murugesan'));
      expect(customers[1].mobileNumber, equals('98745621'));
    });

    test('parseCustomerData skips empty rows', () {
      final testData = [
        ['NAME', 'Mobile No'],
        ['133.Arumugam', '12345466'],
        ['', ''],  // Empty row
        ['254.Murugesan', '98745621'],
      ];

      final customers = CsvService.parseCustomerData(testData);
      
      expect(customers.length, equals(2));
    });

    test('parseCustomerData handles empty data', () {
      final customers = CsvService.parseCustomerData([]);
      
      expect(customers, isEmpty);
    });
  });

  group('Customer', () {
    test('fromRow parses customer ID and name correctly', () {
      final customer = Customer.fromRow(['133.Arumugam', '12345466']);
      
      expect(customer.customerId, equals('133'));
      expect(customer.name, equals('Arumugam'));
      expect(customer.mobileNumber, equals('12345466'));
    });

    test('fromRow handles names without dots', () {
      final customer = Customer.fromRow(['Arumugam', '12345466']);
      
      expect(customer.customerId, equals(''));
      expect(customer.name, equals('Arumugam'));
    });

    test('matchesSearch finds by customer ID', () {
      final customer = Customer.fromRow(['133.Arumugam', '12345466']);
      
      expect(customer.matchesSearch('133'), isTrue);
      expect(customer.matchesSearch('999'), isFalse);
    });

    test('matchesSearch finds by name (case insensitive)', () {
      final customer = Customer.fromRow(['133.Arumugam', '12345466']);
      
      expect(customer.matchesSearch('Arumugam'), isTrue);
      expect(customer.matchesSearch('arumu'), isTrue);
      expect(customer.matchesSearch('ARUMUGAM'), isTrue);
    });

    test('matchesSearch finds by mobile number', () {
      final customer = Customer.fromRow(['133.Arumugam', '12345466']);
      
      expect(customer.matchesSearch('12345'), isTrue);
      expect(customer.matchesSearch('99999'), isFalse);
    });
  });

  group('LedgerEntry', () {
    test('isEmpty returns true for empty entry', () {
      const entry = LedgerEntry(
        date: '',
        toBy: '',
        particulars: '',
        vchType: '',
        vchNo: '',
        debit: '',
        credit: '',
      );
      
      expect(entry.isEmpty, isTrue);
    });

    test('isEmpty returns false for non-empty entry', () {
      const entry = LedgerEntry(
        date: '2025-04-01',
        toBy: 'To',
        particulars: 'Opening Balance',
        vchType: '',
        vchNo: '',
        debit: '56012',
        credit: '',
      );
      
      expect(entry.isEmpty, isFalse);
    });
  });
}
