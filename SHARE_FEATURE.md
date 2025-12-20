# Share Functionality Documentation

## Overview
This document describes the share functionality added to LedgerViewer app, allowing users to share ledger statements and customer details as PDF files to external apps like WhatsApp, Email, etc.

## Features Added

### 1. Share Ledger Statement
Users can now share ledger statements as PDF files directly from the app. The share button is available in two locations:
- **Header Section**: Icon button next to the print button in the ledger display header
- **Bottom Section**: Full-width "Share Ledger" button at the bottom of the ledger display

**PDF Details:**
- Filename format: `ledger_CustomerName_YYYYMMDD.pdf`
- Example: `ledger_Pushpa_Malliga_Teacher_20251220.pdf`
- Content includes: Customer name, date range, all ledger entries, totals, and balance

### 2. Share Customer Details
Users can share customer details as PDF files from the home screen's customer details expansion tile.

**PDF Details:**
- Filename format: `customer_CustomerID_YYYYMMDD.pdf`
- Example: `customer_1139B_20251220.pdf`
- Content includes: Customer ID, Name, Mobile Number, Area, and GPAY details

## Technical Implementation

### Modified Files

#### 1. `/lib/services/print_service.dart`
**New Methods:**
- `shareLedger(LedgerResult result)` - Shares ledger as PDF
- `shareCustomerDetails(Customer customer)` - Shares customer details as PDF

**Refactored Methods:**
- `_generateLedgerPdf(LedgerResult result)` - Extracted PDF generation logic (private)
- `_generateCustomerDetailsPdf(Customer customer)` - Extracted PDF generation logic (private)

**Implementation Details:**
- Uses `Printing.sharePdf()` from the `printing` package
- Generates meaningful filenames with customer information and date
- Handles spaces in customer names by replacing with underscores
- Uses thermal printer format (58mm width) for compact PDFs

#### 2. `/lib/widgets/ledger_display.dart`
**UI Changes:**
- Added share icon button in header (next to print button)
- Modified bottom button layout from single print button to Row with two buttons:
  - Share button (green background)
  - Print button (theme-based background)

**New Methods:**
- `_shareLedger(BuildContext context)` - Handles share action with error handling

**Visual Design:**
- Share button uses green color (`Colors.green.shade600`) to distinguish from print
- Both buttons have equal width in responsive Row layout
- Consistent icon usage (Icons.share for share button)

#### 3. `/lib/screens/home_screen.dart`
**UI Changes:**
- Added share icon button in customer details expansion tile
- Positioned before print button with 8px spacing

**New Methods:**
- `_shareCustomerDetails(BuildContext context)` - Handles share action with error handling

**Visual Design:**
- Compact icon buttons (size: 20) to fit in the tile trailing section
- Maintains consistency with existing print button style

### Error Handling
All share methods include comprehensive error handling:
```dart
try {
  await PrintService.shareLedger(result);
} catch (e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error sharing: ${e.toString()}'),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }
}
```

## User Experience

### Sharing Flow
1. User taps the share button
2. PDF is generated in memory
3. Android/iOS share sheet appears
4. User selects destination app (WhatsApp, Email, Drive, etc.)
5. PDF is shared to the selected app

### Supported Destinations
The share functionality works with any app that supports receiving PDF files:
- **Messaging Apps**: WhatsApp, Telegram, Signal, etc.
- **Email Clients**: Gmail, Outlook, etc.
- **Cloud Storage**: Google Drive, Dropbox, OneDrive, etc.
- **Other Apps**: Any app registered to handle PDF files

## Dependencies
The feature relies on the existing `printing` package (v5.13.0) which is already included in `pubspec.yaml`:
```yaml
dependencies:
  printing: ^5.13.0
```

No additional dependencies are required.

## Testing

### Manual Testing Checklist
- [ ] Share ledger from header button opens share sheet
- [ ] Share ledger from bottom button opens share sheet
- [ ] Share customer details opens share sheet
- [ ] PDF can be shared to WhatsApp successfully
- [ ] PDF can be shared to Email successfully
- [ ] PDF can be shared to Google Drive successfully
- [ ] Filename is meaningful and correctly formatted
- [ ] PDF content displays correctly in external apps
- [ ] Error messages display when share fails
- [ ] Share works on different Android versions
- [ ] Share button UI is consistent across screens

### Automated Tests
Unit tests have been added in `test/print_service_test.dart` to verify:
- Share methods exist and are callable
- Filename format is correct
- Methods handle customer names with spaces correctly

## Future Enhancements

### Potential Improvements
1. **Share as Image**: Add option to share as PNG/JPG image in addition to PDF
2. **Custom Message**: Allow users to add a custom message when sharing
3. **Multiple Share**: Allow sharing multiple ledgers at once
4. **Share Settings**: Add settings to customize PDF format (A4 vs Thermal)
5. **Quick Share**: Add quick share to favorite contacts/apps

### Performance Considerations
- PDF generation is fast (< 1 second for typical ledgers)
- Memory usage is minimal as PDFs are generated on-demand
- No storage required as PDFs are shared directly without saving to device

## Screenshots Location
(Screenshots should be added here after manual testing on device)

## Support
For issues or questions about the share functionality, please refer to:
- GitHub Issues: https://github.com/apkarthik/LedgerViewer/issues
- Project README: /README.md
