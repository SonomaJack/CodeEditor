# Code Editor - App Store IAP Version

This branch contains the App Store version with In-App Purchase (IAP) support.

## Features

### Free Features
- ✅ Basic code editing
- ✅ Plain Text, Markdown, JSON, XML, CSV
- ✅ Find (search only)
- ✅ Line numbers toggle
- ✅ Save and Open files
- ✅ Basic file management
- ✅ Syntax highlighting for free languages

### Premium Features (One-time purchase: $4.99)
- 🔒 All 21 programming languages (Swift, Python, JavaScript, TypeScript, Java, Apex, C++, C, C#, Go, Rust, Ruby, PHP, SQL, HTML, CSS, YAML)
- 🔒 Find & Replace with regex support
- 🔒 Column-restricted search
- 🔒 Print with headers and footers
- 🔒 Code completion suggestions
- 🔒 Split view editing
- 🔒 Code snippets & templates
- 🔒 Multi-file search
- 🔒 Git integration
- 🔒 Premium color themes
- 🔒 Advanced customization

## Setup Instructions

### 1. StoreKit Configuration (Local Testing)

1. In Xcode, create a StoreKit Configuration file:
   - File → New → File → StoreKit Configuration File
   - Name: `Products.storekit`

2. Add the IAP product:
   - Click **+** → Add Non-Consumable In-App Purchase
   - Product ID: `com.codeeditor.premium`
   - Reference Name: `Premium Features`
   - Price: $4.99 (or equivalent in your region)

3. Enable StoreKit testing:
   - Product → Scheme → Edit Scheme
   - Run → Options tab
   - StoreKit Configuration → Select `Products.storekit`

### 2. App Store Connect Setup (Production)

1. Create In-App Purchase in App Store Connect:
   - Go to your app → In-App Purchases
   - Click **+** to create new
   - Type: Non-Consumable
   - Product ID: `com.codeeditor.premium` (MUST match StoreKit config)
   - Reference Name: Premium Features
   - Price: Select price tier

2. Add localized information:
   - Display Name: "Premium Features"
   - Description: "Unlock all programming languages, find & replace, printing, code completion, and more advanced features"

3. Add screenshot (if required)

4. Submit for review with your app

### 3. Entitlements

Ensure your app has the following entitlements:
- ✅ App Sandbox
- ✅ In-App Purchase

### 4. Testing

#### Local Testing with StoreKit Configuration:
1. Run app in Xcode with StoreKit config enabled
2. Try to use a premium feature (e.g., select Python language)
3. Premium gate should appear
4. Click "Unlock Premium"
5. Transaction should succeed (simulated)
6. Feature should now be unlocked

#### TestFlight Testing:
1. Upload build to App Store Connect
2. Add IAP to the build
3. Create sandbox test users in App Store Connect
4. Test with TestFlight users

### 5. File Structure

```
CodeEditor/
├── StoreManager.swift          # StoreKit 2 manager
├── PremiumFeatureView.swift    # Paywall UI
├── FeatureAccess.swift         # Feature gating logic
├── SettingsView.swift          # Settings with upgrade option
├── CodeEditorView.swift        # Updated with premium checks
└── Products.storekit           # StoreKit configuration (create manually)
```

## Code Changes from Main Branch

### New Files:
- `StoreManager.swift` - Handles all IAP logic
- `PremiumFeatureView.swift` - Premium upgrade UI
- `FeatureAccess.swift` - Centralized feature access control
- `SettingsView.swift` - Settings window

### Modified Files:
- `CodeEditorView.swift` - Added premium checks for features
- `CodeEditorApp.swift` - Added Settings menu item
- `ContentView.swift` - Added settings window handling

## Premium Feature Implementation

Each premium feature checks `FeatureAccess` before allowing use:

```swift
// Example: Language selection
if !FeatureAccess.canUseLanguage(newValue) {
    document.language = oldValue
    premiumFeatureMessage = FeatureAccess.featureDescription(for: .language(newValue))
    showPremiumGate = true
}
```

## Revenue Model

- **Type**: One-time purchase (non-consumable)
- **Price**: $4.99 USD (adjust per region)
- **Product ID**: `com.codeeditor.premium`

## Testing Checklist

- [ ] StoreKit configuration file created
- [ ] Product ID matches in code and StoreKit config
- [ ] Free features work without purchase
- [ ] Premium features show paywall
- [ ] Purchase flow completes successfully
- [ ] Features unlock after purchase
- [ ] Restore purchases works
- [ ] Settings window shows purchase status
- [ ] Tested on clean install
- [ ] Tested with sandbox account

## Deployment

1. Ensure all premium features are properly gated
2. Test thoroughly with StoreKit config
3. Create archive for App Store
4. Upload to App Store Connect
5. Add IAP product in App Store Connect
6. Submit for review
7. Wait for approval (typically 24-48 hours)

## Support

Users can restore purchases from:
- Settings window → "Restore Purchases" button
- Any premium feature gate → "Restore Purchases" button

## Notes

- IAP is only available on the App Store version
- Direct downloads will not have IAP functionality
- Keep `main` branch as the free/open-source version
- This `appstore-iap-version` branch is for App Store releases only
