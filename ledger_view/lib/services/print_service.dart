import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/ledger_entry.dart';

class PrintService {
  static Future<void> printLedger(LedgerResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Header
            pw.Center(
              child: pw.Text(
                'LEDGER STATEMENT',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),

            // Customer Info
            pw.Text(
              'Customer: ${result.customerName}',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Period: ${result.dateRange}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 16),

            // Table Header
            pw.Container(
              color: PdfColors.grey200,
              padding: const pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Date',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Particulars',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      'Type',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Debit',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Credit',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            // Table Rows
            ...result.entries.map((entry) => _buildEntryRow(entry)),

            // Divider
            pw.Divider(thickness: 2),

            // Totals Row
            pw.Container(
              color: PdfColors.grey100,
              padding: const pw.EdgeInsets.all(8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 6,
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      _formatAmount(result.totalDebit),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      _formatAmount(result.totalCredit),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 16),

            // Closing Balance
            if (result.closingBalance.isNotEmpty)
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.green50,
                  border: pw.Border.all(color: PdfColors.green),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Closing Balance',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      'Rs. ${_formatAmount(result.closingBalance)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _buildEntryRow(LedgerEntry entry) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              entry.date,
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (entry.toBy.isNotEmpty)
                  pw.Text(
                    entry.toBy,
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                pw.Text(
                  entry.particulars,
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ),
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              entry.vchType,
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              _formatAmount(entry.debit),
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              _formatAmount(entry.credit),
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(String amount) {
    if (amount.isEmpty) return '-';

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
