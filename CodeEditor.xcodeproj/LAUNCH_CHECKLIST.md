# 🚀 Clarity Code - Complete Launch Checklist

## ✅ Pre-Launch Verification (COMPLETE)

### Code Configuration
- [x] **FeatureAccess.swift** - `overridePremiumForTesting = false`
- [x] **Premium pricing** - Set to $14.99 in code fallbacks
- [x] **StoreManager.swift** - Properly configured for StoreKit
- [x] **Language detection** - All 20+ languages working
- [x] **Free tier** - Markdown, JSON, XML, CSV, Plain Text functional
- [x] **Premium gates** - All premium features require purchase

### Marketing Materials Ready
- [x] **Privacy Policy** - `privacy.html` created
- [x] **Terms of Service** - `terms.html` created
- [x] **Marketing Page** - `index.html` created
- [x] **App Store Description** - Prepared (see below)
- [x] **Keywords** - Optimized for search
- [x] **Promotional Text** - 170 character version ready
- [x] **Pricing Analysis** - $14.99 recommended and documented

---

## 📋 STEP 1: Website Deployment

Upload these files to your web server:

### Required Files:
- [ ] **`index.html`** → `https://codeedit.sonomaenterprises.com/index.html`
- [ ] **`privacy.html`** → `https://codeedit.sonomaenterprises.com/privacy.html`
- [ ] **`terms.html`** → `https://codeedit.sonomaenterprises.com/terms.html`
- [ ] **`WebServerfeedback.html`** → `https://codeedit.sonomaenterprises.com/WebServerfeedback.html`

### Verify URLs Work:
- [ ] Test privacy policy URL loads
- [ ] Test terms of service URL loads
- [ ] Test marketing page URL loads
- [ ] Test support/feedback URL loads
- [ ] All links between pages work

**URLs to use in App Store Connect:**
```
Privacy Policy: https://codeedit.sonomaenterprises.com/privacy.html
Support URL: https://codeedit.sonomaenterprises.com/WebServerfeedback.html
Marketing URL: https://codeedit.sonomaenterprises.com/index.html (optional)
```

---

## 📋 STEP 2: App Store Connect Setup

### Create App Record
- [ ] Log in to [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Click **"My Apps"** → **"+"** → **"New App"**
- [ ] Select **macOS** platform
- [ ] Enter app name: **"Clarity Code"**
- [ ] Select your primary language: **English (U.S.)**
- [ ] Enter **Bundle ID** (from Xcode project)
- [ ] Enter **SKU**: (e.g., `claritycode-2026` or your choice)

### App Information
- [ ] **App Name**: Clarity Code
- [ ] **Subtitle**: Professional Code Editor
- [ ] **Privacy Policy URL**: `https://codeedit.sonomaenterprises.com/privacy.html`
- [ ] **Category**: Developer Tools
  - **Primary**: Developer Tools
  - **Secondary**: Productivity (optional)

---

## 📋 STEP 3: Create In-App Purchase

### Navigate to IAP
- [ ] In App Store Connect, go to your app
- [ ] Click **"Features"** → **"In-App Purchases"**
- [ ] Click **"+"** to create new IAP

### Configure IAP Product
- [ ] **Type**: Non-Consumable
- [ ] **Reference Name**: Premium Features
- [ ] **Product ID**: `com.claritycodedit.premium`
  
  ⚠️ **CRITICAL**: This MUST match your StoreManager.swift exactly:
  ```swift
  case premiumFeatures = "com.claritycodedit.premium"
  ```

### Pricing & Availability
- [ ] **Price**: Select **Tier 15** ($14.99 USD)
- [ ] **Availability**: All territories
- [ ] **Family Sharing**: ✅ Enabled

### Localization (English - U.S.)
- [ ] **Display Name**: Clarity Code Premium
- [ ] **Description**: 
  ```
  Unlock all 20+ programming languages, intelligent code completion, advanced syntax highlighting, Salesforce Apex support, and professional developer tools. One-time purchase, yours forever.
  ```

### Review Information
- [ ] **Screenshot** (optional but recommended):
  - Take screenshot showing premium features
  - Size: 1280x800 or larger
  - Upload to IAP

### Submit IAP for Review
- [ ] Click **"Submit for Review"**
- [ ] Wait for status: "Waiting for Review" or "Ready to Submit"

---

## 📋 STEP 4: App Store Listing

### App Privacy
- [ ] Click **"App Privacy"** in App Store Connect
- [ ] **Data Collection**: Select **"No, we do not collect data from this app"**
- [ ] Confirm all privacy questions with "No data collected"
- [ ] Save

### Pricing and Availability
- [ ] **Price**: Free (the base app is free)
- [ ] **Availability**: All territories (or your choice)
- [ ] **Pre-order**: Not selected

### Version Information (1.0)

#### App Description (4,000 chars max)
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
- Find and replace with regex support
- Full keyboard shortcuts (Cmd+N, Cmd+O, Cmd+S, Cmd+P, Cmd+F)
- Print with preserved formatting

PREMIUM - UNLOCK FOR JUST $14.99
Upgrade once to unlock everything. No subscription, no recurring fees.

20+ Programming Languages:
- Swift, Python, JavaScript, TypeScript
- Java, C#, C, C++
- Go, Rust, Ruby, PHP
- Salesforce Apex (classes and triggers)
- SQL, HTML, CSS
- And more!

Developer Tools:
- Intelligent code completion
- Advanced syntax highlighting for 20+ languages
- Monospaced font with line numbers
- Real-time language detection

DESIGNED FOR macOS
- Native NSTextView for smooth scrolling
- Full keyboard shortcut support
- System-level undo/redo
- Standard macOS print dialogs
- Retina-optimized interface
- Light and dark mode support

PERFECT FOR:
- Learning to code in multiple languages
- Quick edits without heavy IDEs
- Reviewing code from colleagues
- Salesforce developers (Apex support!)
- Web developers (HTML, CSS, JavaScript)
- Data scientists (Python, SQL, CSV)
- Students and educators
- Anyone who writes code

PREMIUM FEATURES IN DETAIL

Advanced Syntax Highlighting: Over 20 languages with carefully crafted color schemes that highlight keywords, strings, comments, functions, and more.

Auto Language Detection: Paste any code snippet and watch Clarity Code analyze the content to determine the language automatically. No more manual selection needed.

Code Completion: Context-aware suggestions for keywords, functions, and common patterns in all supported languages. Boost your productivity with intelligent autocomplete.

Salesforce Apex Support: First-class support for Salesforce developers with .cls and .trigger file recognition, SOQL highlighting, and Apex-specific code completion.

FILE MANAGEMENT
- Open multiple files simultaneously
- Sidebar file organization
- Save files with Cmd+S
- Context menu actions
- File modification indicators
- UTF-8, ASCII, and Latin-1 encoding support

KEYBOARD SHORTCUTS
Cmd+N - New File
Cmd+O - Open File
Cmd+S - Save File
Cmd+P - Print
Cmd+F - Find & Replace
Cmd+Z - Undo/Redo

PERFORMANCE AND RELIABILITY
Built with Swift and native macOS frameworks for exceptional performance. No Electron, no web wrappers - just pure native code that respects your Mac's resources.

ONE-TIME PURCHASE
No subscription. Pay once, own forever. Premium features unlock across all your Macs via Family Sharing.

PRIVACY FIRST
Your code never leaves your Mac. No cloud sync, no data collection, no analytics. What you write is yours alone.

Start coding smarter today with Clarity Code - where clarity meets capability.
```

#### Keywords (100 chars max)
```
code editor,swift,python,javascript,syntax,developer,programming,apex,salesforce,html,css,java,rust
```

#### Promotional Text (170 chars max)
```
Write, edit, and debug code in 20+ languages with intelligent syntax highlighting, auto-detection, and professional tools. Free to start, premium to master.
```

#### Support URL
```
https://codeedit.sonomaenterprises.com/WebServerfeedback.html
```

#### Marketing URL (Optional)
```
https://codeedit.sonomaenterprises.com/index.html
```

---

## 📋 STEP 5: Screenshots

### Required Sizes for macOS:
You need screenshots in at least TWO sizes:

#### Option 1: Standard Sizes
- [ ] **1280 x 800** pixels (required)
- [ ] **1440 x 900** pixels (required)

#### Option 2: High Resolution (Optional)
- [ ] **2560 x 1600** pixels
- [ ] **2880 x 1800** pixels

### Suggested Screenshots (in order):

1. **Main Editor View**
   - Show code with syntax highlighting
   - Multiple files in sidebar
   - Caption: "Professional code editing with beautiful syntax highlighting"

2. **Language Auto-Detection**
   - Show before/after of pasting code
   - Language badge visible
   - Caption: "Intelligent auto-detection recognizes 20+ languages"

3. **Premium Features Overview**
   - Split view or feature comparison
   - Caption: "Unlock all features with one-time purchase"

4. **Code Completion**
   - Show autocomplete dropdown
   - Caption: "Smart code completion boosts productivity"

5. **Find & Replace (Premium)**
   - Show find/replace interface
   - Caption: "Powerful search with regex support"

6. **Multi-Language Support**
   - Grid of different language examples
   - Caption: "Swift, Python, JavaScript, C#, and 15+ more"

### Screenshot Tips:
- Use light mode for first 3, dark mode for last 3
- Show actual code (use examples from marketing page)
- Keep UI clean and uncluttered
- Show app name in window title
- Highlight key features visually

---

## 📋 STEP 6: Build and Archive

### Prepare Xcode Project

#### Version & Build Numbers
- [ ] Set **Version**: `1.0`
- [ ] Set **Build**: `1`
- [ ] Location: Xcode → Target → General → Identity

#### Bundle Identifier
- [ ] Verify Bundle ID matches App Store Connect
- [ ] Example: `com.yourcompany.claritycode`

#### Signing & Capabilities
- [ ] **Signing**: Automatic (with your Apple Developer account)
- [ ] **Team**: Select your team
- [ ] **Capabilities** enabled:
  - [x] App Sandbox
  - [x] In-App Purchase
  - [x] Hardened Runtime

#### Entitlements Verification
Verify these entitlements exist in your `.entitlements` file:
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.print</key>
<true/>
```

#### Deployment Target
- [ ] Set to **macOS 13.0** (or your minimum version)

### Build Process
1. [ ] Select **"Any Mac"** as destination
2. [ ] **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
3. [ ] **Archive**: Product → Archive (⌘B first to check for errors)
4. [ ] Wait for archive to complete

### Validate Archive
1. [ ] Open **Organizer** (Window → Organizer)
2. [ ] Select your archive
3. [ ] Click **"Validate App"**
4. [ ] Choose signing options:
   - Distribution certificate
   - App Store Connect distribution
5. [ ] Fix any validation errors
6. [ ] Validation should show "No Issues"

### Upload to App Store Connect
1. [ ] In Organizer, click **"Distribute App"**
2. [ ] Select **"App Store Connect"**
3. [ ] Select **"Upload"**
4. [ ] Choose signing options (same as validation)
5. [ ] Click **"Upload"**
6. [ ] Wait for upload to complete (5-15 minutes)

### Verify Processing
- [ ] Go to App Store Connect
- [ ] Navigate to your app → TestFlight or App Store
- [ ] Wait for **"Processing"** to change to **"Ready to Submit"**
- [ ] This can take 30-60 minutes

---

## 📋 STEP 7: Testing (Recommended)

### Create Sandbox Tester
1. [ ] App Store Connect → Users and Access → Sandbox Testers
2. [ ] Click **"+"** to create new tester
3. [ ] Enter unique email (e.g., `test@yourdomain.com`)
4. [ ] Set password
5. [ ] Select region: **United States**

### Test on Your Mac
1. [ ] **Sign out** of App Store (System Settings → App Store)
2. [ ] Run app from Xcode or TestFlight
3. [ ] Try to unlock Premium
4. [ ] When prompted, sign in with sandbox account
5. [ ] Complete "purchase" (free in sandbox)
6. [ ] Verify premium features unlock

### Testing Checklist
#### Free Features
- [ ] Create new Markdown file - syntax works
- [ ] Open JSON file - highlighting works
- [ ] Save file - no errors
- [ ] Multiple files open simultaneously

#### Premium Purchase Flow
- [ ] Premium button visible when trying premium language
- [ ] StoreKit sheet appears with $14.99 price
- [ ] Sandbox purchase completes
- [ ] Premium features unlock immediately
- [ ] Price shows correctly ($14.99)

#### Premium Features (After Purchase)
- [ ] Swift file opens with syntax highlighting
- [ ] Python file opens with syntax highlighting
- [ ] Code completion works
- [ ] Find & Replace works
- [ ] Auto language detection works
- [ ] Restart app - premium still unlocked

#### Error Handling
- [ ] Cancel purchase - app continues working
- [ ] Restore Purchases button works
- [ ] Invalid file type shows error (not crash)

---

## 📋 STEP 8: Submit for Review

### Final Checks Before Submission
- [ ] All screenshots uploaded
- [ ] App description complete
- [ ] Keywords entered
- [ ] Promotional text entered
- [ ] Privacy policy URL working
- [ ] Support URL working
- [ ] IAP created and submitted
- [ ] Build uploaded and processed
- [ ] Age rating completed
- [ ] Copyright information entered

### Select Build
1. [ ] In App Store Connect, go to your app version
2. [ ] Under **"Build"**, click **"+ (plus)"**
3. [ ] Select your uploaded build
4. [ ] Confirm selection

### App Review Information
- [ ] **Contact Information**:
  - First Name: [Your Name]
  - Last Name: [Your Name]
  - Phone: [Your Phone]
  - Email: support@sonomaenterprises.com

- [ ] **Demo Account**: Not required (no login needed)

- [ ] **Notes for Review**:
  ```
  This is a native macOS code editor with a freemium model.

  FREE FEATURES (no purchase needed):
  - Users can edit Markdown, JSON, XML, CSV, and plain text files
  - Full file operations (open, save, print)
  - Find and replace with regex support
  - Unlimited files
  - No time limit or restrictions

  PREMIUM FEATURES (one-time IAP):
  A one-time in-app purchase ($14.99) unlocks:
  - Syntax highlighting for 20+ programming languages
  - Code completion
  - Advanced language auto-detection
  - Salesforce Apex support

  TO TEST PREMIUM FEATURES:
  Please make a sandbox purchase. The IAP product ID is:
  com.claritycodedit.premium

  The app works completely offline and collects zero data.
  All code editing happens locally on the user's Mac.

  Thank you for reviewing Clarity Code!
  ```

### Version Release
- [ ] **Automatic Release**: Release immediately after approval
  - OR -
- [ ] **Manual Release**: Hold for manual release

### Copyright
- [ ] Enter: `2026 Sonoma Enterprises` (or your name/company)

### Age Rating
- [ ] Complete Age Rating questionnaire
- [ ] Expected rating: **4+** (no objectionable content)

### Export Compliance
- [ ] Select: **No encryption** (or follow prompts if applicable)

### Submit!
- [ ] Click **"Add for Review"** or **"Submit for Review"**
- [ ] Confirm submission
- [ ] Status changes to **"Waiting for Review"**

---

## 📋 STEP 9: Post-Submission

### Monitor Status
- [ ] Check App Store Connect daily
- [ ] Status progression:
  1. **Waiting for Review** (1-3 days typically)
  2. **In Review** (1-2 days typically)
  3. **Pending Developer Release** (if manual release)
  4. **Ready for Sale** 🎉

### Respond to Apple (if needed)
- [ ] Check email for any reviewer questions
- [ ] Respond within 24 hours if contacted
- [ ] Be polite and helpful
- [ ] Provide clarifications if needed

### If Rejected
- [ ] Read rejection reason carefully
- [ ] Fix the issues
- [ ] Respond in Resolution Center OR
- [ ] Upload new build if code changes needed
- [ ] Resubmit

---

## 📋 STEP 10: Launch Day! 🚀

### When Approved
- [ ] App appears in Mac App Store
- [ ] Test download from App Store
- [ ] Verify IAP purchase flow works in production
- [ ] Test on fresh Mac (if possible)

### Marketing Launch
- [ ] Share on social media (Twitter, LinkedIn, etc.)
- [ ] Post to Product Hunt (optional)
- [ ] Email mailing list (if you have one)
- [ ] Post in relevant communities (Reddit, forums, etc.)
- [ ] Update website with App Store badge
- [ ] Add App Store link to website

### Monitoring
- [ ] Check App Store Connect Analytics
- [ ] Monitor first reviews
- [ ] Respond to user reviews
- [ ] Track conversion rate (free → paid)
- [ ] Track crash reports (if any)

### Customer Support
- [ ] Set up email forwarding for support@sonomaenterprises.com
- [ ] Prepare FAQ based on common questions
- [ ] Be responsive to early users (24-48 hour response time)

---

## 📊 Success Metrics to Track

### Week 1
- [ ] Total downloads
- [ ] Premium conversion rate
- [ ] Average rating
- [ ] Number of reviews
- [ ] Crash reports (should be zero)

### Month 1
- [ ] Monthly downloads
- [ ] Monthly revenue
- [ ] Conversion rate trend
- [ ] User retention
- [ ] Feature requests from users

### Pricing Review
After 30 days, review:
- If conversion rate > 5%: Consider raising to $19.99
- If conversion rate < 2%: Consider lowering to $9.99 or improving free tier
- If conversion rate 3-5%: Perfect! Keep at $14.99

---

## 📞 Important Links

**App Store Connect:** https://appstoreconnect.apple.com

**Your URLs:**
- Marketing: https://codeedit.sonomaenterprises.com/index.html
- Privacy: https://codeedit.sonomaenterprises.com/privacy.html
- Terms: https://codeedit.sonomaenterprises.com/terms.html
- Support: https://codeedit.sonomaenterprises.com/WebServerfeedback.html

**IAP Product ID:** `com.claritycodedit.premium`

**Price:** $14.99 (Tier 15)

**Contact Emails:**
- support@sonomaenterprises.com
- privacy@sonomaenterprises.com
- legal@sonomaenterprises.com

---

## ✅ Quick Verification

Before submitting, verify:
- [ ] `overridePremiumForTesting = false` in FeatureAccess.swift
- [ ] IAP Product ID matches code exactly
- [ ] Website URLs all work
- [ ] Privacy policy accessible
- [ ] Terms of service accessible
- [ ] Support page accessible
- [ ] Screenshots look professional
- [ ] App description has no typos
- [ ] Price set to $14.99 in App Store Connect
- [ ] Sandbox testing completed successfully

---

## 🎉 YOU'RE READY TO LAUNCH!

Follow this checklist step-by-step and you'll have a successful launch.

**Estimated Timeline:**
- Steps 1-6: 2-4 hours
- Step 7 (Testing): 1-2 hours
- Step 8 (Submit): 30 minutes
- Step 9 (Review): 2-5 days (Apple's timeline)
- Step 10 (Launch): 🚀

**Questions?** Review the documentation:
- `APP_REVIEW_REJECTION_FIX.md` - **🚨 FIX APP REJECTION (IAP + Entitlements)**
- `REJECTION_FIX_QUICK.md` - Quick rejection fix checklist
- `EXPORT_COMPLIANCE_GUIDE.md` - How to resolve "Missing Compliance"
- `PRICING_ANALYSIS.md` - Pricing research and strategy
- `FINAL_PRICING_SUMMARY.md` - Pricing quick reference
- `APP_STORE_READY.md` - Technical configuration
- `privacy.html` - Privacy policy
- `terms.html` - Terms of service

**Good luck with your launch! 🎊**

---

*Last Updated: April 12, 2026*
*Clarity Code by Sonoma Enterprises*
