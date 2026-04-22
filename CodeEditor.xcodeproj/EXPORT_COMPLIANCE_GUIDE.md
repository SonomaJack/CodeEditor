# Export Compliance Resolution Guide

## ⚠️ Problem: "Missing Compliance" in App Store Connect

When you try to add a build in App Store Connect, you see:
- ⚠️ **Missing Compliance** status
- Message: "By selecting this build, you'll need to answer a set of questions about your app and your export compliance requirements"

## ✅ Solution: Two Options

---

### Option 1: Answer Questions in App Store Connect (Quick Fix)

This is the **fastest way** to get your current build working:

1. **In App Store Connect**, when you select your build (1.21 (11))
2. You'll see an **Export Compliance** prompt
3. Answer the questions:

   **Q1: "Is your app designed to use cryptography or does it contain or incorporate cryptography?"**
   
   ✅ **Answer: NO**
   
   **Why NO?** Clarity Code:
   - Does NOT use custom encryption algorithms
   - Does NOT contain cryptographic code
   - Only uses standard macOS system APIs (file I/O, text editing)
   - Only uses standard HTTPS (which is exempt)
   - Just edits text files locally

4. After answering **NO**, the compliance status will clear
5. Your build will be available for selection
6. You can proceed with app submission

**When to answer YES:** Only if you:
- Implement custom encryption algorithms
- Include third-party crypto libraries (beyond standard SSL/TLS)
- Export/import encrypted data formats
- Use VPN or secure communication protocols

**Clarity Code does NONE of these**, so answer **NO**.

---

### Option 2: Add to Info.plist (Prevents Future Prompts)

This will **automatically handle compliance** for all future builds:

#### Step 1: Open Your Info.plist

In Xcode:
1. Open your **CodeEditor** project
2. In the Project Navigator, find **Info.plist**
3. Right-click → **Open As** → **Source Code**

#### Step 2: Add Export Compliance Key

Add this to your Info.plist inside the main `<dict>` tag:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

#### Complete Example:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your existing keys -->
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    
    <key>CFBundleDisplayName</key>
    <string>Clarity Code</string>
    
    <!-- ADD THIS KEY -->
    <key>ITSAppUsesNonExemptEncryption</key>
    <false/>
    
    <!-- Your other existing keys -->
</dict>
</plist>
```

#### Step 3: Rebuild and Upload

1. **Clean Build Folder**: Product → Clean Build Folder (⇧⌘K)
2. **Archive**: Product → Archive
3. **Upload** to App Store Connect
4. The new build will **not** show "Missing Compliance"

---

## What Does This Key Mean?

- **`ITSAppUsesNonExemptEncryption`**: Declares whether your app uses custom encryption
- **`<false/>`**: Means you do NOT use non-exempt encryption
- **Exempt encryption** includes:
  - Standard HTTPS/TLS
  - Encrypted file formats (like HTTPS downloads)
  - System-provided encryption APIs
  - Password hashing
  
- **Non-exempt encryption** includes:
  - Custom cryptographic algorithms
  - Third-party crypto libraries
  - VPN or secure tunneling
  - Proprietary encryption schemes

**Clarity Code only uses exempt encryption** (standard system APIs), so `<false/>` is correct.

---

## Recommendation

### For Your Current Build:
Use **Option 1** (answer in App Store Connect) to get your build available immediately.

### For Future Builds:
Add **Option 2** (Info.plist key) so you never see this prompt again.

---

## Verification

After adding the Info.plist key:

1. Archive a new build
2. Upload to App Store Connect
3. Go to your app → Build section
4. The build should show **no compliance warning**
5. You can immediately select it without answering questions

---

## Common Questions

### Q: Will this affect app review?
**A:** No. This is a standard export compliance declaration. Apple requires it for all apps.

### Q: What if I'm not sure about encryption?
**A:** If your app:
- Only edits local files ✅ Answer NO / use `<false/>`
- Only uses HTTPS for web requests ✅ Answer NO / use `<false/>`
- Uses system APIs for file encryption ✅ Answer NO / use `<false/>`
- Implements VPN or custom crypto ❌ Answer YES / use `<true/>`

**Clarity Code = NO / `<false/>`**

### Q: Can I change this later?
**A:** Yes! If you add encryption features later:
1. Update Info.plist to `<true/>`
2. You'll need to provide additional documentation
3. Apple will review your encryption usage

### Q: What happens if I answer wrong?
**A:** If you answer NO but actually use encryption:
- App may be rejected in review
- Apple may request clarification
- You'll need to update and resubmit

**But for Clarity Code, NO is the correct answer.**

---

## For Clarity Code Specifically

✅ **Correct Answer: NO / `<false/>`**

Because Clarity Code:
- ✅ Edits text files locally (no encryption)
- ✅ Saves files to disk (standard file I/O)
- ✅ Uses standard macOS APIs (NSTextView, FileManager)
- ✅ No network requests (except StoreKit, which is exempt)
- ✅ No custom cryptography
- ✅ No third-party crypto libraries
- ✅ No secure communications beyond standard SSL/TLS

**You're good to answer NO!**

---

## Next Steps

1. ✅ **For build 1.21 (11)**: Answer "NO" in App Store Connect
2. ✅ **For future builds**: Add `ITSAppUsesNonExemptEncryption = false` to Info.plist
3. ✅ **Continue with submission**: Your build will be available immediately

---

## Additional Resources

- [Apple's Export Compliance Documentation](https://developer.apple.com/documentation/security/complying_with_encryption_export_regulations)
- [App Store Connect Help: Export Compliance](https://help.apple.com/app-store-connect/#/dev88f5c7bf9)

---

**Last Updated:** April 15, 2026
**Status:** Ready to resolve compliance ✅
