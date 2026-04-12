# TestFlight In-App Purchase Setup Guide

## Issue
"Unlock Premium" button does nothing in TestFlight because the IAP product hasn't been configured in App Store Connect.

## Why It Doesn't Work

### In Xcode (Development)
- Uses **StoreKit Configuration File** (local testing)
- Products are defined in `.storekit` file
- Works without App Store Connect

### In TestFlight (Production Testing)
- Uses **real App Store Connect** products
- Requires IAP product to be created
- Requires product to be submitted for review
- **Does NOT use .storekit file**

## Solution: Set Up IAP in App Store Connect

### Step 1: Create IAP Product in App Store Connect

1. **Go to App Store Connect**
   - https://appstoreconnect.apple.com

2. **Navigate to Your App**
   - My Apps → Select your app

3. **Go to In-App Purchases**
   - Click "In-App Purchases" tab
   - Or: Features → In-App Purchases

4. **Create New IAP**
   - Click **+** or "Create"
   - Select Type: **Non-Consumable**
   - Click "Create"

5. **Configure Product**
   - **Product ID**: `com.claritycodedit.premium`
     ⚠️ **MUST MATCH** the ID in ProductID enum
   - **Reference Name**: Premium Features
   - **Review Screenshot**: Upload a screenshot showing the feature
   - Click "Save"

6. **Add Pricing**
   - Click "Pricing and Availability"
   - Select **Price**: $4.99 USD (or equivalent)
   - Set **Availability**: All territories
   - Click "Save"

7. **Add Localized Information**
   - Click "App Store Localization"
   - Add for **English (U.S.)**:
     - **Display Name**: Premium Features
     - **Description**: Unlock all 21 programming languages, Find & Replace, Code Completion, Printing, Split View, Code Snippets, Multi-file Search, Git Integration, Premium Themes, and advanced customization.
   - Click "Save"

8. **Submit for Review**
   - Click "Submit" button
   - IAP must be reviewed and approved before it works in TestFlight
   - ⚠️ **Can take 24-48 hours** for approval

### Step 2: Add IAP to Your Build

1. **In App Store Connect**
   - Go to: TestFlight → Builds
   - Select your build
   - Click "In-App Purchases and Subscriptions"
   - Enable your Premium Features IAP
   - Click "Save"

### Step 3: Create Sandbox Tester Account

1. **In App Store Connect**
   - Users and Access → Sandbox Testers
   - Click **+** to add tester

2. **Fill In Details**
   - First Name: Test
   - Last Name: User
   - Email: **Use a NEW email** (not used for Apple ID)
   - Password: Create strong password
   - Country: United States (or your test region)
   - Click "Save"

### Step 4: Test in TestFlight

1. **On Your Test Device**
   - Settings → App Store
   - Scroll down to "Sandbox Account"
   - Sign in with sandbox tester email

2. **Launch App from TestFlight**
   - Open your app
   - Tap "Unlock Premium"
   - Should show purchase dialog with $4.99 price
   - Complete purchase (will be free in sandbox)

3. **Verify**
   - Premium features should unlock
   - Check console logs for purchase messages

## Troubleshooting

### "Unlock Premium" Does Nothing

**Possible Causes:**

1. **Products Not Loading**
   ```
   Check Console for:
   "Failed to load products: ..."
   ```
   **Fix**: Ensure Product ID matches exactly

2. **Product Not Approved**
   ```
   App Store Connect shows: "Waiting for Review"
   ```
   **Fix**: Wait for Apple approval (24-48 hours)

3. **Product Not Added to Build**
   ```
   IAP not associated with TestFlight build
   ```
   **Fix**: Add IAP to build in TestFlight settings

4. **Sandbox Account Issue**
   ```
   Not signed in to sandbox account
   ```
   **Fix**: Sign in to sandbox in Settings → App Store

### Check Console Logs

With the updated code, you'll see:
```
🛒 Attempting to purchase: com.claritycodedit.premium
✅ Purchase successful, verifying...
✅ Transaction finished and products updated
```

Or errors like:
```
❌ Failed to load products: ...
❌ User cancelled purchase
⏳ Purchase is pending
```

### Product ID Mismatch

**In Code (StoreManager.swift):**
```swift
case premiumFeatures = "com.claritycodedit.premium"
```

**Must Match App Store Connect:**
```
Product ID: com.claritycodedit.premium
```

⚠️ They are **case-sensitive** and must be **exactly the same**!

## Quick Fix for Immediate Testing

If you need to test NOW before App Store approval:

### Option 1: Enable Debug Override (Temporary)

In `FeatureAccess.swift`:
```swift
static let overridePremiumForTesting = true
```

⚠️ **Remember to set back to `false` before releasing!**

### Option 2: Use StoreKit Configuration (Xcode Only)

This only works in Xcode, not TestFlight:

1. **Create StoreKit Config**
   - File → New → File
   - StoreKit Configuration File
   - Name: `Products.storekit`

2. **Add Product**
   - Click **+** → Add Non-Consumable
   - Product ID: `com.claritycodedit.premium`
   - Reference Name: Premium Features
   - Price: $4.99

3. **Enable in Scheme**
   - Product → Scheme → Edit Scheme
   - Run → Options
   - StoreKit Configuration: Select `Products.storekit`

4. **Test in Xcode**
   - Run app in simulator/device from Xcode
   - Purchase will work immediately

## Expected Timeline

| Step | Time Required |
|------|---------------|
| Create IAP in App Store Connect | 5 minutes |
| Submit IAP for review | Instant |
| **Apple Review** | **24-48 hours** |
| Add IAP to TestFlight build | 2 minutes |
| Create sandbox tester | 2 minutes |
| Test purchase | 1 minute |
| **Total** | **1-2 days** |

## Verification Checklist

Before TestFlight works:

- [ ] IAP created in App Store Connect
- [ ] Product ID: `com.claritycodedit.premium` (exact match)
- [ ] Pricing set to $4.99
- [ ] Localized information added
- [ ] Review screenshot uploaded
- [ ] **IAP submitted and approved** ⚠️
- [ ] IAP added to TestFlight build
- [ ] Sandbox tester account created
- [ ] Sandbox account signed in on device
- [ ] App launched from TestFlight

## Console Output to Monitor

With improved logging, watch for:

**Good Signs:**
```
🛒 Purchase button clicked
🛒 Attempting to purchase: com.claritycodedit.premium
✅ Purchase successful, verifying...
✅ Transaction finished and products updated
✅ Purchase completed successfully
```

**Warning Signs:**
```
❌ Failed to load products: ...
❌ User cancelled purchase
⏳ Purchase is pending
⚠️ Unknown purchase result
```

**Products Loading:**
```
🔍 Loading products...
✅ Loaded 1 product(s)
```

Or:
```
❌ Failed to load products: [Error description]
```

## Alternative: Test Locally First

Before dealing with TestFlight:

1. **Create StoreKit Configuration file**
2. **Test in Xcode simulator**
3. **Verify purchase flow works**
4. **Then** set up App Store Connect
5. **Then** test in TestFlight

This lets you catch code issues before dealing with App Store approval delays.

## Product ID Reference

Your current product ID is:
```
com.claritycodedit.premium
```

If you need to change it:
1. Update in `StoreManager.swift` → `ProductID` enum
2. Update in App Store Connect → IAP Product ID
3. Both must match EXACTLY

## Summary

**Why it doesn't work in TestFlight:**
- No IAP product configured in App Store Connect

**Solution:**
- Create IAP in App Store Connect
- Submit for review (24-48 hours)
- Add to TestFlight build
- Test with sandbox account

**Quick workaround for NOW:**
- Use `overridePremiumForTesting = true` temporarily
- Or test in Xcode with StoreKit Configuration

**Long-term solution:**
- Get IAP approved in App Store Connect
- Will work in both TestFlight and production

---

**Updated**: Added better logging to StoreManager and PremiumFeatureView  
**Console**: Now shows detailed purchase flow messages  
**Debugging**: Check Xcode console for detailed error messages  
