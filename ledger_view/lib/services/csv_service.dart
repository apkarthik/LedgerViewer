import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import '../models/ledger_entry.dart';

class CsvService {
  /// Fetch CSV data from the given URL and parse it
  static Future<List<List<dynamic>>> fetchCsvData(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final csvString = response.body;
        final csvConverter = const CsvToListConverter(
          eol: '\n',
          shouldParseNumbers: false,
        );
        return csvConverter.convert(csvString);
      } else {
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching CSV: $e');
    }
  }

  /// Find ledger entries for a specific customer number
  static LedgerResult? findLedgerByNumber(
    List<List<dynamic>> data,
    String searchNumber,
  ) {
    if (data.isEmpty) return null;

    // Normalize search number
    final normalizedSearch = searchNumber.trim().toUpperCase();
    
    int startRow = -1;
    int endRow = -1;
    String customerName = '';
    String dateRange = '';

    // Find the section that matches the search number
    for (int i = 0; i < data.length; i++) {
      final row = data[i];
      
      // Check if this row is a header row (contains "Ledger:")
      if (row.isNotEmpty && row[0].toString().trim().toLowerCase() == 'ledger:') {
        // Column 1 contains the customer number and name (e.g., "1139B.Pushpa Malliga Teacher")
        final customerInfo = row.length > 1 ? row[1].toString().trim() : '';
        
        // Extract the number part (before the first dot or space)
        String extractedNumber = '';
        if (customerInfo.contains('.')) {
          extractedNumber = customerInfo.split('.')[0].trim().toUpperCase();
        } else {
          // Try splitting by space
          extractedNumber = customerInfo.split(' ')[0].trim().toUpperCase();
        }
        
        if (extractedNumber == normalizedSearch) {
          startRow = i;
          customerName = customerInfo;
          dateRange = row.length > 2 ? row[2].toString().trim() : '';
          
          // Find the end of this section (next "Ledger:" or end of data)
          for (int j = i + 1; j < data.length; j++) {
            final nextRow = data[j];
            if (nextRow.isNotEmpty && 
                nextRow[0].toString().trim().toLowerCase() == 'ledger:') {
              endRow = j - 1;
              break;
            }
          }
          
          // If we didn't find another "Ledger:", use the end of data
          if (endRow == -1) {
            endRow = data.length - 1;
          }
          
          break;
        }
      }
    }

    if (startRow == -1) return null;

    // Extract the ledger entries
    final entries = <LedgerEntry>[];
    String totalDebit = '';
    String totalCredit = '';
    String closingBalance = '';

    for (int i = startRow + 2; i <= endRow; i++) {
      final row = data[i];
      if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
        continue; // Skip empty rows
      }

      // Parse the row
      final date = row.length > 0 ? row[0].toString().trim() : '';
      final toBy = row.length > 1 ? row[1].toString().trim() : '';
      final particulars = row.length > 2 ? row[2].toString().trim() : '';
      final vchType = row.length > 3 ? row[3].toString().trim() : '';
      final vchNo = row.length > 4 ? row[4].toString().trim() : '';
      final debit = row.length > 5 ? row[5].toString().trim() : '';
      final credit = row.length > 6 ? row[6].toString().trim() : '';

      // Check if this is a totals row or closing balance row
      if (particulars.toLowerCase().contains('closing balance')) {
        closingBalance = credit.isNotEmpty ? credit : debit;
      } else if (date.isNotEmpty && !_isDateString(date)) {
        // This is a totals row
        totalDebit = date;
        totalCredit = credit;
      } else if (date.isNotEmpty || toBy.isNotEmpty || particulars.isNotEmpty) {
        entries.add(LedgerEntry(
          date: _formatDate(date),
          toBy: toBy,
          particulars: particulars,
          vchType: vchType,
          vchNo: vchNo,
          debit: debit,
          credit: credit,
        ));
      }
    }

    return LedgerResult(
      customerName: customerName,
      dateRange: dateRange,
      entries: entries,
      totalDebit: totalDebit,
      totalCredit: totalCredit,
      closingBalance: closingBalance,
    );
  }

  static bool _isDateString(String str) {
    // Check if the string looks like a date using regex pattern
    // Matches yyyy-mm-dd, dd-mm-yyyy, dd/mm/yyyy formats
    final datePattern = RegExp(r'\d{4}-\d{2}-\d{2}|\d{2}[-/]\d{2}[-/]\d{4}|\d{2}-[A-Za-z]{3}-\d{4}');
    return datePattern.hasMatch(str) || str.contains('-') && str.length > 8;
  }

  static String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    
    // Try to parse and format the date
    try {
      // Handle Excel date format (e.g., "2025-04-01 00:00:00")
      if (dateStr.contains(' ')) {
        dateStr = dateStr.split(' ')[0];
      }
      
      // Parse yyyy-mm-dd format
      if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          final year = parts[0];
          final month = _getMonthName(int.tryParse(parts[1]) ?? 0);
          final day = int.tryParse(parts[2]) ?? parts[2];
          return '$day-$month-$year';
        }
      }
      
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }

  static String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    if (month >= 1 && month <= 12) {
      return months[month];
    }
    return month.toString();
  }
}
