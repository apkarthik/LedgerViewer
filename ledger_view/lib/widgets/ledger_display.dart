import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ledger_entry.dart';
import '../services/print_service.dart';

class LedgerDisplay extends StatelessWidget {
  final LedgerResult result;

  const LedgerDisplay({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
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
                          color: Colors.white.withValues(alpha: 0.9),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                  _buildTableHeader(),
                  const Divider(height: 1, thickness: 2),
                  
                  // Entries
                  ...result.entries.map((entry) => _buildEntryRow(entry)),
                  
                  const Divider(height: 1, thickness: 2),
                  
                  // Totals
                  _buildTotalsRow(),
                  
                  const SizedBox(height: 8),
                  
                  // Closing Balance
                  if (result.closingBalance.isNotEmpty)
                    _buildClosingBalance(),
                  
                  const SizedBox(height: 16),
                  
                  // Print Button at bottom
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _printLedger(context),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Ledger'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
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

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: Colors.grey.shade100,
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
            flex: 4,
            child: Text(
              'Particulars',
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

  Widget _buildEntryRow(LedgerEntry entry) {
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
              entry.date,
              style: const TextStyle(fontSize: 10),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.toBy.isNotEmpty)
                  Text(
                    entry.toBy,
                    style: TextStyle(
                      fontSize: 10,
                      color: entry.toBy.toLowerCase() == 'to' 
                          ? Colors.red.shade700 
                          : Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Text(
                  entry.particulars,
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              entry.vchType,
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
                color: isDebit ? Colors.red.shade700 : Colors.grey,
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
                color: isCredit ? Colors.green.shade700 : Colors.grey,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          const Expanded(
            flex: 9,
            child: Text(
              'TOTAL',
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
              _formatAmount(result.totalDebit),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.red.shade700,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatAmount(result.totalCredit),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.green.shade700,
                fontFamily: 'monospace',
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingBalance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.1),
            const Color(0xFF059669).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Closing Balance',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF065F46),
            ),
          ),
          Text(
            '₹ ${_formatAmount(result.closingBalance)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF065F46),
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
}
