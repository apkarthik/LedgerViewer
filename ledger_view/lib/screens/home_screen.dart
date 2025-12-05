import 'package:flutter/material.dart';
import '../models/ledger_entry.dart';
import '../services/csv_service.dart';
import '../services/storage_service.dart';
import '../widgets/ledger_display.dart';

class HomeScreen extends StatefulWidget {
  final String? initialSearchQuery;

  const HomeScreen({super.key, this.initialSearchQuery});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  LedgerResult? _ledgerResult;
  String? _csvUrl;
  bool _autoSearchTriggered = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final url = await StorageService.getLedgerSheetUrl();
    final lastSearch = await StorageService.getLastSearch();
    setState(() {
      _csvUrl = url;
      // If initialSearchQuery is provided, use it instead of last search
      if (widget.initialSearchQuery != null && widget.initialSearchQuery!.isNotEmpty) {
        _searchController.text = widget.initialSearchQuery!;
      } else if (lastSearch != null && lastSearch.isNotEmpty) {
        _searchController.text = lastSearch;
      }
    });
    
    // Auto-trigger search if initialSearchQuery is provided
    if (widget.initialSearchQuery != null && 
        widget.initialSearchQuery!.isNotEmpty && 
        !_autoSearchTriggered &&
        _csvUrl != null &&
        _csvUrl!.isNotEmpty) {
      _autoSearchTriggered = true;
      _searchLedger();
    }
  }

  Future<void> _searchLedger() async {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();
    
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      _showError('Please enter a customer number');
      return;
    }

    if (_csvUrl == null || _csvUrl!.isEmpty) {
      _showError('Please configure Ledger Sheet URL in Settings');
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

      // Fetch fresh data from Google Drive
      final csvData = await CsvService.fetchCsvData(_csvUrl!);

      // Find the ledger for the searched number
      final result = CsvService.findLedgerByNumber(csvData, searchQuery);

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
                // Search Card
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
                          'Enter customer number to view ledger details',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'e.g., 1139B',
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
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
                                onSubmitted: (_) => _searchLedger(),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _isLoading ? null : _searchLedger,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6366F1),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text('Search'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Status indicator
                if (_csvUrl == null || _csvUrl!.isEmpty)
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
                              'Please configure Ledger Sheet URL in Settings to start searching',
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
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter a customer number to view their ledger',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
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
