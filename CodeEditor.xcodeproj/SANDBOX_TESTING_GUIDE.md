# 🧪 Sandbox Testing Setup - Step by Step

**Why Sandbox:** Works immediately, free testing, doesn't require IAP to be synced

---

## 🎯 Step 1: Create Sandbox Tester Account

### In App Store Connect:

1. **Go to:** [appstoreconnect.apple.com](https://appstoreconnect.apple.com)
2. Click **"Users and Access"** (top navigation)
3. Click **"Sandbox Testers"** (left sidebar)
4. Click **"+"** button (top left)

### Fill in the Form:

**Required Fields:**
- **First Name:** Test
- **Last Name:** User
- **Email:** Must be UNIQUE (not used for any Apple ID)
  
  **Options:**
  - Use a new email: `test.clarity@yourdomain.com`
  - Use Gmail + trick: `youremail+sandbox@gmail.com`
  - Use any unique email you control

- **Password:** Create a strong password (8+ characters, number, uppercase)
  - Example: `TestPass123`
  - **Write it down!** You'll need it.

- **Country/Region:** United States

- **App Store Storefront:** United States

**Click "Create"**

✅ Sandbox account created!

---

## 🎯 Step 2: Sign Out of App Store on Mac

**IMPORTANT:** Only sign out of App Store, NOT iCloud!

### How to Sign Out:

1. **System Settings** (or System Preferences)
2. Click **"App Store"** (or "Media & Purchases" on older macOS)
3. Click your **Apple ID name**
4. Click **"Sign Out"**
5. Confirm sign out

**Verify:**
- App Store section should show "Sign In"
- iCloud should still be signed in

⚠️ **DO NOT sign out of iCloud!** Only App Store.

---

## 🎯 Step 3: Run App from Xcode

### Launch the App:

1. Open **Xcode**
2. Open your **Clarity Code** project
3. Select destination: **"My Mac"**
4. Press **⌘R** (Product → Run)
5. App launches on your Mac

### Watch the Console:

In Xcode's debug console (bottom), you should see:
```
🏪 StoreManager initializing...
📦 Loading products from App Store...
📦 Requesting products: ["com.yourcompany.claritycode.premium"]
```

**In Sandbox, products will load with $0.00 price:**
```
✅ Product loaded: com.yourcompany.claritycode.premium - ... - $0.00
📦 Loading complete. Found 1 product(s)
```

---

## 🎯 Step 4: Trigger Premium Purchase

### In the Running App:

1. **File** → **Open** (or ⌘O)
2. Navigate to any `.swift` file (or create one)
3. Select and open it
4. Premium dialog appears: "Premium Feature - Syntax highlighting for Swift requires Premium"

### Click "Unlock Premium"

The StoreKit purchase sheet should appear!

---

## 🎯 Step 5: Sign In with Sandbox Account

### When StoreKit Sheet Appears:

**You'll see:**
- Product: "Clarity Code Premium"
- Price: **$0.00** (sandbox shows free)
- Apple ID login prompt

**Sign In:**
1. Enter **sandbox tester email** (the one you created)
2. Enter **sandbox password**
3. Click **"Buy"** or **"Subscribe"**

**Possible Prompt:**
If you see "This Apple ID has not yet been used in the iTunes Store":
1. Click **"Review"**
2. **Accept** Terms and Conditions
3. Click **"Continue"**
4. Complete the purchase

---

## 🎯 Step 6: Verify Purchase

### In Xcode Console:

You should see:
```
🛒 Purchase button clicked
✅ Purchase successful, verifying...
✅ Transaction finished and products updated
🔐 Premium check: ✅ HAS PREMIUM
```

### In the App:

- Premium dialog dismisses
- Swift file opens with **syntax highlighting**! 🎉
- All premium features are now unlocked

---

## 🎯 Step 7: Test Premium Features

**Try these to verify everything works:**

1. **Syntax Highlighting:**
   - Open Swift file → colorized code ✅
   - Open Python file → colorized code ✅
   - Open JavaScript file → colorized code ✅

2. **Code Completion:**
   - Type in Swift file
   - Suggestions appear ✅

3. **Settings Check:**
   - Settings → Premium tab
   - Should show "Premium Unlocked" ✅
   - Thank you message appears ✅

4. **Restart Test:**
   - Quit app completely (⌘Q)
   - Relaunch from Xcode (⌘R)
   - Premium still unlocked ✅
   - No purchase prompt ✅

---

## ✅ Success Indicators

### Console Shows:
```
🏪 StoreManager initializing...
📦 Loading products from App Store...
✅ Product loaded: com.yourcompany.claritycode.premium - Clarity Code Premium - $0.00
📦 Loading complete. Found 1 product(s)
💎 PURCHASE BUTTON TAPPED!
🛒 Purchase button clicked
✅ Purchase successful, verifying...
✅ Transaction finished and products updated
🔐 Premium check: ✅ HAS PREMIUM
```

### In App:
- ✅ Swift files show syntax highlighting
- ✅ All 21 languages available
- ✅ Premium badge in Settings shows "Unlocked"
- ✅ No more premium prompts

---

## 🚨 Troubleshooting

### Issue: "Cannot Connect to iTunes Store"

**Fix:**
1. Make sure you signed out of App Store (System Settings)
2. Don't use sandbox email for iCloud
3. Restart Xcode
4. Try again

---

### Issue: Products Still Show "0 products"

**Check:**
```
📦 Requesting products: ["com.yourcompany.claritycode.premium"]
⚠️ No products returned from App Store
```

**Fix:**
1. Verify you're signed OUT of App Store
2. Check internet connection
3. Verify sandbox account created correctly
4. Wait a few minutes and try again
5. Check that Product ID matches exactly

---

### Issue: "This Apple ID is not valid"

**Fix:**
1. Make sure you created the sandbox account in App Store Connect
2. Double-check email and password
3. Email must be unique (not used for real Apple ID)
4. Try creating a different sandbox account

---

### Issue: Purchase Completes but Premium Doesn't Unlock

**Check Console:**
```
✅ Purchase successful
🔐 Premium check: ❌ NO PREMIUM  ← Problem!
```

**Fix:**
1. Check `FeatureAccess.swift` → `overridePremiumForTesting` should be `false`
2. Restart app
3. Check `StoreManager.swift` → `hasPremiumFeatures` logic
4. Try "Restore Purchases" in Settings

---

### Issue: Sandbox Purchase Asks for Payment Method

**This shouldn't happen in sandbox, but if it does:**

**Fix:**
1. Make sure you're signed OUT of App Store
2. Close app completely
3. Verify sandbox account in App Store Connect
4. Sign out and sign back in to sandbox account
5. Try again

---

## 📋 Complete Sandbox Testing Checklist

### Setup:
- [ ] Created sandbox tester in App Store Connect
- [ ] Email is unique (not used for real Apple ID)
- [ ] Password is strong and saved
- [ ] Signed out of App Store on Mac (System Settings)
- [ ] iCloud still signed in (only App Store signed out)

### Testing:
- [ ] Opened Xcode project
- [ ] Ran app (⌘R)
- [ ] Console shows "Found 1 product(s)"
- [ ] Products show $0.00 (sandbox price)
- [ ] Triggered premium (opened .swift file)
- [ ] Clicked "Unlock Premium"
- [ ] StoreKit sheet appeared
- [ ] Signed in with sandbox account
- [ ] Purchase completed (free)
- [ ] Console shows "HAS PREMIUM"
- [ ] Premium features unlocked
- [ ] Restart app → Still unlocked

### Verification:
- [ ] Swift syntax highlighting works
- [ ] Python syntax highlighting works
- [ ] All 21 languages available
- [ ] Code completion works
- [ ] Settings shows "Premium Unlocked"
- [ ] No crashes or errors

---

## 🎉 After Successful Sandbox Testing

**You've verified:**
- ✅ IAP purchase flow works
- ✅ Premium features unlock correctly
- ✅ Purchase persists after restart
- ✅ All premium features functional
- ✅ No crashes or errors

**Next steps:**
1. Sign back in to App Store (System Settings)
2. Wait for production IAP to sync (2-4 hours)
3. Test with TestFlight (real $14.99 purchase)
4. OR proceed to release!

---

## 🔄 Signing Back Into App Store

**When you're done testing:**

1. **System Settings** → **App Store**
2. Click **"Sign In"**
3. Enter your **real Apple ID** (not sandbox)
4. Sign in
5. Back to normal!

**Sandbox purchases won't affect your real Apple ID.**

---

## ✅ Quick Reference

**Sandbox Tester Email:** `_____________________` (write yours here)  
**Sandbox Password:** `_____________________` (write yours here)

**To Test Again:**
1. Sign out of App Store
2. Run from Xcode (⌘R)
3. Purchase with sandbox account
4. Test features

**To Stop Testing:**
1. Sign back in to App Store (System Settings)
2. Use real Apple ID

---

## 🎯 Summary

**Sandbox Testing = Immediate + Free + Full Testing**

1. Create sandbox account → 2 min
2. Sign out of App Store → 30 sec
3. Run from Xcode → 10 sec
4. Purchase (free) → 30 sec
5. Test features → 5 min

**Total: ~8 minutes to full testing!**

---

**Ready to start? Follow the steps above and tell me when you get to Step 5 (signing in with sandbox account)!**
