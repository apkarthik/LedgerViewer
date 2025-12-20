# Share Feature - Visual Guide

## Where to Find Share Buttons

### 1. Ledger Display Screen

#### Header Section
```
┌─────────────────────────────────────────────┐
│ Customer Name                    [📤] [🖨️]  │
│ Date Range                                  │
└─────────────────────────────────────────────┘
```
- Share button (📤) appears next to Print button (🖨️)
- Located in the top-right corner of the ledger display
- White icon on colored gradient background

#### Bottom Section
```
┌──────────────────┬──────────────────┐
│   📤 Share       │   🖨️ Print       │
│   Ledger         │   Ledger         │
└──────────────────┴──────────────────┘
```
- Two equal-width buttons in a row
- Share button: Green background (distinguishable)
- Print button: Theme-colored background
- Both buttons full width with padding

### 2. Customer Details (Home Screen)

#### Expansion Tile
```
┌─────────────────────────────────────────────┐
│ 👤 Customer Details          [📤] [🖨️] [▼]  │
│ ┌───────────────────────────────────────┐   │
│ │ Customer ID  : 1139B                  │   │
│ │ Name        : Pushpa Malliga Teacher  │   │
│ │ Mobile      : 9876543210             │   │
│ │ Area        : Area Name              │   │
│ │ GPAY        : 9876543210             │   │
│ └───────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```
- Share button appears before Print button
- Small compact icons (size: 20)
- Located in the trailing section of expansion tile
- 8px spacing between share and print buttons

## Share Flow Diagram

```
User Action          System Response              Result
─────────────────────────────────────────────────────────
                                                  
Tap Share Button  →  Generate PDF in Memory  →   Open Share Sheet
                     (< 1 second)                  
                                                   ↓
                                                  
                                              User Selects App
                                              (WhatsApp, Email, etc.)
                                                   
                                                   ↓
                                                  
                                              PDF Shared to App
                                              (Ready to send)
```

## Generated PDF Filenames

### Ledger Statement
```
Format: ledger_CustomerName_YYYYMMDD.pdf

Examples:
- ledger_Pushpa_Malliga_Teacher_20251220.pdf
- ledger_John_Doe_20251220.pdf
- ledger_Test_Customer_20251220.pdf
```
- Spaces in customer names replaced with underscores
- Date in YYYYMMDD format for sortability
- Always includes current date

### Customer Details
```
Format: customer_CustomerID_YYYYMMDD.pdf

Examples:
- customer_1139B_20251220.pdf
- customer_1001-A_20251220.pdf
- customer_TEST123_20251220.pdf
```
- Customer ID used as-is (preserves special characters)
- Date in YYYYMMDD format for sortability
- Always includes current date

## PDF Content

### Ledger Statement PDF
```
╔═══════════════════════════════╗
║    LEDGER STATEMENT           ║
║    20/12/2025 09:08          ║
╠═══════════════════════════════╣
║ Customer: Pushpa Malliga      ║
║ Period: 01-Apr-25 to 23-Nov-25║
╠═══════════════════════════════╣
║ Date  | Tp | No | Debit |Credit║
╠═══════════════════════════════╣
║ 24/04 | S  | 01 | 1000  |  -   ║
║ 25/04 | P  | 02 |  -    | 500  ║
║  ...  |... |... |  ...  | ...  ║
╠═══════════════════════════════╣
║ Total Debit:  Rs. 10,000      ║
║ Total Credit: Rs. 5,000       ║
║ Balance:      Rs. 5,000       ║
╚═══════════════════════════════╝
```

### Customer Details PDF
```
╔═══════════════════════════════╗
║   CUSTOMER DETAILS            ║
║   20/12/2025 09:08           ║
╠═══════════════════════════════╣
║ Customer ID : 1139B          ║
║ Name        : Pushpa Malliga ║
║ Mobile      : 9876543210     ║
║ Area        : City Center    ║
║ GPAY        : 9876543210     ║
╚═══════════════════════════════╝
```

## Error Handling

### Error Message Display
```
┌─────────────────────────────────────────────┐
│ ⚠️  Error sharing: [Error message]          │
└─────────────────────────────────────────────┘
```
- Red background (Colors.red.shade600)
- Snackbar notification
- Auto-dismisses after few seconds
- User-friendly error messages

### Common Scenarios
1. **No Storage Permission**: "Error sharing: Permission denied"
2. **Network Issue**: "Error sharing: Network error"
3. **Low Storage**: "Error sharing: Insufficient storage"
4. **App Not Installed**: (Handled by OS - app won't appear in share sheet)

## Compatibility

### Supported Apps (Examples)
- ✅ WhatsApp
- ✅ Gmail / Email clients
- ✅ Google Drive
- ✅ Telegram
- ✅ Slack
- ✅ Microsoft Teams
- ✅ Dropbox
- ✅ OneDrive
- ✅ Any app that accepts PDF files

### Android Versions
- ✅ Android 5.0+ (API 21+)
- ✅ Fully compatible with modern Android versions
- ✅ Uses native Android share sheet

## UI/UX Decisions

### Color Choices
- **Share Button**: Green (`Colors.green.shade600`)
  - Reason: Universal color for "send/share" actions
  - Distinguishable from print button
  
- **Print Button**: Theme-based color
  - Reason: Maintains existing theme consistency
  - Users already familiar with this color

### Button Placement
1. **Header**: Quick access without scrolling
2. **Bottom**: Accessible after reviewing content
3. **Consistent**: Same pattern across all screens

### Icon Selection
- **Share**: `Icons.share` (standard Material icon)
  - Reason: Universal recognition
  - Platform-independent understanding

### Spacing & Layout
- 8px spacing between buttons
- Equal width for bottom buttons (responsive)
- Compact icons in header/expansion tile (size: 20)
- Full-size buttons at bottom (padding: 16)
