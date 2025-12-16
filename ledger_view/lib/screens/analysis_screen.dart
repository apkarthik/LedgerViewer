import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../models/ledger_entry.dart';
import '../services/csv_service.dart';
import '../services/storage_service.dart';

/// Analysis screen for viewing customer balances
class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CustomerBalance> _allBalances = [];
  List<CustomerBalance> _filteredBalances = [];
  bool _isLoading = false;
  bool _hasLoadedData = false;
  String? _errorMessage;
  SortOption _currentSort = SortOption.nameAsc;

  @override
  void initState() {
    super.initState();
    _loadBalanceData();
  }

  Future<void> _loadBalanceData() async {
    final masterUrl = await StorageService.getMasterSheetUrl();
    final ledgerUrl = await StorageService.getLedgerSheetUrl();

    if (masterUrl == null || masterUrl.isEmpty || ledgerUrl == null || ledgerUrl.isEmpty) {
      setState(() {
        _errorMessage = 'Please configure Master and Ledger Sheet URLs in Settings first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch customer list and ledger data
      final customers = await CsvService.fetchCustomerData(masterUrl);
      final ledgerData = await CsvService.fetchCsvData(ledgerUrl);

      // Parse balance information for each customer
      final balances = <CustomerBalance>[];
      for (final customer in customers) {
        final ledgerResult = CsvService.findLedgerByNumber(ledgerData, customer.customerId);
        if (ledgerResult != null) {
          balances.add(CustomerBalance(
            customer: customer,
            totalDebit: ledgerResult.totalDebit,
            totalCredit: ledgerResult.totalCredit,
            closingBalance: ledgerResult.closingBalance,
          ));
        } else {
          // Add customer even if no ledger found (with zero balances)
          balances.add(CustomerBalance(
            customer: customer,
            totalDebit: '',
            totalCredit: '',
            closingBalance: '',
          ));
        }
      }

      setState(() {
        _allBalances = balances;
        _filteredBalances = balances;
        _isLoading = false;
        _hasLoadedData = true;
        _sortBalances();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading data: ${e.toString()}';
      });
    }
  }

  void _filterBalances(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredBalances = _allBalances;
      } else {
        _filteredBalances = _allBalances
            .where((balance) => balance.customer.matchesSearch(query))
            .toList();
      }
      _sortBalances();
    });
  }

  void _sortBalances() {
    switch (_currentSort) {
      case SortOption.nameAsc:
        _filteredBalances.sort((a, b) => a.customer.name.compareTo(b.customer.name));
        break;
      case SortOption.nameDesc:
        _filteredBalances.sort((a, b) => b.customer.name.compareTo(a.customer.name));
        break;
      case SortOption.balanceAsc:
        _filteredBalances.sort((a, b) {
          final balA = _parseAmount(a.closingBalance);
          final balB = _parseAmount(b.closingBalance);
          return balA.compareTo(balB);
        });
        break;
      case SortOption.balanceDesc:
        _filteredBalances.sort((a, b) {
          final balA = _parseAmount(a.closingBalance);
          final balB = _parseAmount(b.closingBalance);
          return balB.compareTo(balA);
        });
        break;
    }
  }

  double _parseAmount(String amount) {
    if (amount.isEmpty) return 0.0;
    try {
      return double.parse(amount.replaceAll(',', ''));
    } catch (e) {
      return 0.0;
    }
  }

  void _changeSortOption(SortOption? option) {
    if (option != null) {
      setState(() {
        _currentSort = option;
        _sortBalances();
      });
    }
  }

  String _formatAmount(String amount) {
    if (amount.isEmpty) return '0.00';
    return amount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer & Balance Analysis'),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBalanceData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search and Sort Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Search Box
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by ID, Name, or Mobile...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      _filterBalances('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: _filterBalances,
                        ),
                        const SizedBox(height: 12),
                        // Sort Options
                        Row(
                          children: [
                            const Icon(Icons.sort, size: 20),
                            const SizedBox(width: 8),
                            const Text('Sort by:', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButton<SortOption>(
                                value: _currentSort,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: SortOption.nameAsc,
                                    child: Text('Name (A-Z)'),
                                  ),
                                  DropdownMenuItem(
                                    value: SortOption.nameDesc,
                                    child: Text('Name (Z-A)'),
                                  ),
                                  DropdownMenuItem(
                                    value: SortOption.balanceAsc,
                                    child: Text('Balance (Low to High)'),
                                  ),
                                  DropdownMenuItem(
                                    value: SortOption.balanceDesc,
                                    child: Text('Balance (High to Low)'),
                                  ),
                                ],
                                onChanged: _changeSortOption,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Summary Card
                if (_hasLoadedData)
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryItem(
                            'Total Customers',
                            _filteredBalances.length.toString(),
                            Icons.people,
                          ),
                          _buildSummaryItem(
                            'With Balances',
                            _filteredBalances.where((b) => b.closingBalance.isNotEmpty).length.toString(),
                            Icons.account_balance_wallet,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                // Error message
                if (_errorMessage != null)
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Balance List
                if (_hasLoadedData)
                  Expanded(
                    child: Card(
                      margin: const EdgeInsets.only(top: 8),
                      child: Column(
                        children: [
                          // List Header
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Customer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Debit',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Credit',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Balance',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          // List Body
                          Expanded(
                            child: _filteredBalances.isEmpty
                                ? Center(
                                    child: Text(
                                      _searchController.text.isEmpty
                                          ? 'No customers found'
                                          : 'No customers match your search',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: _filteredBalances.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      final balance = _filteredBalances[index];
                                      return _buildBalanceRow(balance);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Empty state when data not loaded
                if (!_hasLoadedData && _errorMessage == null && !_isLoading)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/ledger_view_logo.png',
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.analytics_outlined,
                                size: 100,
                                color: Colors.grey.shade400,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading customer balance data...',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Loading indicator
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceRow(CustomerBalance balance) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  balance.customer.customerId,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  balance.customer.name,
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatAmount(balance.totalDebit),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatAmount(balance.totalCredit),
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatAmount(balance.closingBalance),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _parseAmount(balance.closingBalance) >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// Customer balance data
class CustomerBalance {
  final Customer customer;
  final String totalDebit;
  final String totalCredit;
  final String closingBalance;

  const CustomerBalance({
    required this.customer,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
  });
}

/// Sort options for the analysis screen
enum SortOption {
  nameAsc,
  nameDesc,
  balanceAsc,
  balanceDesc,
}
