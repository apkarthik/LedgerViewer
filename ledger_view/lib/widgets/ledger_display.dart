import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/ledger_entry.dart';
import '../services/print_service.dart';
import '../utils/voucher_type_mapper.dart';

class LedgerDisplay extends StatelessWidget {
  final LedgerResult result;

  const LedgerDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = themeProvider.currentTheme;
    final headerGradient = ThemeService.getLedgerHeaderGradient(currentTheme);
    final debitColor = ThemeService.getLedgerDebitColor(currentTheme);
    final creditColor = ThemeService.getLedgerCreditColor(currentTheme);
    final tableHeaderColor = ThemeService.getLedgerTableHeaderColor(currentTheme);
    final printButtonColor = ThemeService.getLedgerPrintButtonColor(currentTheme);

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: headerGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.customerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.dateRange,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Print Button
                IconButton(
                  onPressed: () => _printLedger(context),
                  icon: const Icon(Icons.print, color: Colors.white),
                  tooltip: 'Print Ledger',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),

          // Ledger entries
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Table Header
                  _buildTableHeader(tableHeaderColor),
                  const Divider(height: 1, thickness: 2),
                  
                  // Entries
                  ...result.entries.map((entry) => _buildEntryRow(entry, debitColor, creditColor)),
                  
                  const Divider(height: 1, thickness: 2),
                  
                  // Totals
                  _buildTotalsRow(debitColor, creditColor),
                  
                  const SizedBox(height: 8),
                  
                  // Balance
                  if (result.closingBalance.isNotEmpty)
                    _buildClosingBalance(creditColor),
                  
                  // Legend
                  if (result.closingBalance.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: const Text(
                        'S - Sales, P - Purchase, C - Cash Receipt, B - Bank Receipt, J - Journal',
                        style: TextStyle(
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Print Button at bottom
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _printLedger(context),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Ledger'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: printButtonColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printLedger(BuildContext context) async {
    try {
      await PrintService.printLedger(result);
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

  Widget _buildTableHeader(Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: backgroundColor,
      child: const Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Date',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Type',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'No',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Debit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Credit',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryRow(LedgerEntry entry, Color debitColor, Color creditColor) {
    final isDebit = entry.debit.isNotEmpty;
    final isCredit = entry.credit.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              _formatDateForDisplay(entry.date), // Format for display: 24-Apr-2025 → 24/04/25
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              VoucherTypeMapper.getVchTypeFirstLetter(entry.vchType, entry.particulars),
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.vchNo,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatAmount(entry.debit),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isDebit ? FontWeight.w600 : FontWeight.normal,
                color: isDebit ? debitColor : Colors.grey,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatAmount(entry.credit),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isCredit ? FontWeight.w600 : FontWeight.normal,
                color: isCredit ? creditColor : Colors.grey,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsRow(Color debitColor, Color creditColor) {
    return Column(
      children: [
        // Total Debit
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                debitColor.withOpacity(0.1),
                debitColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: debitColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Debit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: debitColor,
                ),
              ),
              Text(
                '₹ ${_formatAmount(result.totalDebit)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: debitColor,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Total Credit
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                creditColor.withOpacity(0.1),
                creditColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: creditColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Credit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: creditColor,
                ),
              ),
              Text(
                '₹ ${_formatAmount(result.totalCredit)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: creditColor,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClosingBalance(Color balanceColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            balanceColor.withOpacity(0.15),
            balanceColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: balanceColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Balance',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: balanceColor,
            ),
          ),
          Text(
            '₹ ${_formatAmount(result.closingBalance)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: balanceColor,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(String amount) {
    if (amount.isEmpty) return '-';
    
    // Try to parse and format the number
    try {
      final numValue = double.tryParse(amount.replaceAll(',', ''));
      if (numValue != null) {
        final formatter = NumberFormat('#,##,###.##', 'en_IN');
        return formatter.format(numValue);
      }
    } catch (e) {
      // Return original if parsing fails
    }
    
    return amount;
  }

  String _formatDateForDisplay(String dateStr) {
    if (dateStr.isEmpty) return '';
    
    try {
      // Date comes from CsvService._formatDate() in format "24-Apr-25"
      // Convert to dd/mm/yy format for display
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = _getMonthNumber(parts[1]); // Already zero-padded
          final year = parts[2].length == 4 ? parts[2].substring(2) : parts[2];
          return '$day/$month/$year';
        }
      }
      
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  String _getMonthNumber(String monthName) {
    const months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };
    return months[monthName] ?? monthName;
  }
}
