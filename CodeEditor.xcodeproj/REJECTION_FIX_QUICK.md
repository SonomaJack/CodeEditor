# 🚨 REJECTION FIX - QUICK CHECKLIST

## Two Issues to Fix

### ❌ Issue #1: IAP Not Submitted
**Fix:** Submit your In-App Purchase for review

- [ ] Open App Store Connect
- [ ] Go to Features → In-App Purchases
- [ ] Click on `com.claritycodedit.premium`
- [ ] Add screenshot (1280x800+) showing premium features
- [ ] Click "Submit for Review"
- [ ] Status → "Waiting for Review" ✅

### ❌ Issue #2: Unnecessary Entitlement
**Fix:** Remove downloads folder permission

- [ ] Open `.entitlements` file in Xcode
- [ ] **Delete these lines:**
  ```xml
  <key>com.apple.security.files.downloads.read-write</key>
  <true/>
  ```
- [ ] Save file
- [ ] Clean Build Folder (⇧⌘K)
- [ ] Archive new build
- [ ] Increment build number: 11 → 12

### ✅ Resubmit

- [ ] Developer Reject current submission
- [ ] Upload new build (1.0 build 12)
- [ ] Select new build in App Store Connect
- [ ] Verify IAP is submitted
- [ ] Reply to Apple (optional)
- [ ] Submit for Review again

---

## What to Keep in Entitlements

**KEEP these entitlements:**
```xml
<key>com.apple.security.app-sandbox</key>
<true/>

<key>com.apple.security.files.user-selected.read-write</key>
<true/>

<key>com.apple.security.print</key>
<true/>

<key>com.apple.security.network.client</key>
<true/>
```

**REMOVE this:**
```xml
<!-- ❌ DELETE THIS -->
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

---

## IAP Screenshot Ideas

Take screenshot of:
1. **Premium feature in action** (Swift code with syntax highlighting)
2. **Purchase dialog** (StoreKit sheet showing $14.99)
3. **Before/after** (free vs premium comparison)

Size: 1280x800 minimum  
Format: PNG or JPG

---

## Timeline

- Fix both issues: **30 min**
- Upload new build: **15 min**
- Resubmit for review: **5 min**
- Apple review: **2-5 days**

---

**Detailed Guide:** See `APP_REVIEW_REJECTION_FIX.md`

**Status:** Ready to fix ✅  
**Next Step:** Add IAP screenshot and remove entitlement
