# Configuration Example

This document provides examples of how to configure the LedgerView app with Google Sheets URLs.

## Example 1: Simplified Approach (Recommended)

Use this approach when you want to publish your entire Google Sheets document once and configure sheet access via GIDs.

### Step 1: Publish Entire Document
1. Open your Google Sheet: `https://docs.google.com/spreadsheets/d/1abc123xyz/edit`
2. Go to **File → Share → Publish to web**
3. Select **Entire Document**
4. Choose **Comma-separated values (.csv)**
5. Click **Publish**

You'll get a URL like:
```
https://docs.google.com/spreadsheets/d/e/2PACX-1vTzfIpRjg7ALjbYM0P_Ueb0J2VXEG_ILPls-vCMhMxU8fiSZQYPeLu16OTBD6EYDQ/pub?output=csv
```

### Step 2: Find Sheet GIDs
When viewing each sheet in your Google Sheets, look at the URL:
- Master sheet: `...edit#gid=0` → GID is `0`
- Ledger sheet: `...edit#gid=123456789` → GID is `123456789`

### Step 3: Configure in App
In the Settings screen (purple section):
- **Published Document URL**: 
  ```
  https://docs.google.com/spreadsheets/d/e/2PACX-1vTzfIpRjg7ALjbYM0P_Ueb0J2VXEG_ILPls-vCMhMxU8fiSZQYPeLu16OTBD6EYDQ/pub?output=csv
  ```
- **Master Sheet GID**: `0`
- **Ledger Sheet GID**: `123456789`

The app will automatically construct:
- Master URL: `...pub?output=csv&gid=0`
- Ledger URL: `...pub?output=csv&gid=123456789`

## Example 2: Individual Sheet URLs (Legacy)

Use this approach when you want to publish each sheet separately.

### Step 1: Publish Master Sheet
1. Open your Google Sheet
2. Go to **File → Share → Publish to web**
3. Select **Master** sheet
4. Choose **Comma-separated values (.csv)**
5. Click **Publish**

Copy the URL, e.g.:
```
https://docs.google.com/spreadsheets/d/e/2PACX-abc123/pub?gid=0&single=true&output=csv
```

### Step 2: Publish Ledger Sheet
Repeat for the Ledger sheet:
```
https://docs.google.com/spreadsheets/d/e/2PACX-abc123/pub?gid=123456789&single=true&output=csv
```

### Step 3: Configure in App
In the Settings screen (green and indigo sections):
- **Master Sheet URL**: Full URL from Step 1
- **Ledger Sheet URL**: Full URL from Step 2

## Backward Compatibility

The app supports both approaches simultaneously:
- If **individual sheet URLs** are provided, they take priority
- If **individual sheet URLs** are empty, the app uses **published document URL + GIDs**
- This allows seamless migration and flexibility

## Tips

1. **First sheet default**: If you leave the GID empty, the app will use the published document URL as-is (usually the first sheet)
2. **Finding GID**: Look at the browser URL when viewing a sheet: `...edit#gid=XXXXXXX`
3. **Testing**: After configuring, use the "Load" button in the Customers tab to verify the Master sheet URL works
4. **Troubleshooting**: If data doesn't load, check that:
   - The document is published (not just shared)
   - The GIDs match your sheet structure
   - The URLs are complete and not truncated
