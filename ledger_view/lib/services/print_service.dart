import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/ledger_entry.dart';
import '../models/customer.dart';
import '../utils/voucher_type_mapper.dart';

class PrintService {
  // Thermal printer paper format (58mm width)
  // 58mm = 164.4 points at 72 DPI
  static const thermalPageFormat = PdfPageFormat(
    164.4, // 58mm width
    double.infinity, // Continuous feed
    marginAll: 4, // Minimal margins for thermal printers
  );

  // Column widths optimized for 58mm thermal printer
  // Total available width: 164.4 - (4*2) = 156.4 points
  static const double dateWidth = 42.0;
  static const double typeWidth = 10.0;
  static const double noWidth = 20.0;
  static const double debitWidth = 42.0;
  static const double creditWidth = 42.0;

  static pw.Document _generateLedgerPdf(LedgerResult result) {
    final pdf = pw.Document();

    // Text style for narrow font (using condensed spacing)
    final narrowTextStyle = pw.TextStyle(
      fontSize: 8,
      letterSpacing: -0.3, // Negative letter spacing for condensed effect
    );
    final narrowBoldTextStyle = pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: -0.3,
    );

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
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 8, letterSpacing: -0.2),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 3),

              // Customer Info
              pw.Text(
                'Customer:',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: -0.2,
                ),
              ),
              pw.Text(
                result.customerName,
                style: const pw.TextStyle(fontSize: 8, letterSpacing: -0.2),
              ),
              pw.SizedBox(height: 1),
              pw.Text(
                'Period: ${result.dateRange}',
                style: const pw.TextStyle(fontSize: 7, letterSpacing: -0.2),
              ),
              pw.SizedBox(height: 6),

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
                      width: dateWidth,
                      child: pw.Text(
                        'Date',
                        style: narrowBoldTextStyle,
                      ),
                    ),
                    pw.SizedBox(
                      width: typeWidth,
                      child: pw.Text(
                        'Tp',
                        style: narrowBoldTextStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(
                      width: noWidth,
                      child: pw.Text(
                        'No',
                        style: narrowBoldTextStyle,
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.SizedBox(
                      width: debitWidth,
                      child: pw.Text(
                        'Debit',
                        style: narrowBoldTextStyle,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.SizedBox(
                      width: creditWidth,
                      child: pw.Text(
                        'Credit',
                        style: narrowBoldTextStyle,
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

              // Total Debit
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Debit',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                        letterSpacing: -0.2,
                      ),
                    ),
                    pw.Text(
                      'Rs. ${_formatAmount(result.totalDebit)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 3),

              // Total Credit
              pw.Container(
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Credit',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                        letterSpacing: -0.2,
                      ),
                    ),
                    pw.Text(
                      'Rs. ${_formatAmount(result.totalCredit)}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),

              // Balance
              if (result.closingBalance.isNotEmpty)
                pw.Container(
                  padding: const pw.EdgeInsets.all(4),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Balance',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: -0.2,
                        ),
                      ),
                      pw.Text(
                        'Rs. ${_formatAmount(result.closingBalance)}',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),

              // Legend
              if (result.closingBalance.isNotEmpty)
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 4),
                  child: pw.Text(
                    'S - Sales, P - Purchase, C - Cash Receipt, B - Bank Receipt, J - Journal',
                    style: const pw.TextStyle(fontSize: 7, letterSpacing: -0.2),
                    textAlign: pw.TextAlign.left,
                  ),
                ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static Future<void> printLedger(LedgerResult result) async {
    final pdf = _generateLedgerPdf(result);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static Future<void> shareLedger(LedgerResult result) async {
    final pdf = _generateLedgerPdf(result);

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'ledger_${result.customerName.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Document _generateCustomerDetailsPdf(Customer customer) {
    final pdf = pw.Document();

    // Text style for customer details
    final normalTextStyle = pw.TextStyle(
      fontSize: 8,
      letterSpacing: -0.2,
    );
    final boldTextStyle = pw.TextStyle(
      fontSize: 8,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: -0.2,
    );

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
                  'CUSTOMER DETAILS',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 8, letterSpacing: -0.2),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 6),

              // Customer ID
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 60,
                    child: pw.Text('Customer ID', style: boldTextStyle),
                  ),
                  pw.Text(': ', style: normalTextStyle),
                  pw.Expanded(
                    child: pw.Text(customer.customerId, style: normalTextStyle),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),

              // Name
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    width: 60,
                    child: pw.Text('Name', style: boldTextStyle),
                  ),
                  pw.Text(': ', style: normalTextStyle),
                  pw.Expanded(
                    child: pw.Text(customer.name, style: normalTextStyle),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),

              // Mobile Number
              if (customer.mobileNumber.isNotEmpty) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 60,
                      child: pw.Text('Mobile', style: boldTextStyle),
                    ),
                    pw.Text(': ', style: normalTextStyle),
                    pw.Expanded(
                      child: pw.Text(customer.mobileNumber, style: normalTextStyle),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
              ],

              // Area
              if (customer.area.isNotEmpty) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 60,
                      child: pw.Text('Area', style: boldTextStyle),
                    ),
                    pw.Text(': ', style: normalTextStyle),
                    pw.Expanded(
                      child: pw.Text(customer.area, style: normalTextStyle),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
              ],

              // GPAY
              if (customer.gpay.isNotEmpty) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 60,
                      child: pw.Text('GPAY', style: boldTextStyle),
                    ),
                    pw.Text(': ', style: normalTextStyle),
                    pw.Expanded(
                      child: pw.Text(customer.gpay, style: normalTextStyle),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static Future<void> printCustomerDetails(Customer customer) async {
    final pdf = _generateCustomerDetailsPdf(customer);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static Future<void> shareCustomerDetails(Customer customer) async {
    final pdf = _generateCustomerDetailsPdf(customer);

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'customer_${customer.customerId}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
    );
  }

  static pw.Widget _buildEntryRow(LedgerEntry entry) {
    final narrowTextStyle = pw.TextStyle(
      fontSize: 7,
      letterSpacing: -0.3,
    );
    
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: dateWidth,
            child: pw.Text(
              _formatDateShort(entry.date),
              style: narrowTextStyle,
            ),
          ),
          pw.SizedBox(
            width: typeWidth,
            child: pw.Text(
              VoucherTypeMapper.getVchTypeFirstLetter(entry.vchType, entry.particulars),
              style: narrowTextStyle,
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: noWidth,
            child: pw.Text(
              entry.vchNo,
              style: narrowTextStyle,
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(
            width: debitWidth,
            child: pw.Text(
              _formatAmount(entry.debit),
              style: narrowTextStyle,
              textAlign: pw.TextAlign.right,
            ),
          ),
          pw.SizedBox(
            width: creditWidth,
            child: pw.Text(
              _formatAmount(entry.credit),
              style: narrowTextStyle,
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDateShort(String dateStr) {
    if (dateStr.isEmpty) return '';
    
    try {
      // Date comes from CsvService._formatDate() in format "24-Apr-25"
      // Convert to dd/mm/yy format for thermal printer (e.g., "24/04/25")
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final day = parts[0].padLeft(2, '0');
          final monthNum = _getMonthNumber(parts[1]); // Already zero-padded
          final rawYear = parts[2];
          final year = rawYear.length >= 2
            ? rawYear.substring(rawYear.length - 2)
            : rawYear.padLeft(2, '0');
          return '$day/$monthNum/$year';
        }
      }
      
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  static String _getMonthNumber(String monthName) {
    const months = {
      'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
      'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
      'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
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
