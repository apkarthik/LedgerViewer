/// Model for customer balance analysis
class CustomerBalance {
  final String customerId;
  final String name;
  final String mobileNumber;
  final double balance;
  final DateTime? lastCreditDate;

  const CustomerBalance({
    required this.customerId,
    required this.name,
    required this.mobileNumber,
    required this.balance,
    this.lastCreditDate,
  });

  /// Get the number of days since the last credit entry
  /// Returns null if there is no last credit date
  int? get daysSinceLastCredit {
    if (lastCreditDate == null) return null;
    final now = DateTime.now();
    return now.difference(lastCreditDate!).inDays;
  }

  @override
  String toString() {
    return 'CustomerBalance(id: $customerId, name: $name, balance: $balance, lastCreditDate: $lastCreditDate)';
  }
}
