/// Utility class for voucher type mapping
class VoucherTypeMapper {
  /// List of bank keywords used to identify bank receipts
  static const List<String> _bankKeywords = ['bank', 'hdfc', 'icici', 'sbi', 'axis'];
  
  /// Map voucher type and particulars to a single letter code
  /// 
  /// Returns:
  /// - 'S' for Sales
  /// - 'P' for Purchase
  /// - 'J' for Journal
  /// - 'C' for Cash Receipts (when particulars contain "cash")
  /// - 'B' for Bank Receipts (when particulars contain bank-related keywords)
  /// - 'B' for all other types
  static String getVchTypeFirstLetter(String vchType, String particulars) {
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
      if (_isBankReceipt(particularsLower)) {
        return 'B';
      }
      // Default receipts to 'C' for cash (as per business requirement in sample_bill.xlsx)
      // This covers cash receipts and any other receipt types not explicitly categorized as bank
      return 'C';
    }
    
    // All other types return 'B'
    return 'B';
  }
  
  /// Check if particulars indicate a bank receipt
  static bool _isBankReceipt(String particularsLower) {
    return _bankKeywords.any((keyword) => particularsLower.contains(keyword));
  }
}
