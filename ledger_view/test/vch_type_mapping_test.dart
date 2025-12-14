import 'package:flutter_test/flutter_test.dart';

// Helper function to simulate _getVchTypeFirstLetter logic
String getVchTypeFirstLetter(String vchType, String particulars) {
  if (vchType.isEmpty) return '';
  
  // Map voucher types according to legend: S-Sales, P-Purchase, C-Cash Receipt, B-Bank Receipt, J-Journal
  final type = vchType.toLowerCase();
  if (type.startsWith('sales')) return 'S';
  if (type.startsWith('purchase')) return 'P';
  if (type.startsWith('journal')) return 'J';
  
  // For receipts, distinguish between Cash (C) and Bank (B)
  if (type.startsWith('receipt')) {
    final particularsLower = particulars.toLowerCase();
    // Check if it's a cash receipt
    if (particularsLower.contains('cash')) {
      return 'C';
    }
    // Check if it's a bank receipt (contains 'bank' or common bank names)
    if (particularsLower.contains('bank') || 
        particularsLower.contains('hdfc') ||
        particularsLower.contains('icici') ||
        particularsLower.contains('sbi') ||
        particularsLower.contains('axis')) {
      return 'B';
    }
    // Default receipts to 'C' for cash (as per business requirement in sample_bill.xlsx)
    // This covers cash receipts and any other receipt types not explicitly categorized as bank
    return 'C';
  }
  
  // All other types return 'B'
  return 'B';
}

void main() {
  group('Voucher Type Mapping', () {
    test('Sales should map to S', () {
      expect(getVchTypeFirstLetter('Sales', '1525.Egabharm'), equals('S'));
    });

    test('Purchase should map to P', () {
      expect(getVchTypeFirstLetter('Purchase', 'Gold Purchase-GST'), equals('P'));
    });

    test('Journal should map to J', () {
      expect(getVchTypeFirstLetter('Journal', '5k16_Savings_Krishnan'), equals('J'));
    });

    test('Cash receipt should map to C', () {
      expect(getVchTypeFirstLetter('Receipt', 'Cash'), equals('C'));
    });

    test('Bank receipt with "Bank" should map to B', () {
      expect(getVchTypeFirstLetter('Receipt', 'HDFC Bank - OD'), equals('B'));
      expect(getVchTypeFirstLetter('Receipt', 'HDFC Bank - Current'), equals('B'));
    });

    test('Bank receipt with bank name HDFC should map to B', () {
      expect(getVchTypeFirstLetter('Receipt', 'HDFC OD Account'), equals('B'));
    });

    test('Bank receipt with bank name ICICI should map to B', () {
      expect(getVchTypeFirstLetter('Receipt', 'ICICI Current'), equals('B'));
    });

    test('Bank receipt with bank name SBI should map to B', () {
      expect(getVchTypeFirstLetter('Receipt', 'SBI Savings'), equals('B'));
    });

    test('Bank receipt with bank name Axis should map to B', () {
      expect(getVchTypeFirstLetter('Receipt', 'Axis Bank Account'), equals('B'));
    });

    test('Receipt without cash or bank defaults to C', () {
      expect(getVchTypeFirstLetter('Receipt', 'Some Other Particulars'), equals('C'));
    });

    test('Case insensitive matching for cash', () {
      expect(getVchTypeFirstLetter('Receipt', 'CASH'), equals('C'));
      expect(getVchTypeFirstLetter('Receipt', 'cash payment'), equals('C'));
    });

    test('Case insensitive matching for bank', () {
      expect(getVchTypeFirstLetter('Receipt', 'BANK TRANSFER'), equals('B'));
      expect(getVchTypeFirstLetter('Receipt', 'hdfc bank'), equals('B'));
    });

    test('Other voucher types should map to B', () {
      expect(getVchTypeFirstLetter('Payment', 'Some Payment'), equals('B'));
      expect(getVchTypeFirstLetter('Contra', 'Some Contra'), equals('B'));
    });

    test('Empty voucher type should return empty string', () {
      expect(getVchTypeFirstLetter('', 'Some Particulars'), equals(''));
    });
  });
}
