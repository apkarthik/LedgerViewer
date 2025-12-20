import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../models/customer.dart';
import '../services/csv_service.dart';
import '../services/storage_service.dart';
import '../services/print_service.dart';
import '../widgets/ledger_display.dart';

class HomeScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final VoidCallback? onSettingsTap;

  const HomeScreen({super.key, this.initialSearchQuery, this.onSettingsTap});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const int _minSearchChars = 1; // Minimum characters to trigger autocomplete
  static const Duration _refreshTimeout = Duration(seconds: 15);
  static final RegExp _phoneNormalizationRegex = RegExp(r'[\s\-\+\(\)]');
  
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  LedgerResult? _ledgerResult;
  Customer? _selectedCustomer;
  List<Customer> _allCustomers = [];
  bool _hasLoadedCustomers = false;
  bool _hasLedgerUrl = false;
  bool _autoSearchTriggered = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerData();
  }

  /// Public method to reload customer data from storage
  /// Called when settings are saved to refresh the UI
  void reloadData() {
    _loadCustomerData();
  }

  Future<void> _loadCustomerData() async {
    // Try to load cached customer data
    final cachedData = await StorageService.getCachedMasterData();
    final ledgerUrl = await StorageService.getLedgerSheetUrl();
    
    if (cachedData != null) {
      final customers = CsvService.parseCustomerData(cachedData);
      setState(() {
        _allCustomers = customers;
        _hasLoadedCustomers = customers.isNotEmpty;
        _hasLedgerUrl = ledgerUrl != null && ledgerUrl.isNotEmpty;
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
      _showError('Please enter a customer number, name, or mobile number');
      return;
    }

    // Get ledger sheet URL to fetch real-time data
    final ledgerUrl = await StorageService.getLedgerSheetUrl();
    if (ledgerUrl == null || ledgerUrl.isEmpty) {
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

      // Fetch fresh ledger data from Google Sheets (real-time)
      final ledgerData = await CsvService.fetchCsvData(ledgerUrl);
      
      // Update cached ledger data (for reference, but always fetch fresh on search)
      await StorageService.saveCachedLedgerData(ledgerData);

      // First, check if search query matches a mobile number in the customer list
      // Normalize phone numbers by removing common formatting characters
      final normalizedSearchQuery = searchQuery.replaceAll(_phoneNormalizationRegex, '');
      String actualSearchQuery = searchQuery;
      Customer? foundCustomer;
      
      final matchedCustomer = _allCustomers.firstWhere(
        (customer) {
          final normalizedMobile = customer.mobileNumber.replaceAll(_phoneNormalizationRegex, '');
          return normalizedMobile == normalizedSearchQuery;
        },
        orElse: () => const Customer(customerId: '', name: '', mobileNumber: ''),
      );
      
      // If we found a customer by mobile number, use their customer ID for ledger search
      if (matchedCustomer.customerId.isNotEmpty) {
        actualSearchQuery = matchedCustomer.customerId;
        foundCustomer = matchedCustomer;
      } else {
        // Try to find customer by ID or name
        final upperSearchQuery = searchQuery.toUpperCase();
        foundCustomer = _allCustomers.firstWhere(
          (customer) => 
            customer.customerId.toUpperCase() == upperSearchQuery ||
            customer.name.toUpperCase().contains(upperSearchQuery),
          orElse: () => const Customer(customerId: '', name: '', mobileNumber: ''),
        );
        if (foundCustomer.customerId.isEmpty) {
          foundCustomer = null;
        }
      }

      // Find the ledger for the searched number or name
      final result = CsvService.findLedgerByNumber(ledgerData, actualSearchQuery);

      if (result != null) {
        setState(() {
          _ledgerResult = result;
          _selectedCustomer = foundCustomer;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No ledger found for "$searchQuery"';
          _selectedCustomer = null;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
        _selectedCustomer = null;
      });
    }
  }

  Future<void> _refreshLedgerData() async {
    // Get only master sheet URL (refresh should only take master data)
    final masterUrl = await StorageService.getMasterSheetUrl();
    
    if (masterUrl == null || masterUrl.isEmpty) {
      _showError('Please configure Master Sheet URL in Settings first');
      return;
    }

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Refreshing master data from Google Sheets...'),
            ],
          ),
          backgroundColor: Colors.blue.shade600,
          behavior: SnackBarBehavior.floating,
          duration: _refreshTimeout,
        ),
      );
    }

    try {
      // Fetch only master data
      final masterData = await CsvService.fetchCsvData(masterUrl);
      
      // Update the cached master data
      await StorageService.saveCachedMasterData(masterData);

      // Parse and update customer list
      final customers = CsvService.parseCustomerData(masterData);
      
      // Update state to reflect we have master data
      setState(() {
        _allCustomers = customers;
        _hasLoadedCustomers = customers.isNotEmpty;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Master data refreshed successfully'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
            onPressed: _refreshLedgerData,
            tooltip: 'Refresh Master Data',
          ),
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
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Autocomplete<Customer>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            // Only show suggestions after typing at least minimum characters
                            if (textEditingValue.text.isEmpty || textEditingValue.text.length < _minSearchChars) {
                              return const Iterable<Customer>.empty();
                            }
                            final query = textEditingValue.text.toLowerCase();
                            return _allCustomers.where((Customer customer) {
                              return customer.customerId.toLowerCase().contains(query) ||
                                  customer.name.toLowerCase().contains(query) ||
                                  customer.mobileNumber.toLowerCase().contains(query) ||
                                  customer.area.toLowerCase().contains(query);
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
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                hintText: 'e.g., 1139B, Pushpa, or 9876543210',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: controller.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          controller.clear();
                                          _searchController.clear();
                                          setState(() {
                                            _ledgerResult = null;
                                            _selectedCustomer = null;
                                            _errorMessage = null;
                                          });
                                          // Request focus after clearing
                                          focusNode.requestFocus();
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
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Material(
                                  elevation: 8.0,
                                  borderRadius: BorderRadius.circular(8.0),
                                  color: Colors.white,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight: 200,
                                      maxWidth: MediaQuery.of(context).size.width - 72,
                                    ),
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: options.length,
                                      itemBuilder: (context, index) {
                                        final customer = options.elementAt(index);
                                        return ListTile(
                                          dense: true,
                                          title: Text(
                                            customer.customerId,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context).colorScheme.primary,
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
                if (!_hasLedgerUrl)
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

                // Customer Master Details (shown when customer is found)
                if (_selectedCustomer != null)
                  Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        initiallyExpanded: false,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Customer Details',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.share, size: 20),
                              onPressed: () => _shareCustomerDetails(context),
                              tooltip: 'Share Customer Details',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.print, size: 20),
                              onPressed: () => _printCustomerDetails(context),
                              tooltip: 'Print Customer Details',
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const Icon(Icons.expand_more),
                          ],
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('Customer ID', _selectedCustomer!.customerId),
                                const SizedBox(height: 8),
                                _buildDetailRow('Name', _selectedCustomer!.name),
                                if (_selectedCustomer!.mobileNumber.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow('Mobile Number', _selectedCustomer!.mobileNumber),
                                ],
                                if (_selectedCustomer!.area.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow('Area', _selectedCustomer!.area),
                                ],
                                if (_selectedCustomer!.gpay.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  _buildDetailRow('GPAY', _selectedCustomer!.gpay),
                                ],
                              ],
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
                                ? 'Enter a customer number, name, or mobile number to view their ledger'
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareCustomerDetails(BuildContext context) async {
    if (_selectedCustomer == null) return;
    
    try {
      await PrintService.shareCustomerDetails(_selectedCustomer!);
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

  Future<void> _printCustomerDetails(BuildContext context) async {
    if (_selectedCustomer == null) return;
    
    try {
      await PrintService.printCustomerDetails(_selectedCustomer!);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
