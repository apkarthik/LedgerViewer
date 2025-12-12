import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _excelFilePathController = TextEditingController();
  final TextEditingController _masterSheetUrlController = TextEditingController();
  final TextEditingController _ledgerSheetUrlController = TextEditingController();
  final TextEditingController _publishedDocumentUrlController = TextEditingController();
  final TextEditingController _masterSheetGidController = TextEditingController();
  final TextEditingController _ledgerSheetGidController = TextEditingController();
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final excelPath = await StorageService.getExcelFilePath();
    final masterUrl = await StorageService.getMasterSheetUrl();
    final ledgerUrl = await StorageService.getLedgerSheetUrl();
    final publishedUrl = await StorageService.getPublishedDocumentUrl();
    final masterGid = await StorageService.getMasterSheetGid();
    final ledgerGid = await StorageService.getLedgerSheetGid();
    setState(() {
      if (excelPath != null) {
        _excelFilePathController.text = excelPath;
      }
      if (masterUrl != null) {
        _masterSheetUrlController.text = masterUrl;
      }
      if (ledgerUrl != null) {
        _ledgerSheetUrlController.text = ledgerUrl;
      }
      if (publishedUrl != null) {
        _publishedDocumentUrlController.text = publishedUrl;
      }
      if (masterGid != null) {
        _masterSheetGidController.text = masterGid;
      }
      if (ledgerGid != null) {
        _ledgerSheetGidController.text = ledgerGid;
      }
    });
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });
    try {
      await StorageService.saveExcelFilePath(_excelFilePathController.text.trim());
      await StorageService.saveMasterSheetUrl(_masterSheetUrlController.text.trim());
      await StorageService.saveLedgerSheetUrl(_ledgerSheetUrlController.text.trim());
      await StorageService.savePublishedDocumentUrl(_publishedDocumentUrlController.text.trim());
      await StorageService.saveMasterSheetGid(_masterSheetGidController.text.trim());
      await StorageService.saveLedgerSheetGid(_ledgerSheetGidController.text.trim());
      setState(() {
        _isSaving = false;
        _hasChanges = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Settings saved successfully'),
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
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
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
        _excelFilePathController.clear();
        _masterSheetUrlController.clear();
        _ledgerSheetUrlController.clear();
        _publishedDocumentUrlController.clear();
        _masterSheetGidController.clear();
        _ledgerSheetGidController.clear();
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label pasted from clipboard'),
              backgroundColor: Colors.blue.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
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
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Excel File Path/URL Card
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
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.insert_drive_file,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Excel File Path or URL',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Provide the path or URL to the Excel file containing both Master and Ledger sheets.',
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
                        controller: _excelFilePathController,
                        decoration: const InputDecoration(
                          hintText: '/path/to/ledger_file.xlsx or https://.../ledger_file.xlsx',
                          prefixIcon: Icon(Icons.insert_drive_file),
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
                          onPressed: () => _pasteFromClipboard(_excelFilePathController, 'Excel File Path'),
                          icon: const Icon(Icons.content_paste),
                          label: const Text('Paste from Clipboard'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Published Document URL Section (Simplified approach)
              Card(
                color: Colors.purple.shade50,
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
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.article,
                              color: Colors.purple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📋 Simplified: Published Document URL',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple.shade900,
                                      ),
                                ),
                                Text(
                                  'One URL for entire document + Sheet GIDs (easier option)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.purple.shade700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _publishedDocumentUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Published Document URL',
                          hintText: 'https://docs.google.com/.../pub?output=csv',
                          prefixIcon: Icon(Icons.link),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _masterSheetGidController,
                              decoration: const InputDecoration(
                                labelText: 'Master Sheet GID',
                                hintText: '0 (optional)',
                                prefixIcon: Icon(Icons.tag),
                              ),
                              keyboardType: TextInputType.text,
                              onChanged: (_) {
                                setState(() {
                                  _hasChanges = true;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _ledgerSheetGidController,
                              decoration: const InputDecoration(
                                labelText: 'Ledger Sheet GID',
                                hintText: '123456789 (optional)',
                                prefixIcon: Icon(Icons.tag),
                              ),
                              keyboardType: TextInputType.text,
                              onChanged: (_) {
                                setState(() {
                                  _hasChanges = true;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _pasteFromClipboard(_publishedDocumentUrlController, 'Published Document URL'),
                          icon: const Icon(Icons.content_paste),
                          label: const Text('Paste from Clipboard'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.purple,
                            side: const BorderSide(color: Colors.purple),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: Colors.purple.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tip: Publish entire document, then specify sheet GIDs.\nFind GID in sheet URL: .../edit#gid=123456789\nLeave GID empty to use first sheet.',
                                style: TextStyle(
                                  color: Colors.purple.shade900,
                                  fontSize: 12,
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

              // OR Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),

              const SizedBox(height: 16),

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
                          'Advanced: To get the CSV URL for each sheet separately:\n1. Open your Google Sheet\n2. Go to File → Share → Publish to web\n3. Select the specific sheet (Master or Ledger)\n4. Choose CSV format and publish\n5. Copy the generated link',
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
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.receipt_long,
                                color: Color(0xFF6366F1),
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
                              foregroundColor: const Color(0xFF6366F1),
                              side: const BorderSide(color: Color(0xFF6366F1)),
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
                      backgroundColor: const Color(0xFF6366F1),
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
                              color: const Color(0xFF1F2937),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
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
    _excelFilePathController.dispose();
    _masterSheetUrlController.dispose();
    _ledgerSheetUrlController.dispose();
    _publishedDocumentUrlController.dispose();
    _masterSheetGidController.dispose();
    _ledgerSheetGidController.dispose();
    super.dispose();
  }
}
