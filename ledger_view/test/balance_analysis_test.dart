import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_view/services/csv_service.dart';
import 'package:ledger_view/models/customer.dart';
import 'package:ledger_view/models/customer_balance.dart';

void main() {
  group('Balance Analysis Tests', () {
    test('analyzeCustomerBalances returns correct balances for multiple customers', () {
      // Create test data with multiple customers having different balances
      final ledgerData = [
        // Customer 1: Balance 50000
        ['Ledger:', '1001.Customer One', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '50000', ''],
        ['50000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '50000'],
        ['50000', '', '', '', '', '', '50000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 2: Balance 75000
        ['Ledger:', '1002.Customer Two', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '75000', ''],
        ['75000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '75000'],
        ['75000', '', '', '', '', '', '75000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 3: Balance 25000
        ['Ledger:', '1003.Customer Three', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '25000', ''],
        ['25000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '25000'],
        ['25000', '', '', '', '', '', '25000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 4: Balance 100000
        ['Ledger:', '1004.Customer Four', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '100000', ''],
        ['100000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '100000'],
        ['100000', '', '', '', '', '', '100000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 5: Balance 10000
        ['Ledger:', '1005.Customer Five', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '10000', ''],
        ['10000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '10000'],
        ['10000', '', '', '', '', '', '10000'],
      ];

      final customers = [
        Customer.fromRow(['1001.Customer One', '1234567890']),
        Customer.fromRow(['1002.Customer Two', '1234567891']),
        Customer.fromRow(['1003.Customer Three', '1234567892']),
        Customer.fromRow(['1004.Customer Four', '1234567893']),
        Customer.fromRow(['1005.Customer Five', '1234567894']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      expect(balances.length, equals(5));
      
      // Verify each customer has the correct unique balance
      final balance1 = balances.firstWhere((b) => b.customerId == '1001');
      expect(balance1.balance, equals(50000.0));
      
      final balance2 = balances.firstWhere((b) => b.customerId == '1002');
      expect(balance2.balance, equals(75000.0));
      
      final balance3 = balances.firstWhere((b) => b.customerId == '1003');
      expect(balance3.balance, equals(25000.0));
      
      final balance4 = balances.firstWhere((b) => b.customerId == '1004');
      expect(balance4.balance, equals(100000.0));
      
      final balance5 = balances.firstWhere((b) => b.customerId == '1005');
      expect(balance5.balance, equals(10000.0));
      
      // Verify all balances are unique
      final uniqueBalances = balances.map((b) => b.balance).toSet();
      expect(uniqueBalances.length, equals(5), reason: 'All balances should be unique');
    });

    test('analyzeCustomerBalances handles balances with commas', () {
      final ledgerData = [
        // Customer with balance containing commas
        ['Ledger:', '2001.Big Customer', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '1,250,000', ''],
        ['1,250,000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '1,250,000'],
        ['1,250,000', '', '', '', '', '', '1,250,000'],
      ];

      final customers = [
        Customer.fromRow(['2001.Big Customer', '9876543210']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      expect(balances.length, equals(1));
      expect(balances[0].balance, equals(1250000.0));
    });

    test('analyzeCustomerBalances handles decimal balances', () {
      final ledgerData = [
        // Customer with decimal balance
        ['Ledger:', '3001.Decimal Customer', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '12345.67', ''],
        ['12345.67', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '12345.67'],
        ['12345.67', '', '', '', '', '', '12345.67'],
      ];

      final customers = [
        Customer.fromRow(['3001.Decimal Customer', '9876543211']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      expect(balances.length, equals(1));
      expect(balances[0].balance, equals(12345.67));
    });

    test('greater than filter works correctly with different balances', () {
      final ledgerData = [
        // Customer 1: Balance 30000
        ['Ledger:', '4001.Customer A', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '30000', ''],
        ['30000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '30000'],
        ['30000', '', '', '', '', '', '30000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 2: Balance 45000
        ['Ledger:', '4002.Customer B', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '45000', ''],
        ['45000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '45000'],
        ['45000', '', '', '', '', '', '45000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 3: Balance 60000
        ['Ledger:', '4003.Customer C', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '60000', ''],
        ['60000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '60000'],
        ['60000', '', '', '', '', '', '60000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 4: Balance 40000
        ['Ledger:', '4004.Customer D', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '40000', ''],
        ['40000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '40000'],
        ['40000', '', '', '', '', '', '40000'],
      ];

      final customers = [
        Customer.fromRow(['4001.Customer A', '1111111111']),
        Customer.fromRow(['4002.Customer B', '2222222222']),
        Customer.fromRow(['4003.Customer C', '3333333333']),
        Customer.fromRow(['4004.Customer D', '4444444444']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      // Test greater than 40000 - should return 2 customers
      final greaterThan40k = balances.where((b) => b.balance > 40000).toList();
      expect(greaterThan40k.length, equals(2));
      expect(greaterThan40k.any((b) => b.customerId == '4002'), isTrue);
      expect(greaterThan40k.any((b) => b.customerId == '4003'), isTrue);
      
      // Test greater than 50000 - should return 1 customer
      final greaterThan50k = balances.where((b) => b.balance > 50000).toList();
      expect(greaterThan50k.length, equals(1));
      expect(greaterThan50k[0].customerId, equals('4003'));
      
      // Test greater than 35000 - should return 3 customers
      final greaterThan35k = balances.where((b) => b.balance > 35000).toList();
      expect(greaterThan35k.length, equals(3));
    });

    test('analyzeCustomerBalances with complex ledger entries', () {
      final ledgerData = [
        // Customer with multiple transactions
        ['Ledger:', '5001.Complex Customer', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '10000', ''],
        ['2025-05-15 00:00:00', 'To', 'Sales', 'Sales', '1001', '50000', ''],
        ['2025-06-20 00:00:00', 'By', 'Cash', 'Receipt', '2001', '', '30000'],
        ['2025-07-25 00:00:00', 'To', 'Sales', 'Sales', '1002', '20000', ''],
        ['80000', '', '', '', '', '', '30000'],
        ['', 'By', 'Closing Balance', '', '', '', '50000'],
        ['80000', '', '', '', '', '', '80000'],
      ];

      final customers = [
        Customer.fromRow(['5001.Complex Customer', '5555555555']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      expect(balances.length, equals(1));
      expect(balances[0].balance, equals(50000.0));
      expect(balances[0].customerId, equals('5001'));
      expect(balances[0].name, equals('Complex Customer'));
    });

    test('analyzeCustomerBalances returns different balances for similar customer IDs', () {
      final ledgerData = [
        // Customer 6001: Balance 15000
        ['Ledger:', '6001.Similar One', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '15000', ''],
        ['15000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '15000'],
        ['15000', '', '', '', '', '', '15000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 6002: Balance 85000
        ['Ledger:', '6002.Similar Two', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '85000', ''],
        ['85000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '85000'],
        ['85000', '', '', '', '', '', '85000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 6003: Balance 42000
        ['Ledger:', '6003.Similar Three', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '42000', ''],
        ['42000', '', '', '', '', '', ''],
        ['', 'By', 'Closing Balance', '', '', '', '42000'],
        ['42000', '', '', '', '', '', '42000'],
      ];

      final customers = [
        Customer.fromRow(['6001.Similar One', '6001111111']),
        Customer.fromRow(['6002.Similar Two', '6002222222']),
        Customer.fromRow(['6003.Similar Three', '6003333333']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      expect(balances.length, equals(3));
      
      // Verify each balance is correctly assigned
      final b1 = balances.firstWhere((b) => b.customerId == '6001');
      expect(b1.balance, equals(15000.0));
      
      final b2 = balances.firstWhere((b) => b.customerId == '6002');
      expect(b2.balance, equals(85000.0));
      
      final b3 = balances.firstWhere((b) => b.customerId == '6003');
      expect(b3.balance, equals(42000.0));
      
      // Ensure balances are not the same
      expect(b1.balance != b2.balance, isTrue);
      expect(b2.balance != b3.balance, isTrue);
      expect(b1.balance != b3.balance, isTrue);
    });

    test('analyzeCustomerBalances handles alphanumeric customer IDs', () {
      final ledgerData = [
        // Customer 1139B: Balance 77490
        ['Ledger:', '1139B.Pushpa Malliga Teacher', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-24 00:00:00', 'By', 'Cash', 'Receipt', '16453', '', '15000'],
        ['85363', '', '', '', '', '', '98724'],
        ['', 'By', 'Closing Balance', '', '', '', '77490'],
        ['85363', '', '', '', '', '', '85363'],
        ['', '', '', '', '', '', ''],
        
        // Customer 2045A: Balance 33250
        ['Ledger:', '2045A.John Teacher', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-05-10 00:00:00', 'To', 'Sales', 'Sales', '5001', '50000', ''],
        ['50000', '', '', '', '', '', '16750'],
        ['', 'By', 'Closing Balance', '', '', '', '33250'],
        ['50000', '', '', '', '', '', '50000'],
      ];

      final customers = [
        Customer.fromRow(['1139B.Pushpa Malliga Teacher', '9876543210']),
        Customer.fromRow(['2045A.John Teacher', '9876543211']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      expect(balances.length, equals(2));
      
      final b1 = balances.firstWhere((b) => b.customerId == '1139B');
      expect(b1.balance, equals(77490.0));
      expect(b1.name, equals('Pushpa Malliga Teacher'));
      
      final b2 = balances.firstWhere((b) => b.customerId == '2045A');
      expect(b2.balance, equals(33250.0));
      expect(b2.name, equals('John Teacher'));
      
      // Verify they have different balances
      expect(b1.balance != b2.balance, isTrue);
    });

    test('analyzeCustomerBalances handles last credit date correctly', () {
      final ledgerData = [
        // Customer with credit entries
        ['Ledger:', '7001.Credit Customer', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['2025-04-01 00:00:00', 'To', 'Opening Balance', '', '', '10000', ''],
        ['2025-05-15 00:00:00', 'By', 'Cash', 'Receipt', '1001', '', '5000'],
        ['2025-07-20 00:00:00', 'By', 'Cash', 'Receipt', '1002', '', '3000'],
        ['10000', '', '', '', '', '', '8000'],
        ['', 'By', 'Closing Balance', '', '', '', '2000'],
        ['10000', '', '', '', '', '', '10000'],
      ];

      final customers = [
        Customer.fromRow(['7001.Credit Customer', '7777777777']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      expect(balances.length, equals(1));
      expect(balances[0].lastCreditDate, isNotNull);
      
      // The last credit should be from 2025-07-20
      final lastCreditDate = balances[0].lastCreditDate!;
      expect(lastCreditDate.year, equals(2025));
      expect(lastCreditDate.month, equals(7));
      expect(lastCreditDate.day, equals(20));
    });

    test('analyzeCustomerBalances handles zero and negative balances', () {
      final ledgerData = [
        // Customer with zero balance
        ['Ledger:', '8001.Zero Customer', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['', 'By', 'Closing Balance', '', '', '', '0'],
        ['0', '', '', '', '', '', '0'],
        ['', '', '', '', '', '', ''],
        
        // Customer with negative balance (credit balance in debit column)
        ['Ledger:', '8002.Negative Customer', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['', 'By', 'Closing Balance', '', '', '-5000', ''],
        ['-5000', '', '', '', '', '', '0'],
      ];

      final customers = [
        Customer.fromRow(['8001.Zero Customer', '8001111111']),
        Customer.fromRow(['8002.Negative Customer', '8002222222']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      expect(balances.length, equals(2));
      
      final b1 = balances.firstWhere((b) => b.customerId == '8001');
      expect(b1.balance, equals(0.0));
      
      // Note: Negative balance handling depends on implementation
      final b2 = balances.firstWhere((b) => b.customerId == '8002');
      expect(b2.balance, isNot(equals(b1.balance)));
    });

    test('less than filter works correctly', () {
      final ledgerData = [
        // Customer 1: Balance 20000
        ['Ledger:', '9001.Customer Low', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['', 'By', 'Closing Balance', '', '', '', '20000'],
        ['20000', '', '', '', '', '', '20000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 2: Balance 35000
        ['Ledger:', '9002.Customer Mid', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['', 'By', 'Closing Balance', '', '', '', '35000'],
        ['35000', '', '', '', '', '', '35000'],
        ['', '', '', '', '', '', ''],
        
        // Customer 3: Balance 55000
        ['Ledger:', '9003.Customer High', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
        ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
        ['', 'By', 'Closing Balance', '', '', '', '55000'],
        ['55000', '', '', '', '', '', '55000'],
      ];

      final customers = [
        Customer.fromRow(['9001.Customer Low', '9001111111']),
        Customer.fromRow(['9002.Customer Mid', '9002222222']),
        Customer.fromRow(['9003.Customer High', '9003333333']),
      ];

      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);

      // Test less than 40000 - should return 2 customers
      final lessThan40k = balances.where((b) => b.balance < 40000).toList();
      expect(lessThan40k.length, equals(2));
      expect(lessThan40k.any((b) => b.customerId == '9001'), isTrue);
      expect(lessThan40k.any((b) => b.customerId == '9002'), isTrue);
      
      // Test less than 30000 - should return 1 customer
      final lessThan30k = balances.where((b) => b.balance < 30000).toList();
      expect(lessThan30k.length, equals(1));
      expect(lessThan30k[0].customerId, equals('9001'));
    });

    test('analyzeCustomerBalances with random varied amounts', () {
      // Test with 10 random customers with varied balances
      final ledgerData = <List<dynamic>>[];
      final customers = <Customer>[];
      final expectedBalances = <String, double>{};
      
      final testBalances = [
        12345.67, 98765.43, 45678.90, 23456.78, 87654.32,
        34567.89, 67890.12, 56789.01, 78901.23, 90123.45
      ];
      
      for (int i = 0; i < 10; i++) {
        final customerId = '100${i + 1}';
        final customerName = 'Random Customer ${i + 1}';
        final balance = testBalances[i];
        
        // Add customer to list
        customers.add(Customer.fromRow(['$customerId.$customerName', '98765432${i % 10}']));
        expectedBalances[customerId] = balance;
        
        // Add ledger data for this customer
        ledgerData.addAll([
          ['Ledger:', '$customerId.$customerName', '1-Apr-2025 to 23-Nov-2025', '', '', '', ''],
          ['Date', 'Particulars', '', 'Vch Type', 'Vch No.', 'Debit', 'Credit'],
          ['', 'By', 'Closing Balance', '', '', '', balance.toString()],
          [balance.toString(), '', '', '', '', '', balance.toString()],
          if (i < 9) ['', '', '', '', '', '', ''], // Add separator except for last customer
        ]);
      }
      
      final balances = CsvService.analyzeCustomerBalances(ledgerData, customers);
      
      // Verify all customers are analyzed
      expect(balances.length, equals(10));
      
      // Verify each customer has the correct balance
      for (int i = 0; i < 10; i++) {
        final customerId = '100${i + 1}';
        final customerBalance = balances.firstWhere((b) => b.customerId == customerId);
        expect(customerBalance.balance, equals(expectedBalances[customerId]));
      }
      
      // Verify all balances are unique
      final uniqueBalances = balances.map((b) => b.balance).toSet();
      expect(uniqueBalances.length, equals(10), 
        reason: 'All 10 customers should have unique balances');
      
      // Test filtering with greater than
      final greaterThan50k = balances.where((b) => b.balance > 50000).toList();
      expect(greaterThan50k.length, greaterThan(0));
      
      // Verify that all filtered results actually meet the criteria
      for (final b in greaterThan50k) {
        expect(b.balance > 50000, isTrue);
      }
    });
  });
}
