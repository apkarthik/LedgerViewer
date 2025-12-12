import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../models/customer.dart';
import '../services/csv_service.dart';
import '../services/storage_service.dart';
import '../widgets/ledger_display.dart';

class HomeScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final VoidCallback? onSettingsTap;

  const HomeScreen({super.key, this.initialSearchQuery, this.onSettingsTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const int _minSearchChars = 3; // Minimum characters to trigger autocomplete
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  LedgerResult? _ledgerResult;
  List<Customer> _allCustomers = [];
  bool _hasLoadedCustomers = false;
  bool _hasLoadedLedgerData = false;
  bool _autoSearchTriggered = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    // Try to load cached customer data
    final cachedData = await StorageService.getCachedMasterData();
    final cachedLedgerData = await StorageService.getCachedLedgerData();
    
    if (cachedData != null) {
      final customers = CsvService.parseCustomerData(cachedData);
      setState(() {
        _allCustomers = customers;
        _hasLoadedCustomers = customers.isNotEmpty;
        _hasLoadedLedgerData = cachedLedgerData != null && cachedLedgerData.isNotEmpty;
      });
      
      // If initialSearchQuery is provided, use it
      if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
        _searchController.text = widget.initialSearchQuery!;
        if (!_autoSearchTriggered) {
          _autoSearchTriggered = true;
          _searchLedger();
        }
      }
    }
  }

  Future<void> _searchLedger() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();
    
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      _showError('Please enter a customer number or name');
      return;
    }

    // Check if we have cached ledger data
    final cachedLedgerData = await StorageService.getCachedLedgerData();
    if (cachedLedgerData == null || cachedLedgerData.isEmpty) {
      _showError('No data available. Please configure and save settings first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _ledgerResult = null;
    });

    try {
      // Save the search query
      await StorageService.saveLastSearch(searchQuery);

      // Find the ledger for the searched number or name
      final result = CsvService.findLedgerByNumber(cachedLedgerData, searchQuery);

      if (result != null) {
        setState(() {
          _ledgerResult = result;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No ledger found for "$searchQuery"';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ledger Search'),
        automaticallyImplyLeading: false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: widget.onSettingsTap,
            tooltip: 'Go to Settings',
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
                // Search Card with Autocomplete
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Customer Ledger',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1F2937),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter customer number or name',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Autocomplete<Customer>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            // Only show suggestions after typing at least minimum characters
                            if (textEditingValue.text.isEmpty || textEditingValue.text.length < _minSearchChars) {
                              return const Iterable<Customer>.empty();
                            }
                            final query = textEditingValue.text.toLowerCase();
                            return _allCustomers.where((Customer customer) {
                              return customer.customerId.toLowerCase().contains(query) ||
                                  customer.name.toLowerCase().contains(query);
                            });
                          },
                          displayStringForOption: (Customer customer) {
                            return '${customer.customerId} - ${customer.name}';
                          },
                          onSelected: (Customer customer) {
                            _searchController.text = customer.customerId;
                            _searchLedger();
                          },
                          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                            // Sync our controller with the autocomplete controller
                            _searchController.text = controller.text;
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'e.g., 1139B or Pushpa',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: controller.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          controller.clear();
                                          _searchController.clear();
                                          setState(() {
                                            _ledgerResult = null;
                                            _errorMessage = null;
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              textCapitalization: TextCapitalization.characters,
                              onSubmitted: (_) {
                                _searchController.text = controller.text;
                                _searchLedger();
                              },
                              onChanged: (value) {
                                _searchController.text = value;
                                setState(() {});
                              },
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  width: MediaQuery.of(context).size.width - 32,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final customer = options.elementAt(index);
                                      return ListTile(
                                        title: Text(
                                          customer.customerId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF6366F1),
                                          ),
                                        ),
                                        subtitle: Text(customer.name),
                                        trailing: customer.mobileNumber.isNotEmpty
                                            ? Text(
                                                customer.mobileNumber,
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              )
                                            : null,
                                        onTap: () {
                                          onSelected(customer);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Status indicator
                if (!_hasLoadedLedgerData)
                  Card(
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber, color: Colors.amber.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No data available. Please configure and save settings first.',
                              style: TextStyle(color: Colors.amber.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

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

                // Ledger display
                if (_ledgerResult != null)
                  Expanded(
                    child: LedgerDisplay(result: _ledgerResult!),
                  ),

                // Empty state
                if (_ledgerResult == null && _errorMessage == null && !_isLoading)
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
                                Icons.receipt_long,
                                size: 100,
                                color: Colors.grey.shade400,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _hasLoadedCustomers
                                ? 'Enter a customer number or name to view their ledger'
                                : 'Configure settings to get started',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
