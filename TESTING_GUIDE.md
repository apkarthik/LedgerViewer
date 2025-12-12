# Testing Guide for Published Document URL Feature

## Pre-Testing Setup

### 1. Prepare Test Google Sheets
You'll need a Google Sheets document with at least two sheets:
- **Master Sheet**: Contains customer data (ID, Name, Mobile)
- **Ledger Sheet**: Contains ledger entries

### 2. Publish the Document
1. Open your Google Sheets
2. Go to **File → Share → Publish to web**
3. Select **Entire Document**
4. Choose **Comma-separated values (.csv)**
5. Click **Publish**
6. Copy the URL (should look like the example below)

Example URL:
```
https://docs.google.com/spreadsheets/d/e/2PACX-1vTzfIpRjg7ALjbYM0P_Ueb0J2VXEG_ILPls-vCMhMxU8fiSZQYPeLu16OTBD6EYDQ/pub?output=csv
```

### 3. Find Sheet GIDs
1. Open your Google Sheets in browser
2. Click on the Master sheet tab
3. Look at the URL: `...edit#gid=0` (example)
4. Note down the GID: `0`
5. Click on the Ledger sheet tab
6. Look at the URL: `...edit#gid=123456789` (example)
7. Note down the GID: `123456789`

## Test Cases

### Test Case 1: New Configuration (Simplified Approach)
**Objective**: Verify new simplified configuration works

**Steps**:
1. Launch the app
2. Go to Settings tab
3. Locate the purple section "📋 Simplified: Published Document URL"
4. Enter the published document URL
5. Enter Master Sheet GID (e.g., `0`)
6. Enter Ledger Sheet GID (e.g., `123456789`)
7. Click "Save Settings"
8. Navigate to "Customers" tab
9. Click "Load" button
10. Verify customer data loads correctly
11. Click on a customer
12. Verify their ledger displays correctly

**Expected Result**: Customer data and ledgers load successfully

### Test Case 2: Backward Compatibility
**Objective**: Verify existing individual sheet URLs still work

**Steps**:
1. In Settings, clear the published document URL and GIDs
2. Enter individual sheet URLs in the green and indigo sections:
   - Master Sheet URL: Your published Master sheet URL
   - Ledger Sheet URL: Your published Ledger sheet URL
3. Click "Save Settings"
4. Test loading customers and ledgers as in Test Case 1

**Expected Result**: Everything works as before

### Test Case 3: Priority System
**Objective**: Verify direct URLs take priority over constructed URLs

**Steps**:
1. Configure BOTH approaches:
   - Fill in published document URL + GIDs
   - Fill in individual sheet URLs
2. Click "Save Settings"
3. Test loading data

**Expected Result**: App uses individual sheet URLs (legacy approach)

### Test Case 4: Empty GID Handling
**Objective**: Verify app handles missing GIDs gracefully

**Steps**:
1. Enter published document URL
2. Leave Master GID empty
3. Leave Ledger GID empty
4. Click "Save Settings"
5. Try to load data

**Expected Result**: App uses base URL without GID parameter (typically accesses first sheet)

### Test Case 5: Invalid URL Handling
**Objective**: Verify error handling for invalid URLs

**Steps**:
1. Enter an invalid URL (e.g., `not-a-url`)
2. Enter valid GIDs
3. Click "Save Settings"
4. Try to load data

**Expected Result**: App shows appropriate error message

### Test Case 6: Reset Settings
**Objective**: Verify reset clears all fields

**Steps**:
1. Configure all fields (both approaches)
2. Click "Reset All Settings"
3. Confirm the reset

**Expected Result**: All fields are cleared

### Test Case 7: GID with Special Characters
**Objective**: Verify GID field accepts text input

**Steps**:
1. Try entering non-numeric GID (though Google Sheets uses numeric)
2. Verify field accepts the input
3. Save and test (may not work but shouldn't crash)

**Expected Result**: Field accepts input, graceful error if invalid

### Test Case 8: URL with Existing GID
**Objective**: Verify GID replacement works correctly

**Steps**:
1. Enter a URL that already has a GID: 
   `https://docs.google.com/.../pub?output=csv&gid=0`
2. Enter different GIDs (e.g., `999` for Master)
3. Save and verify constructed URL replaces the GID

**Expected Result**: GID is replaced, not appended

## Unit Test Execution

Run the test suite to verify all unit and integration tests pass:

```bash
cd ledger_view
flutter test
```

Expected: All tests pass

## Manual Verification Checklist

- [ ] App compiles without errors
- [ ] Settings screen displays new purple section
- [ ] Paste from clipboard works for published URL
- [ ] Customer data loads with simplified approach
- [ ] Ledger data loads with simplified approach
- [ ] Backward compatibility maintained
- [ ] Priority system works (direct URLs take precedence)
- [ ] Error messages are clear and helpful
- [ ] Reset clears all new fields
- [ ] UI is intuitive and visually clear
- [ ] Instructions in Settings are helpful

## Known Limitations

1. **GIDs must be valid**: Google Sheets GIDs are typically numeric. Invalid GIDs will fail to load data.
2. **Document must be published**: The document must be actively published for the URLs to work.
3. **No validation**: The app doesn't validate GIDs before saving (to remain flexible).

## Troubleshooting

**Problem**: Customer data doesn't load
- **Check**: Is the published document URL correct?
- **Check**: Is the Master sheet GID correct?
- **Check**: Is the document published (not just shared)?

**Problem**: Ledger data doesn't load
- **Check**: Is the Ledger sheet GID correct?
- **Check**: Does the sheet contain the expected data format?

**Problem**: Both approaches configured but wrong one is used
- **Expected**: Direct URLs take priority. Clear them to use simplified approach.

## Success Criteria

✅ All test cases pass
✅ All unit tests pass
✅ Backward compatibility maintained
✅ No crashes or unexpected errors
✅ UI is clear and intuitive
✅ Documentation is accurate

## Reporting Issues

If you encounter any issues:
1. Note the exact steps to reproduce
2. Check the error message displayed
3. Verify your URL and GID configuration
4. Check if the issue occurs with legacy approach too
5. Report with details in the issue tracker
