import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cross_file/cross_file.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../models/ledger_entry.dart';
import '../models/customer.dart';
import '../models/customer_balance.dart';
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
  static const int _rgbChannelCount = 3;

  static Future<void> printLedger(LedgerResult result) async {
    final pdf = await _generateLedgerPdf(result);

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  static Future<void> printCustomerDetails(Customer customer) async {
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

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
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

  /// Share ledger as PDF or image
  static Future<void> shareLedger(LedgerResult result, {bool asImage = false}) async {
    try {
      final pdf = await _generateLedgerPdf(result);
      final pdfBytes = await pdf.save();
      
      // Create meaningful filename
      final customerParts = result.customerName.split('.');
      final customerIdClean = (customerParts.isNotEmpty && customerParts[0].isNotEmpty 
          ? customerParts[0] 
          : result.customerName)
          .replaceAll(RegExp(r'[^\w\s-]'), '');
      
      if (asImage) {
        // Convert PDF to image (timestamp added in _sharePdfAsImage)
        await _sharePdfAsImage(pdfBytes, 'Ledger_$customerIdClean');
      } else {
        // Share as PDF
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        await _sharePdfFile(pdfBytes, 'Ledger_${customerIdClean}_$timestamp.pdf');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Share customer balance analysis as PDF or image
  static Future<void> shareBalanceAnalysis(
    List<CustomerBalance> balances,
    {bool asImage = false}
  ) async {
    try {
      final pdf = await _generateBalanceAnalysisPdf(balances);
      final pdfBytes = await pdf.save();
      
      if (asImage) {
        // Convert PDF to image (timestamp added in _sharePdfAsImage)
        await _sharePdfAsImage(pdfBytes, 'Balance_Analysis');
      } else {
        // Share as PDF
        final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        await _sharePdfFile(pdfBytes, 'Balance_Analysis_$timestamp.pdf');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Share ledger via WhatsApp to a specific phone number
  static Future<void> shareViaWhatsApp(LedgerResult result, String phoneNumber) async {
    try {
      final pdf = await _generateLedgerPdf(result);
      final pdfBytes = await pdf.save();
      
      // Create meaningful filename
      final customerParts = result.customerName.split('.');
      final customerIdClean = (customerParts.isNotEmpty && customerParts[0].isNotEmpty 
          ? customerParts[0] 
          : result.customerName)
          .replaceAll(RegExp(r'[^\w\s-]'), '');
      
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'Ledger_${customerIdClean}_$timestamp.pdf';
      
      // Save PDF to temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(pdfBytes);
      
      // Clean phone number (remove spaces, dashes, etc.)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      
      // Add country code if not present (assuming India +91)
      if (!cleanPhone.startsWith('+')) {
        if (!cleanPhone.startsWith('91') && cleanPhone.length == 10) {
          cleanPhone = '91$cleanPhone';
        }
      }
      
      // Encode the message
      final message = Uri.encodeComponent('Please find your ledger statement attached.');
      
      // Create WhatsApp URL with file
      // Using whatsapp://send works better on mobile devices
      final Uri whatsappUri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$message');
      
      // Try to launch WhatsApp with the message
      // Note: File sharing via URL doesn't work directly, so we'll share via Share API with text
      if (await canLaunchUrl(whatsappUri)) {
        // Share file first via Share API
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Ledger Statement',
          text: 'Please find your ledger statement attached.',
        );
      } else {
        throw Exception('WhatsApp is not installed on this device');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Print balance analysis
  static Future<void> printBalanceAnalysis(List<CustomerBalance> balances) async {
    final pdf = await _generateBalanceAnalysisPdf(balances);
    
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  /// Generate ledger PDF document
  static Future<pw.Document> _generateLedgerPdf(LedgerResult result) async {
    final pdf = pw.Document();

    // Text style for narrow font (using condensed spacing)
    final narrowTextStyle = pw.TextStyle(
      fontSize: 8,
      letterSpacing: -0.3,
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

  /// Generate balance analysis PDF document
  static Future<pw.Document> _generateBalanceAnalysisPdf(List<CustomerBalance> balances) async {
    final pdf = pw.Document();
    final currencyFormat = NumberFormat.currency(symbol: 'Rs. ', decimalDigits: 2);
    final dateFormat = DateFormat('dd-MMM-yyyy');

    final narrowTextStyle = pw.TextStyle(
      fontSize: 7,
      letterSpacing: -0.3,
    );
    final narrowBoldTextStyle = pw.TextStyle(
      fontSize: 7,
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
                  'BALANCE ANALYSIS',
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

              // Info
              pw.Text(
                'Total Customers: ${balances.length}',
                style: const pw.TextStyle(fontSize: 8, letterSpacing: -0.2),
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
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text('Customer', style: narrowBoldTextStyle),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Balance',
                        style: narrowBoldTextStyle,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // Table Rows
              ...balances.map((balance) => pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(
                      color: PdfColors.grey300,
                      width: 0.5,
                    ),
                  ),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            balance.customerId,
                            style: narrowBoldTextStyle,
                          ),
                          pw.Text(
                            balance.name,
                            style: narrowTextStyle,
                          ),
                          if (balance.lastCreditDate != null)
                            pw.Text(
                              'Last: ${dateFormat.format(balance.lastCreditDate!)}',
                              style: pw.TextStyle(
                                fontSize: 6,
                                letterSpacing: -0.2,
                              ),
                            ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        currencyFormat.format(balance.balance),
                        style: narrowBoldTextStyle,
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),

              // Summary
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 6),
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Balance',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: -0.2,
                      ),
                    ),
                    pw.Text(
                      currencyFormat.format(
                        balances.fold(0.0, (sum, b) => sum + b.balance),
                      ),
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  /// Share PDF file
  static Future<void> _sharePdfFile(Uint8List pdfBytes, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    await file.writeAsBytes(pdfBytes);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: filename.replaceAll('.pdf', ''),
    );
  }

  /// Share PDF as image
  static Future<void> _sharePdfAsImage(Uint8List pdfBytes, String filenameBase) async {
    // Convert PDF to image using printing package with proper DPI for quality
    // Using JPEG format to ensure white background (no transparency issues)
    final rasters = await Printing.raster(pdfBytes, dpi: 300);
    final pdfRaster = await rasters.first;

    // Convert raster to PNG first to preserve colors, then flatten on white background
    final pngBytes = await pdfRaster.toPng();
    final imgImage = img.decodePng(pngBytes);

    if (imgImage == null) {
      throw Exception('Failed to decode PDF image for sharing');
    }

    final whiteBackground = img.Image(
      width: imgImage.width,
      height: imgImage.height,
      format: img.Format.uint8,
      numChannels: _rgbChannelCount,
    );

    img.fill(
      whiteBackground,
      color: img.ColorUint8.rgb(255, 255, 255),
    );

    // Note: compositeImage writes directly into whiteBackground to overlay the raster
    img.compositeImage(
      whiteBackground,
      imgImage,
      dstX: 0,
      dstY: 0,
    );

    // Encode as JPEG (returns Uint8List directly) with solid white background
    final imageBytes = img.encodeJpg(whiteBackground);
    
    // Add timestamp to filename to ensure uniqueness
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filenameWithTimestamp = '${filenameBase}_$timestamp';
    
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filenameWithTimestamp.jpg');
    await file.writeAsBytes(imageBytes);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: filenameWithTimestamp,
    );
  }
}
