# LedgerView

A modern Flutter Android app to view customer ledger data from Google Sheets CSV.

## Features

- 🔍 **Search by Customer Number**: Enter a customer number (e.g., "1139B") to view their ledger
- 👥 **Customer List**: Browse customer information from Master sheet with search and filter
- 📊 **Professional Ledger Display**: Clean, formatted view optimized for thermal printer output
- ☁️ **Google Drive Integration**: Fetch live data from Google Sheets published as CSV
- 💾 **Persistent Settings**: App data persists until uninstall or manual reset
- 🎨 **Modern UI**: Professional, colorful design with Material Design 3

## App Screens

The app contains 3 main screens accessible via bottom navigation:

1. **Settings** - Configure the Google Sheets CSV URLs for Master sheet (customer list) and Ledger sheet (ledger data)
2. **Customers** - View and search customer information from the Master sheet. Click on any customer to view their ledger
3. **Ledger Search** - Search for customer ledgers directly by entering a customer number

## Setup

1. **Configure Google Sheets CSV URLs**:
   - Open your Google Sheet containing ledger data
   - Go to **File → Share → Publish to web**
   - **Important**: Select the specific sheet to publish (Master or Ledger), not the entire document
   - Select **CSV** format
   - Click **Publish** and copy the generated link
   - Repeat for each sheet you need to publish
   
2. **In the app's Settings page, configure both URLs**:
   - **Master Sheet URL**: The CSV link for your customer list (Master sheet)
   - **Ledger Sheet URL**: The CSV link for your ledger data (Ledger sheet)

3. **Search for Ledger**:
   - Use the **Ledger Search** tab to enter a customer number directly (e.g., "1033", "1035", "1139B", "1525")
   - Or use the **Customers** tab to browse and click on a customer to view their ledger
   - Data is fetched fresh from Google Drive on each search

## Building the APK

This repository includes a GitHub Actions workflow to build the APK manually:

1. Go to the **Actions** tab in GitHub
2. Select **Build APK** workflow
3. Click **Run workflow**
4. Choose build type (release/debug)
5. Download the APK from the workflow artifacts

Note: The workflow is only triggered manually (not on push or pull request).

## Data Format

The app expects CSV data in the following format:
- Column A: "Ledger:" header or dates
- Column B: Customer number and name (format: "number.name") or particulars
- Columns C-G: Date range, voucher type, voucher number, debit, credit

Example:
```
Ledger:,1139B.Pushpa Malliga Teacher,1-Apr-2025 to 23-Nov-2025,,,
Date,Particulars,,Vch Type,Vch No.,Debit,Credit
2025-04-24,By,Cash,Receipt,16453,,15000
...
```

## Tech Stack

- **Flutter 3.24+**
- **Dart 3.0+**
- **SharedPreferences** for persistent storage
- **HTTP package** for network requests
- **CSV package** for parsing
- **Google Fonts** for typography

## License

This project is licensed under the MIT License.