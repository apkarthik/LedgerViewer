import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/ledger_entry.dart';

class PrintService {
  // Thermal printer paper format (58mm width)
  // 58mm = 164.4 points at 72 DPI
  static const thermalPageFormat = PdfPageFormat(
    164.4, // 58mm width
    double.infinity, // Continuous feed
    marginAll: 6, // Small margins for thermal printers
  );

  static Future<void> printLedger(LedgerResult result) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: thermalPageFormat,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'LEDGER STATEMENT',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 4),

              // Customer Info
              pw.Text(
                'Customer:',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                result.customerName,
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Period: ${result.dateRange}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 8),

              // Table Header
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 1),
                  ),
                ),
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 28,
                      child: pw.Text(
                        'Dt',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    pw.SizedBox(
                      width: 12,
                      child: pw.Text(
                        'Tp',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(
                      width: 28,
                      child: pw.Text(
                        'No',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Debit',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Credit',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
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
              pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(width: 1),
                  ),
                ),
                margin: const pw.EdgeInsets.only(top: 4),
              ),

              // Totals Row
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  children: [
                    pw.SizedBox(
                      width: 68, // Dt + Tp + No columns (28 + 12 + 28)
                      child: pw.Text(
                        'TOTAL',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                        textAlign: pw.TextAlign.left,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(right: 4),
                        child: pw.Text(
                          _formatAmount(result.totalDebit),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 4),
                        child: pw.Text(
                          _formatAmount(result.totalCredit),
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // Closing Balance
              if (result.closingBalance.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Closing Balance',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${_formatAmount(result.closingBalance)}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

              // Legend
              if (result.closingBalance.isNotEmpty)
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 6),
                  child: pw.Text(
                    'S - Sales, P - Purchase, C - Receipt, J - Journal, B - all others',
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.left,
                  ),
                ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static pw.Widget _buildEntryRow(LedgerEntry entry) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 28,
            child: pw.Text(
              _formatDateShort(entry.date),
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          pw.SizedBox(
            width: 12,
            child: pw.Text(
              _getVchTypeFirstLetter(entry.vchType),
              style: const pw.TextStyle(fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: 28,
            child: pw.Text(
              entry.vchNo,
              style: const pw.TextStyle(fontSize: 8),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              _formatAmount(entry.debit),
              style: const pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.Expanded(
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

  static String _getVchTypeFirstLetter(String vchType) {
    if (vchType.isEmpty) return '';
    return vchType[0].toUpperCase();
  }

  static String _formatDateShort(String dateStr) {
    if (dateStr.isEmpty) return '';
    
    try {
      // Date comes from CsvService._formatDate() in format "24-Apr-2025"
      // Convert to dd/mm/yy format for display
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final month = _getMonthNumber(parts[1]).padLeft(2, '0');
          final year = parts[2].length == 4 ? parts[2].substring(2) : parts[2];
          return '$day/$month/$year';
        }
      }
      
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  static String _getMonthNumber(String monthName) {
    const months = {
      'Jan': '1', 'Feb': '2', 'Mar': '3', 'Apr': '4',
      'May': '5', 'Jun': '6', 'Jul': '7', 'Aug': '8',
      'Sep': '9', 'Oct': '10', 'Nov': '11', 'Dec': '12'
    };
    return months[monthName] ?? monthName;
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
