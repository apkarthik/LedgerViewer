import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../models/customer_balance.dart';
import '../services/csv_service.dart';
import '../services/storage_service.dart';
import '../services/print_service.dart';
import 'home_screen.dart';

class BalanceAnalysisScreen extends StatefulWidget {
  const BalanceAnalysisScreen({super.key});

  @override
  State<BalanceAnalysisScreen> createState() => _BalanceAnalysisScreenState();
}

class _BalanceAnalysisScreenState extends State<BalanceAnalysisScreen> {
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<CustomerBalance> _allBalances = [];
  List<CustomerBalance> _filteredBalances = [];
  
  // Filter options
  String _balanceComparison = 'greater'; // 'greater' or 'less'
  bool _useBalanceFilter = false;
  bool _useDaysFilter = false;
  
  // Collapsible filter state
  bool _isFilterExpanded = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _analyzeBalances() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _filteredBalances = [];
    });

    try {
      // Get URLs
      final ledgerUrl = await StorageService.getLedgerSheetUrl();

      if (ledgerUrl == null || ledgerUrl.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please configure Ledger Sheet URL in Settings first';
        });
        return;
      }

      // Fetch ledger data
      final ledgerData = await CsvService.fetchCsvData(ledgerUrl);

      // Analyze balances - no longer requires master sheet
      // Customer information will be extracted directly from ledger data
      final balances = CsvService.analyzeCustomerBalances(ledgerData);

      setState(() {
        _allBalances = balances;
        _isLoading = false;
        _isFilterExpanded = false; // Collapse filters when showing results
      });

      // Apply filters
      _applyFilters();

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error analyzing balances: ${e.toString()}';
      });
    }
  }

  void _applyFilters() {
    if (_allBalances.isEmpty) return;

    List<CustomerBalance> filtered = List.from(_allBalances);

    // Filter out customers with zero balance
    filtered = filtered.where((cb) => cb.balance != 0).toList();

    // Apply balance filter
    if (_useBalanceFilter) {
      final balanceAmount = double.tryParse(_balanceController.text);
      if (balanceAmount != null) {
        filtered = filtered.where((cb) {
          if (_balanceComparison == 'greater') {
            return cb.balance > balanceAmount;
          } else {
            return cb.balance < balanceAmount;
          }
        }).toList();
      }
    }

    // Apply days filter
    if (_useDaysFilter) {
      final days = int.tryParse(_daysController.text);
      if (days != null && days > 0) {
        filtered = filtered.where((cb) {
          final daysSinceCredit = cb.daysSinceLastCredit;
          // Include customers with no credit history OR those with at least the specified days since last credit
          return daysSinceCredit == null || daysSinceCredit >= days;
        }).toList();
      }
    }

    setState(() {
      _filteredBalances = filtered;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _navigateToCustomerLedger(CustomerBalance customerBalance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          initialSearchQuery: customerBalance.customerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    final dateFormat = DateFormat('dd-MMM-yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Analysis'),
        automaticallyImplyLeading: false,
        actions: [
          if (_filteredBalances.isNotEmpty) ...[
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => _printAnalysis(context),
              tooltip: 'Print Analysis',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.share),
              tooltip: 'Share Analysis',
              onSelected: (value) => _shareAnalysis(context, value == 'image'),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Share as PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'image',
                  child: Row(
                    children: [
                      Icon(Icons.image, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('Share as Image'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
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
                // Filter Card
                Card(
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(
                        'Filter Options',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      leading: Icon(
                        _isFilterExpanded ? Icons.filter_alt : Icons.filter_alt_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      initiallyExpanded: _isFilterExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _isFilterExpanded = expanded;
                        });
                      },
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Balance Filter
                              CheckboxListTile(
                                value: _useBalanceFilter,
                                onChanged: (value) {
                                  setState(() {
                                    _useBalanceFilter = value ?? false;
                                  });
                                },
                                title: const Text('Filter by Balance Amount'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (_useBalanceFilter) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: DropdownButtonFormField<String>(
                                        value: _balanceComparison,
                                        decoration: const InputDecoration(
                                          labelText: 'Comparison',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'greater',
                                            child: Text('Greater than'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'less',
                                            child: Text('Less than'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _balanceComparison = value ?? 'greater';
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      flex: 1,
                                      child: TextField(
                                        controller: _balanceController,
                                        decoration: const InputDecoration(
                                          labelText: 'Amount',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        ),
                                        keyboardType: TextInputType.number,
                                      ),
                                    ),
                                  ],
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Days Filter
                              CheckboxListTile(
                                value: _useDaysFilter,
                                onChanged: (value) {
                                  setState(() {
                                    _useDaysFilter = value ?? false;
                                  });
                                },
                                title: const Text('Filter by Days without Credit'),
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              if (_useDaysFilter) ...[
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _daysController,
                                  decoration: const InputDecoration(
                                    labelText: 'Number of days (from today)',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    helperText: 'Shows customers with no credit entry for this many days',
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ],

                              const SizedBox(height: 16),

                              // Analyze Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : () {
                                    if (!_useBalanceFilter && !_useDaysFilter) {
                                      _showError('Please select at least one filter option');
                                      return;
                                    }
                                    if (_useBalanceFilter && _balanceController.text.isEmpty) {
                                      _showError('Please enter balance amount');
                                      return;
                                    }
                                    if (_useDaysFilter && _daysController.text.isEmpty) {
                                      _showError('Please enter number of days');
                                      return;
                                    }
                                    _analyzeBalances();
                                  },
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.analytics),
                                  label: Text(_isLoading ? 'Analyzing...' : 'Analyze'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

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

                // Results header
                if (_filteredBalances.isNotEmpty)
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Found ${_filteredBalances.length} customer(s) matching criteria',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Results List
                if (_filteredBalances.isNotEmpty)
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
                                    'Balance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Last Credit',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                const SizedBox(width: 40),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          // List Body
                          Expanded(
                            child: ListView.separated(
                              itemCount: _filteredBalances.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final customerBalance = _filteredBalances[index];
                                return _buildCustomerBalanceRow(
                                  customerBalance,
                                  currencyFormat,
                                  dateFormat,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Empty state
                if (_filteredBalances.isEmpty && _errorMessage == null && !_isLoading)
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
                            _allBalances.isEmpty
                                ? 'Select filter options and click "Analyze" to view results'
                                : 'No customers match the selected criteria',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerBalanceRow(
    CustomerBalance customerBalance,
    NumberFormat currencyFormat,
    DateFormat dateFormat,
  ) {
    final daysSinceCredit = customerBalance.daysSinceLastCredit;
    
    return InkWell(
      onTap: () => _navigateToCustomerLedger(customerBalance),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerBalance.customerId,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    customerBalance.name,
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
                currencyFormat.format(customerBalance.balance),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: customerBalance.balance >= 0 ? Colors.green.shade700 : Colors.red.shade700,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    customerBalance.lastCreditDate != null
                        ? dateFormat.format(customerBalance.lastCreditDate!)
                        : 'Never',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  if (daysSinceCredit != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '$daysSinceCredit days ago',
                      style: TextStyle(
                        fontSize: 10,
                        color: daysSinceCredit > 30 ? Colors.red.shade600 : Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () => _navigateToCustomerLedger(customerBalance),
                tooltip: 'View Ledger',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _printAnalysis(BuildContext context) async {
    try {
      await PrintService.printBalanceAnalysis(_filteredBalances);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Future<void> _shareAnalysis(BuildContext context, bool asImage) async {
    try {
      await PrintService.shareBalanceAnalysis(_filteredBalances, asImage: asImage);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _daysController.dispose();
    super.dispose();
  }
}
