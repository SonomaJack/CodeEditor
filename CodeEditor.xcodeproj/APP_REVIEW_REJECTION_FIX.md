# 🚨 App Review Rejection - Complete Fix Guide

**Date:** April 16, 2026  
**Status:** Rejected - Action Required  
**Submission ID:** 04b8826e-3961-473d-82e6-02024d360326

---

## 📋 Issues Found

### ❌ Issue #1: In-App Purchase Not Submitted
**Guideline:** 2.1(b) - Performance - App Completeness

**Problem:**  
The IAP product `com.claritycodedit.premium` exists in your app but was NOT submitted for review alongside the app binary.

### ❌ Issue #2: Unnecessary Entitlement
**Guideline:** 2.4.5(i) - Performance - Hardware Compatibility

**Problem:**  
Your app has the entitlement `com.apple.security.files.downloads.read-write` but doesn't actually need it.

---

## ✅ SOLUTION #1: Submit In-App Purchase for Review

### Step 1: Add Screenshot to IAP

1. **Open App Store Connect**
2. Go to your app **Clarity Code Edit**
3. Click **Features** → **In-App Purchases**
4. Click on your IAP: **"Clarity Code Premium"** (`com.claritycodedit.premium`)
5. Scroll to **"Review Information"** section
6. Click **"Add Screenshot"**

#### What Screenshot to Upload:
Take a screenshot showing the premium features in action:

**Option A - Premium Feature in Use:**
- Show the app with Swift/Python code with syntax highlighting
- Include the premium badge or indicator
- Size: 1280x800 or larger
- Format: PNG or JPG

**Option B - Purchase Dialog:**
- Show the StoreKit purchase sheet with $14.99 price
- Include app context showing what's being unlocked
- Size: 1280x800 or larger

**Option C - Before/After:**
- Split screen showing free vs. premium features
- Clearly shows value of premium unlock

**Quick Method:**
1. Run your app on your Mac
2. Trigger the premium purchase flow (try to open a Swift file)
3. Press **⇧⌘4** (Shift-Command-4) to take screenshot
4. Upload the screenshot file

### Step 2: Submit IAP for Review

1. Still in the IAP settings, scroll down
2. Click **"Submit for Review"**
3. Status should change to **"Waiting for Review"**
4. ✅ IAP is now submitted!

### Step 3: Verify IAP Status

Before resubmitting app, verify:
- [ ] IAP has screenshot uploaded
- [ ] IAP status is "Waiting for Review" or "Ready to Submit"
- [ ] IAP pricing is $14.99 (Tier 15)
- [ ] IAP display name is clear: "Clarity Code Premium"
- [ ] IAP description explains what unlocks

---

## ✅ SOLUTION #2: Remove Unnecessary Entitlement

### What Happened:
Your app's entitlements file includes `com.apple.security.files.downloads.read-write`, which gives your app permission to read/write files in the user's Downloads folder. 

**Clarity Code doesn't need this** because:
- ✅ You use file picker (user-selected files)
- ✅ User explicitly chooses files = automatic permission
- ✅ No need to access Downloads folder directly

### Fix: Remove the Entitlement

#### Step 1: Find Your Entitlements File

In Xcode:
1. Open your **CodeEditor** project
2. In Project Navigator, look for a file ending in `.entitlements`
   - Usually named: `CodeEditor.entitlements` or `Clarity Code.entitlements`
3. Click to open it

#### Step 2: Remove Downloads Entitlement

Your entitlements file probably looks like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    
    <!-- ❌ REMOVE THIS SECTION -->
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
    <!-- ❌ END REMOVE -->
    
    <key>com.apple.security.print</key>
    <true/>
    
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

**Remove these two lines:**
```xml
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

#### Step 3: Verify Correct Entitlements

After removing, your file should have **ONLY** these:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Sandbox - REQUIRED -->
    <key>com.apple.security.app-sandbox</key>
    <true/>
    
    <!-- User-selected file access - NEEDED (for Open/Save) -->
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    
    <!-- Printing - NEEDED (for Cmd+P) -->
    <key>com.apple.security.print</key>
    <true/>
    
    <!-- Network access - NEEDED (for StoreKit IAP) -->
    <key>com.apple.security.network.client</key>
    <true/>
</dict>
</plist>
```

#### Alternative: Use Xcode UI

If you prefer not to edit XML:

1. Select your **CodeEditor** target
2. Go to **Signing & Capabilities** tab
3. Under **App Sandbox** section, find **File Access**
4. **Uncheck** "Downloads Folder" (Read/Write)
5. Keep checked:
   - ✅ User Selected File (Read/Write)
6. Under **Network**, keep checked:
   - ✅ Outgoing Connections (Client)
7. Under **Printing**, keep checked:
   - ✅ Printing

#### Step 4: Save Changes

- **File** → **Save** (⌘S)
- Verify no errors in Xcode

---

## 🔄 Rebuild and Resubmit

### Step 1: Increment Build Number

1. In Xcode, select your **CodeEditor** target
2. Go to **General** tab → **Identity**
3. Keep **Version**: `1.0`
4. Change **Build**: `11` → `12` (or next number)

### Step 2: Clean and Archive

1. **Product** → **Clean Build Folder** (⇧⌘K)
2. Select destination: **Any Mac (Apple Silicon, Intel)**
3. **Product** → **Archive**
4. Wait for archive to complete

### Step 3: Validate

1. **Window** → **Organizer**
2. Select your new archive
3. Click **"Validate App"**
4. Fix any errors (there shouldn't be any)
5. Validation should pass ✅

### Step 4: Upload

1. In Organizer, click **"Distribute App"**
2. Select **"App Store Connect"**
3. Select **"Upload"**
4. Follow prompts to upload
5. Wait for processing (30-60 minutes)

### Step 5: Select New Build in App Store Connect

1. Go to **App Store Connect**
2. Go to your app → **Version 1.0**
3. Under **Build**, click the **+** button
4. Select your new build (1.0 (12))
5. Answer export compliance: **NO**
6. Build appears in your version

### Step 6: Verify Both Fixes

Before resubmitting:
- [ ] IAP has screenshot uploaded
- [ ] IAP is submitted for review
- [ ] New build uses build number 12+ (not 11)
- [ ] Downloads entitlement removed (check archive)
- [ ] Build validation passed

### Step 7: Reply to Apple (Optional but Recommended)

In App Store Connect, reply to the rejection message:

```
Hello,

Thank you for the feedback. I have addressed both issues:

1. IN-APP PURCHASE: I have now submitted the IAP product 
   "com.claritycodedit.premium" for review with the required 
   screenshot. The IAP is now in "Waiting for Review" status.

2. ENTITLEMENTS: I have removed the unnecessary 
   com.apple.security.files.downloads.read-write entitlement. 
   The app only needs user-selected file access since users 
   explicitly choose files via the standard file picker.

I have uploaded a new build (1.0, build 12) with the corrected 
entitlements and submitted the IAP for review.

Thank you for your time reviewing Clarity Code Edit!

Best regards
```

### Step 8: Resubmit for Review

1. Click **"Submit for Review"**
2. Confirm all information is correct
3. Status changes to **"Waiting for Review"**
4. ✅ Resubmitted!

---

## 📊 Verification Checklist

Before clicking "Submit for Review":

### In-App Purchase:
- [ ] IAP product created: `com.claritycodedit.premium`
- [ ] IAP reference name: "Premium Features" or "Clarity Code Premium"
- [ ] IAP display name: Clear and descriptive
- [ ] IAP description: Explains what unlocks (20+ languages, etc.)
- [ ] IAP price: $14.99 (Tier 15)
- [ ] IAP screenshot: Uploaded and shows premium features
- [ ] IAP status: "Waiting for Review" or "Ready to Submit"
- [ ] IAP family sharing: Enabled

### Entitlements (in .entitlements file):
- [ ] ✅ `com.apple.security.app-sandbox` = true
- [ ] ✅ `com.apple.security.files.user-selected.read-write` = true
- [ ] ✅ `com.apple.security.print` = true
- [ ] ✅ `com.apple.security.network.client` = true
- [ ] ❌ `com.apple.security.files.downloads.read-write` = **REMOVED**

### Build:
- [ ] New build number (12 or higher)
- [ ] Clean build completed
- [ ] Archive validated successfully
- [ ] Uploaded to App Store Connect
- [ ] Processing completed
- [ ] Export compliance answered (NO)
- [ ] Selected in version 1.0

### App Store Connect:
- [ ] All screenshots uploaded
- [ ] App description complete
- [ ] Keywords entered
- [ ] Privacy policy URL working
- [ ] Support URL working
- [ ] Age rating completed
- [ ] Build selected (new build #12)

---

## 🎯 Expected Timeline

- **IAP Review**: 1-2 days (reviewed alongside app)
- **App Review**: 2-5 days after resubmission
- **Total**: ~3-7 days from resubmission

---

## ❓ Common Questions

### Q: Do I need to "Developer Reject" my app?
**A:** Yes, you need to reject the current version to upload a new build.

1. In App Store Connect, find your app version
2. Click the version (1.0)
3. Look for "Developer Rejected" button or similar option
4. Reject the current submission
5. Upload new build
6. Resubmit

### Q: What if I can't find the entitlements file?
**A:** 
1. In Xcode Project Navigator, press ⌘⇧F (Find in Project)
2. Search for: `.entitlements`
3. Or go to Target → Build Settings → search "entitlements"
4. Look for "Code Signing Entitlements" setting
5. The value shows the path to your entitlements file

### Q: Can I just respond to Apple without fixing the entitlements?
**A:** No. You must:
- Upload a new binary with fixed entitlements, OR
- Explain why you need the Downloads folder access (but you don't)

Since you don't need Downloads access, just remove it.

### Q: What if my IAP was already submitted?
**A:** Check the IAP status in App Store Connect:
- If "Waiting for Review" or "In Review" → You're good!
- If "Ready to Submit" → You need to submit it
- If "Missing Metadata" → Add screenshot and submit

### Q: Can I keep the same version number?
**A:** Yes! Keep version **1.0**, just increment the **build** number:
- Version: 1.0 (stays same)
- Build: 11 → 12 (increment)

---

## 🔍 How to Check Entitlements in Archive

To verify the entitlements are correct in your uploaded build:

1. Open **Organizer** (Window → Organizer)
2. Select your archive
3. Right-click → **"Show in Finder"**
4. Right-click archive → **"Show Package Contents"**
5. Navigate to `Products/Applications/YourApp.app/Contents/`
6. Look for file: `embedded.provisionprofile` or `Info.plist`
7. Or use Terminal:
   ```bash
   codesign -d --entitlements :- /path/to/YourApp.app
   ```

You should NOT see `downloads` in the output.

---

## 📧 Resources

- [In-App Purchase Documentation](https://developer.apple.com/in-app-purchase/)
- [App Sandbox Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements)
- [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Entitlements Reference](https://developer.apple.com/documentation/bundleresources/entitlements)

---

## ✅ Summary

**Two simple fixes:**

1. **IAP**: Add screenshot to IAP → Submit IAP for review
2. **Entitlements**: Remove `downloads.read-write` from .entitlements file
3. **Rebuild**: Create new build (increment build number)
4. **Resubmit**: Upload new build and resubmit for review

**Time required:** 30-60 minutes  
**Expected approval:** 3-7 days after resubmission

---

**Good luck! You're almost there! 🚀**

*Last Updated: April 16, 2026*
