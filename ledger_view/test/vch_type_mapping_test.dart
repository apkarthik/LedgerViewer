import 'package:flutter_test/flutter_test.dart';
import 'package:ledger_view/utils/voucher_type_mapper.dart';

void main() {
  group('Voucher Type Mapping', () {
    test('Sales should map to S', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Sales', '1525.Egabharm'), equals('S'));
    });

    test('Purchase should map to P', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Purchase', 'Gold Purchase-GST'), equals('P'));
    });

    test('Journal should map to J', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Journal', '5k16_Savings_Krishnan'), equals('J'));
    });

    test('Cash receipt should map to C', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'Cash'), equals('C'));
    });

    test('Bank receipt with "Bank" should map to B', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'HDFC Bank - OD'), equals('B'));
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'HDFC Bank - Current'), equals('B'));
    });

    test('Bank receipt with bank name HDFC should map to B', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'HDFC OD Account'), equals('B'));
    });

    test('Bank receipt with bank name ICICI should map to B', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'ICICI Current'), equals('B'));
    });

    test('Bank receipt with bank name SBI should map to B', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'SBI Savings'), equals('B'));
    });

    test('Bank receipt with bank name Axis should map to B', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'Axis Bank Account'), equals('B'));
    });

    test('Receipt without cash or bank defaults to C', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'Some Other Particulars'), equals('C'));
    });

    test('Case insensitive matching for cash', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'CASH'), equals('C'));
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'cash payment'), equals('C'));
    });

    test('Case insensitive matching for bank', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'BANK TRANSFER'), equals('B'));
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Receipt', 'hdfc bank'), equals('B'));
    });

    test('Other voucher types should map to B', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Payment', 'Some Payment'), equals('B'));
      expect(VoucherTypeMapper.getVchTypeFirstLetter('Contra', 'Some Contra'), equals('B'));
    });

    test('Empty voucher type should return empty string', () {
      expect(VoucherTypeMapper.getVchTypeFirstLetter('', 'Some Particulars'), equals(''));
    });
  });
}
