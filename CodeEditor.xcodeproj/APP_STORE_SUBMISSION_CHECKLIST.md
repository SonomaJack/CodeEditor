# App Store Submission Checklist for Clarity Code

## ✅ Code Changes Complete

### Premium Feature Configuration
- [x] `overridePremiumForTesting` set to `false` in `FeatureAccess.swift`
- [x] Premium features now properly gated behind StoreKit purchase
- [x] DEBUG-only override for development testing
- [x] All premium features require actual IAP purchase in production

## 📋 Pre-Submission Checklist

### 1. In-App Purchase Configuration (App Store Connect)

- [ ] **Create IAP Product** in App Store Connect
  - Product ID: `com.yourcompany.claritycode.premium` (or similar)
  - Type: Non-Consumable  
  - Price: **$14.99** (recommended - see PRICING_ANALYSIS.md)
  - Display Name: "Clarity Code Premium"
  - Description: "Unlock all 20+ programming languages, code completion, find & replace, and advanced features"
  - Screenshots (if required): Upload IAP feature screenshots

- [ ] **Submit IAP for Review**
  - Add localization if needed
  - Submit alongside app or separately
  - Wait for "Ready to Submit" or "Approved" status

### 2. App Store Connect - App Information

- [ ] **App Name**: Clarity Code
- [ ] **Subtitle**: Professional Code Editor
- [ ] **Category**: Developer Tools
- [ ] **Privacy Policy URL**: (Add your privacy policy URL)
- [ ] **Support URL**: (Add your support website or email)
- [ ] **Marketing URL** (optional): Your marketing page

### 3. App Store Connect - Pricing and Availability

- [ ] **Price**: Free (base app is free)
- [ ] **Availability**: All territories or select regions
- [ ] **Pre-order** (optional): Configure if desired

### 4. App Store Connect - App Information

#### App Description
```
Transform Your Mac Into a Powerful Coding Workstation

Clarity Code is a native macOS code editor designed for developers who value clarity, speed, and simplicity. Whether you're writing Swift, Python, JavaScript, C#, or any of 20+ supported languages, Clarity Code provides intelligent syntax highlighting and smart language detection to keep you focused on what matters: your code.

INTELLIGENT LANGUAGE DETECTION
Paste code and watch Clarity Code automatically detect the language. Advanced content analysis recognizes patterns from Swift to Salesforce Apex, ensuring accurate syntax highlighting every time.

FREE TIER - GET STARTED TODAY
- Markdown editing with live formatting
- JSON and XML with structure highlighting  
- CSV file editing
- Plain text editing
- Unlimited files and projects
- Save, open, and print documents
- Full keyboard shortcuts (Cmd+N, Cmd+O, Cmd+S, Cmd+P)

PREMIUM - UNLOCK FULL POWER
Upgrade once to unlock professional features forever.

(Continue with full description from marketing materials)
```

#### Keywords
```
code editor,swift,python,javascript,syntax,developer,programming,apex,salesforce,html,css,java,rust
```

#### Promotional Text (170 chars)
```
Write, edit, and debug code in 20+ languages with intelligent syntax highlighting, auto-detection, and professional tools. Free to start, premium to master.
```

### 5. Screenshots and Previews

Required sizes for macOS:
- [ ] **1280 x 800** (required)
- [ ] **1440 x 900** (required)
- [ ] **2560 x 1600** (optional)
- [ ] **2880 x 1800** (optional)

Suggested screenshots:
1. Main editor view with syntax highlighted code
2. Multi-file sidebar with multiple open files
3. Language selection and auto-detection
4. Code completion in action
5. Find and replace interface (Premium)
6. Premium feature comparison

### 6. App Privacy

#### Data Collection
- [ ] **No data collected** ✓
  - No tracking
  - No analytics
  - No crash reporting
  - All editing happens locally

Privacy Manifest (if required):
- No required reasons API usage
- No third-party SDKs
- No data collection

### 7. Build Configuration

#### Xcode Project Settings

- [ ] **Version Number**: 1.0 (or your version)
- [ ] **Build Number**: 1 (increment for each submission)
- [ ] **Bundle Identifier**: Matches App Store Connect
- [ ] **Signing**: Automatic or manual with valid certificates
- [ ] **Deployment Target**: macOS 13.0 or later
- [ ] **Architectures**: arm64 and x86_64 (Universal)

#### Capabilities
- [ ] **In-App Purchase**: Enabled
- [ ] **Sandbox**: Enabled (required for Mac App Store)
- [ ] **Hardened Runtime**: Enabled

#### Entitlements
```xml
<!-- Required entitlements -->
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.print</key>
<true/>
```

### 8. Testing Checklist

#### Free Features
- [ ] Create new file works
- [ ] Open file works (Markdown, JSON, XML, CSV, TXT)
- [ ] Save file works
- [ ] Print works (if free)
- [ ] Syntax highlighting for free languages works
- [ ] Multiple files can be opened

#### Premium Purchase Flow
- [ ] Premium upgrade button visible
- [ ] StoreKit purchase sheet appears
- [ ] Sandbox purchase works (with test account)
- [ ] Purchase completes successfully
- [ ] Premium features unlock immediately
- [ ] Restore purchases works
- [ ] Premium state persists after app restart

#### Premium Features (After Purchase)
- [ ] All 20+ languages syntax highlighting works
- [ ] Code completion works
- [ ] Find and replace works
- [ ] Auto language detection works
- [ ] All premium languages selectable
- [ ] Print with formatting works (if premium)

#### Error Handling
- [ ] Purchase cancellation handled gracefully
- [ ] Network error during purchase handled
- [ ] Invalid file type shows error
- [ ] Large file handling
- [ ] Binary file rejection

### 9. StoreKit Configuration File (Optional)

For local testing, create `Products.storekit`:
```json
{
  "identifier" : "YOUR_BUNDLE_ID",
  "nonRenewingSubscriptions" : [ ],
  "products" : [ {
    "displayPrice" : "14.99",
    "familyShareable" : true,
    "internalID" : "12345678",
    "localizations" : [ {
      "description" : "Unlock all 20+ programming languages and premium features",
      "displayName" : "Clarity Code Premium",
      "locale" : "en_US"
    } ],
    "productID" : "com.yourcompany.claritycode.premium",
    "referenceName" : "Premium Features",
    "type" : "NonConsumable"
  } ],
  "settings" : {
    "_failTransactionsEnabled" : false,
    "_locale" : "en_US",
    "_storefront" : "USA",
    "_storeKitErrors" : [ ]
  },
  "subscriptionGroups" : [ ],
  "version" : {
    "major" : 2,
    "minor" : 0
  }
}
```

### 10. Build and Archive

- [ ] Clean build folder (Product → Clean Build Folder)
- [ ] Archive app (Product → Archive)
- [ ] Validate archive in Organizer
- [ ] Upload to App Store Connect
- [ ] Wait for processing (can take 30-60 minutes)

### 11. TestFlight (Optional but Recommended)

- [ ] Enable TestFlight for internal testing
- [ ] Test with sandbox IAP accounts
- [ ] Verify purchase flow works
- [ ] Verify all features work
- [ ] External beta (optional)

### 12. Submit for Review

#### App Review Information
- [ ] **Contact Information**: Valid email and phone
- [ ] **Demo Account**: Not required (no login)
- [ ] **Notes**: Add helpful notes for reviewers

Example notes:
```
This is a native macOS code editor with a freemium model.

FREE FEATURES:
Users can edit Markdown, JSON, XML, CSV, and plain text files for free without any purchase.

PREMIUM FEATURES:
A one-time in-app purchase unlocks:
- Syntax highlighting for 20+ programming languages
- Code completion
- Find and replace
- Advanced language detection

To test premium features, please make a sandbox purchase. The IAP product ID is: com.yourcompany.claritycode.premium

Thank you for reviewing our app!
```

- [ ] **Version Release**: Manual or Automatic
- [ ] **Submit for Review**

### 13. Post-Submission

- [ ] Monitor App Store Connect for review status
- [ ] Respond to any reviewer questions within 24 hours
- [ ] Fix any issues if rejected and resubmit
- [ ] Celebrate when approved! 🎉

## 🔧 Common Issues and Solutions

### Issue: "In-App Purchase not configured"
**Solution**: Create and submit IAP in App Store Connect first, wait for approval

### Issue: "Missing entitlements"
**Solution**: Enable App Sandbox and file access entitlements

### Issue: "Premium features not unlocking"
**Solution**: 
- Check `overridePremiumForTesting` is `false`
- Verify StoreManager is checking purchase status correctly
- Test with sandbox account

### Issue: "Binary rejected for using private APIs"
**Solution**: Ensure no use of undocumented APIs

### Issue: "Guideline 2.3.1 - Performance - Accurate Metadata"
**Solution**: Ensure app description matches actual app functionality

## 📱 Marketing Preparation

- [ ] Marketing website live
- [ ] Support email configured
- [ ] Privacy policy published
- [ ] Terms of service (optional)
- [ ] Social media accounts (optional)
- [ ] Press kit (optional)

## 🎯 Launch Day Checklist

- [ ] Monitor reviews
- [ ] Respond to user feedback
- [ ] Track downloads in App Store Connect
- [ ] Share on social media
- [ ] Contact tech press (optional)

---

## Quick Reference

**Bundle ID**: (Add your bundle ID)
**IAP Product ID**: (Add your IAP product ID)
**App Store Connect URL**: https://appstoreconnect.apple.com

**Support Email**: support@claritycode.app (change to yours)
**Website**: https://yourwebsite.com

---

Good luck with your App Store submission! 🚀
