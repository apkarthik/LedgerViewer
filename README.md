# LedgerView

A modern Flutter Android app to view customer ledger data from Google Sheets CSV.

## Features

- 🔍 **Search by Customer Number**: Enter a customer number, name, or mobile number (e.g., "1139B", "Pushpa", "9876543210") to view their ledger
- 👥 **Customer List**: Browse customer information from Master sheet with search and filter
- 📊 **Professional Ledger Display**: Clean, formatted view in the app; simplified print output with Date, Vch Type (first letter), Vch No., Debit, and Credit columns
- 📈 **Customer & Balance Analysis**: View all customers with their total debit, credit, and closing balance in one comprehensive screen with sorting and filtering capabilities
- 🖨️ **Print/PDF Support**: Generate printable ledger statements with simplified format matching accounting requirements
- ☁️ **Google Drive Integration**: Fetch live ledger data on each search; refresh master data independently
- 💾 **Persistent Settings**: App data persists until uninstall or manual reset
- 🎨 **Modern UI**: Professional, colorful design with Material Design 3
- 🌈 **Customizable Themes**: Choose from 5 beautiful themes (Light, Dark, Ocean Blue, Nature Green, Royal Purple) to personalize your experience

## App Screens

The app contains 4 main screens accessible via bottom navigation:

1. **Settings** - Configure the Google Sheets CSV URLs for Master sheet (customer list) and Ledger sheet (ledger data). Also customize the app theme to your preference.
2. **Ledger Search** - Search for customer ledgers directly by entering a customer number
3. **Analysis** - View comprehensive customer and balance analysis with sortable columns showing total debit, credit, and closing balance for all customers

## Theme Customization

The app supports 5 beautiful themes that can be changed from the Settings screen:

- **Light** - Clean, bright interface perfect for daylight use
- **Dark** - Easy on the eyes for low-light environments
- **Ocean Blue** - Calming blue tones inspired by the ocean
- **Nature Green** - Fresh, natural green theme
- **Royal Purple** - Elegant purple theme for a premium feel

Your theme preference is saved automatically and persists across app sessions.

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
   - Use the **Ledger Search** tab to enter a customer number, name, or mobile number (e.g., "1033", "1035", "1139B", "1525", "Pushpa", "9876543210")
   - The search field supports text input for flexible searching
   - Or use the **Customers** tab to browse and click on a customer to view their ledger
   - Ledger data is fetched fresh from Google Sheets on each search
   
4. **Refresh Data**:
   - Use the refresh button in the Ledger Search screen to update only the master data (customer list)
   - Ledger data is always fetched fresh when you search, so no need to refresh it separately

## Print Format

The app displays full ledger details on screen but prints a simplified format for better clarity:

**On-Screen Display:**
- Date, To/By, Particulars, Vch Type, Debit, Credit

**Print/PDF Output (Optimized for 58mm Thermal Printer):**
- Date (dd/mm/yy format, e.g., 24/04/25), Vch Type (first letter only), Vch No., Debit, Credit
- Examples: Sales → S, Purchase → P, Cash Receipt → C, Bank Receipt → B, Journal → J
- Uses narrow/condensed fonts to maximize space on thermal paper
- Auto-adjustable column widths for debit and credit amounts

This simplified print format follows standard accounting practices for thermal printers and matches the requirements in `sample_bill.xlsx` (Required sheet).

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
- **PDF package** for generating printable documents
- **Printing package** for print/PDF preview

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3).

You may redistribute and/or modify this program under the terms of the GNU GPL as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

See the [LICENSE](LICENSE) file for details.