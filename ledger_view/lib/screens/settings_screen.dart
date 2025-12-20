import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../services/csv_service.dart';
import '../services/theme_service.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onSettingsSaved;

  const SettingsScreen({super.key, this.onSettingsSaved});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _masterSheetUrlController = TextEditingController();
  final TextEditingController _ledgerSheetUrlController = TextEditingController();
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final masterUrl = await StorageService.getMasterSheetUrl();
    final ledgerUrl = await StorageService.getLedgerSheetUrl();
    setState(() {
      if (masterUrl != null) {
        _masterSheetUrlController.text = masterUrl;
      }
      if (ledgerUrl != null) {
        _ledgerSheetUrlController.text = ledgerUrl;
      }
    });
  }

  Future<void> _saveSettings() async {
    final masterUrl = _masterSheetUrlController.text.trim();
    final ledgerUrl = _ledgerSheetUrlController.text.trim();

    if (masterUrl.isEmpty || ledgerUrl.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please provide both Master and Ledger Sheet URLs'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });
    
    try {
      // Save URLs first
      await StorageService.saveMasterSheetUrl(masterUrl);
      await StorageService.saveLedgerSheetUrl(ledgerUrl);

      // Fetch and cache Master data
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
                Text('Fetching Master data...'),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 30),
          ),
        );
      }
      
      final masterData = await CsvService.fetchCsvData(masterUrl);
      await StorageService.saveCachedMasterData(masterData);

      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Settings saved and master data cached successfully'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        
        // Notify that settings were saved
        widget.onSettingsSaved?.call();
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to clear all settings? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService.clearAll();
      setState(() {
        _masterSheetUrlController.clear();
        _ledgerSheetUrlController.clear();
        _hasChanges = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Settings reset successfully'),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  Future<void> _pasteFromClipboard(TextEditingController controller, String label) async {
    try {
      final data = await Clipboard.getData('text/plain');
      if (data != null && data.text != null) {
        setState(() {
          controller.text = data.text!;
          _hasChanges = true;
        });
        // Remove the snackbar notification to prevent duplicate alerts
        // The user can see the URL is pasted in the text field
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to paste: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions Card
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'To get the CSV URL for each sheet:\n1. Open your Google Sheet\n2. Go to File → Share → Publish to web\n3. Select the specific sheet (Master or Ledger)\n4. Choose CSV format and publish\n5. Copy the generated link',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Master Sheet URL Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.people,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Master Sheet URL',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'CSV link for Customer List (Master sheet)',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _masterSheetUrlController,
                          decoration: const InputDecoration(
                            hintText: 'https://docs.google.com/spreadsheets/d/.../Master',
                            prefixIcon: Icon(Icons.cloud_download),
                          ),
                          maxLines: 2,
                          keyboardType: TextInputType.url,
                          onChanged: (_) {
                            setState(() {
                              _hasChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _pasteFromClipboard(_masterSheetUrlController, 'Master Sheet'),
                            icon: const Icon(Icons.content_paste),
                            label: const Text('Paste from Clipboard'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: const BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Ledger Sheet URL Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.receipt_long,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ledger Sheet URL',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'CSV link for Ledger Data (Ledger sheet)',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _ledgerSheetUrlController,
                          decoration: const InputDecoration(
                            hintText: 'https://docs.google.com/spreadsheets/d/.../Ledger',
                            prefixIcon: Icon(Icons.cloud_download),
                          ),
                          maxLines: 2,
                          keyboardType: TextInputType.url,
                          onChanged: (_) {
                            setState(() {
                              _hasChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _pasteFromClipboard(_ledgerSheetUrlController, 'Ledger Sheet'),
                            icon: const Icon(Icons.content_paste),
                            label: const Text('Paste from Clipboard'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveSettings,
                    icon: _isSaving
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
                        : const Icon(Icons.save),
                    label: const Text('Save Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Reset Settings Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.restore,
                                color: Colors.red.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Reset Settings',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Clear all saved data and settings',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _resetSettings,
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Reset All Settings'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Theme Selection Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.palette,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'App Theme',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Choose your preferred color scheme',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Consumer<ThemeProvider>(
                          builder: (context, themeProvider, child) {
                            return DropdownButtonFormField<AppTheme>(
                              value: themeProvider.currentTheme,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  ThemeService.getThemeIcon(themeProvider.currentTheme),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: AppTheme.values.map((theme) {
                                return DropdownMenuItem<AppTheme>(
                                  value: theme,
                                  child: Row(
                                    children: [
                                      Icon(
                                        ThemeService.getThemeIcon(theme),
                                        size: 20,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(ThemeService.getThemeName(theme)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (AppTheme? theme) {
                                if (theme != null) {
                                  themeProvider.setTheme(theme);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Theme changed to ${ThemeService.getThemeName(theme)}'),
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App Info
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/ledger_view_logo.png',
                        width: 80,
                        height: 80,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'LedgerView',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.1.0',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }

  @override
  void dispose() {
    _masterSheetUrlController.dispose();
    _ledgerSheetUrlController.dispose();
    super.dispose();
  }
}
