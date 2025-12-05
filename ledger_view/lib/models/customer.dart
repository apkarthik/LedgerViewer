/// Represents a customer with their details
class Customer {
  final String customerId;
  final String name;
  final String mobileNumber;

  const Customer({
    required this.customerId,
    required this.name,
    required this.mobileNumber,
  });

  /// Parse customer data from a row where column A contains "CustomerID.Name" format
  /// and column B contains the mobile number
  factory Customer.fromRow(List<dynamic> row) {
    final fullName = row.isNotEmpty ? row[0].toString().trim() : '';
    final mobile = row.length > 1 ? row[1].toString().trim() : '';

    // Split "CustomerID.Name" format
    String customerId = '';
    String name = '';

    if (fullName.contains('.')) {
      final dotIndex = fullName.indexOf('.');
      customerId = fullName.substring(0, dotIndex).trim();
      name = fullName.substring(dotIndex + 1).trim();
    } else {
      // If no dot, treat the whole thing as name
      name = fullName;
    }

    return Customer(
      customerId: customerId,
      name: name,
      mobileNumber: mobile,
    );
  }

  /// Check if customer matches search query (case-insensitive)
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return customerId.toLowerCase().contains(lowerQuery) ||
        name.toLowerCase().contains(lowerQuery) ||
        mobileNumber.toLowerCase().contains(lowerQuery);
  }

  @override
  String toString() {
    return 'Customer(id: $customerId, name: $name, mobile: $mobileNumber)';
  }
}
