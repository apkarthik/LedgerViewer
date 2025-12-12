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

There are two ways to configure Google Sheets URLs:

### Option 1: Simplified Approach (Recommended)

1. **Publish entire Google Sheets document**:
   - Open your Google Sheet containing ledger data
   - Go to **File → Share → Publish to web**
   - Select **Entire Document** (not individual sheets)
   - Select **Comma-separated values (.csv)** format
   - Click **Publish** and copy the generated link
   - Example: `https://docs.google.com/spreadsheets/d/e/2PACX-1vTzfIpRjg7ALjbYM0P_Ueb0J2VXEG_ILPls-vCMhMxU8fiSZQYPeLu16OTBD6EYDQ/pub?output=csv`

2. **Find Sheet GIDs** (optional):
   - Open your Google Sheet
   - Look at the URL when viewing each sheet: `.../edit#gid=123456789`
   - The number after `gid=` is the sheet's GID
   - Leave GID empty to use the first sheet (GID 0)

3. **Configure in the app's Settings page**:
   - **Published Document URL**: Paste the entire document URL
   - **Master Sheet GID**: Enter the GID for your customer list sheet (e.g., `0` for first sheet)
   - **Ledger Sheet GID**: Enter the GID for your ledger data sheet (e.g., `123456789`)

### Option 2: Individual Sheet URLs (Legacy)

1. **Publish each sheet separately**:
   - Open your Google Sheet containing ledger data
   - Go to **File → Share → Publish to web**
   - Select the specific sheet to publish (Master or Ledger)
   - Select **CSV** format
   - Click **Publish** and copy the generated link
   - Repeat for each sheet you need to publish
   
2. **In the app's Settings page, configure both URLs**:
   - **Master Sheet URL**: The CSV link for your customer list (Master sheet)
   - **Ledger Sheet URL**: The CSV link for your ledger data (Ledger sheet)

### Using the App

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

This project is licensed under the GNU General Public License v3.0 (GPLv3).

You may redistribute and/or modify this program under the terms of the GNU GPL as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

See the [LICENSE](LICENSE) file for details.