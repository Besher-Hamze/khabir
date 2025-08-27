# Profile Features Implementation

## Overview

This implementation adds several new features to the profile page:

1. **PDF Viewer for Terms & Conditions and Privacy Policy**
2. **WhatsApp Support Integration**
3. **Enhanced Delete Account Flow**

## Setup Instructions

### 1. Install Dependencies

Run the following command to install the required packages:

```bash
flutter pub get
```

This will install:

- `syncfusion_flutter_pdfviewer: ^24.2.8` - For viewing PDF files
- `file_picker: ^8.0.0+1` - For picking files from device

### 2. PDF Files Setup

To make the PDF viewer fully functional, you need to:

#### Option A: Add PDF files to assets

1. Create a `pdfs` folder in your `assets` directory
2. Add your PDF files:
   - `assets/pdfs/terms_and_conditions.pdf`
   - `assets/pdfs/privacy_policy.pdf`
3. Update `pubspec.yaml` to include PDF assets:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
    - assets/lang/
    - assets/pdfs/ # Add this line
```

#### Option B: Use network URLs

Update the `_showPdfViewerDialog` method to use actual PDF URLs from your API.

### 3. WhatsApp Support Configuration

The WhatsApp support is currently configured with a placeholder number `+96812345678`. Update this in the `_openWhatsAppSupport()` method with your actual support number.

## Features Details

### PDF Viewer

- **Terms & Conditions**: Opens a dialog with PDF viewing options
- **Privacy Policy**: Same functionality as Terms & Conditions
- **File Picker**: Allows users to select PDF files from their device
- **Download Option**: Placeholder for downloading sample PDFs

### WhatsApp Support

- **Support Dialog**: Shows contact information and WhatsApp integration
- **Direct WhatsApp**: Opens WhatsApp with pre-filled support message
- **Error Handling**: Graceful fallback if WhatsApp is not available

### Delete Account

- **Confirmation Dialog**: User must confirm deletion
- **Loading State**: Shows progress indicator during "deletion"
- **Success Message**: Displays success notification
- **Auto Navigation**: Automatically redirects to login screen
- **Fake Implementation**: Currently simulates the process (no actual API call)

## Code Structure

### New Methods Added:

- `_showPdfViewerDialog()` - Main PDF viewer dialog
- `_showPdfOptionsDialog()` - PDF opening options
- `_pickAndViewPdf()` - File picker integration
- `_downloadSamplePdf()` - PDF download functionality
- `_showWhatsAppSupportDialog()` - Support contact dialog
- `_openWhatsAppSupport()` - WhatsApp integration

### Updated Methods:

- `_openTermsAndConditions()` - Now opens PDF viewer
- `_openPrivacyPolicy()` - Now opens PDF viewer
- `_openSupport()` - Now opens WhatsApp support
- `_showDeleteAccountDialog()` - Enhanced with loading and success flow

## Usage

### For Users:

1. **View Documents**: Tap on "Terms and Conditions" or "Privacy Policy"
2. **Get Support**: Tap on "Support" to contact via WhatsApp
3. **Delete Account**: Tap on "Delete Account" and confirm

### For Developers:

1. Install dependencies with `flutter pub get`
2. Add actual PDF files or update URLs
3. Update WhatsApp support number
4. Implement actual delete account API call

## Notes

- The PDF viewer will show a placeholder until packages are installed
- WhatsApp support requires the device to have WhatsApp installed
- Delete account is currently a simulation - implement actual API call as needed
- All dialogs are responsive and follow the app's design system

## Troubleshooting

### PDF Viewer Not Working:

1. Ensure `flutter pub get` was run
2. Check that PDF files exist in assets (if using local files)
3. Verify network URLs are accessible (if using network files)

### WhatsApp Not Opening:

1. Ensure WhatsApp is installed on the device
2. Check the phone number format
3. Verify URL launcher permissions

### Import Errors:

1. Run `flutter clean` then `flutter pub get`
2. Restart your IDE
3. Check package versions in `pubspec.yaml`
