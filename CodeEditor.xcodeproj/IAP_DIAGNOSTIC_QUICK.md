# 🔍 Quick IAP Diagnostic

## Run This NOW:

### Step 1: Open Console.app
1. Press **⌘Space** (Spotlight)
2. Type: **Console**
3. Press **Enter**

### Step 2: Filter Logs
In Console app:
- Search box (top right): Type **`StoreManager`**
- Or search: **`Premium`**

### Step 3: Trigger Purchase
1. Open Clarity Code Edit (from TestFlight)
2. File → Open → Select a `.swift` file
3. Click **"Unlock Premium"** button

### Step 4: Read the Logs

**Look for this:**

#### ✅ WORKING (Products loaded):
```
📦 Loading products from App Store...
📦 Requesting products: ["com.claritycodedit.premium"]
✅ Product loaded: com.claritycodedit.premium - ... - $14.99
📦 Loading complete. Found 1 product(s)
💎 Showing REAL purchase button with price: $14.99
💎 PURCHASE BUTTON TAPPED!
```

**Result:** IAP should trigger. If button still does nothing → Check entitlements

---

#### ❌ NOT WORKING (No products):
```
📦 Loading products from App Store...
📦 Requesting products: ["com.claritycodedit.premium"]
⚠️ No products returned from App Store
📦 Loading complete. Found 0 product(s)
💎 Showing FALLBACK button (products didn't load)
```

**Result:** IAP not accessible → Check App Store Connect

---

## What the Logs Mean:

### If you see "Found 0 product(s)":
**Cause:** IAP not approved OR not synced yet

**Fix:**
1. Go to App Store Connect
2. Features → In-App Purchases  
3. Check status of `com.claritycodedit.premium`
4. **Status should be "Approved"**
5. If "Waiting for Review" → Wait for approval (1-2 days)
6. If "Ready to Submit" → Submit it NOW
7. If "Approved" → Wait 2-4 hours for sync

### If you see "Found 1 product(s)" but button does nothing:
**Cause:** Purchase not triggering

**Fix:**
1. Check entitlements file has:
   ```xml
   <key>com.apple.security.network.client</key>
   <true/>
   ```
2. Check Signing & Capabilities has "In-App Purchase"
3. Restart TestFlight app
4. Reinstall app from TestFlight

### If you see purchase button tapped but no sheet:
**Cause:** StoreKit not showing purchase UI

**Fix:**
1. Verify signed in to App Store (System Settings)
2. Check payment method is valid
3. Try restarting Mac
4. Try sandbox testing instead (works even if IAP not approved)

---

## Copy/Paste This:

**Send me these 3 things:**

1. **IAP Status:**
   - Go to App Store Connect → Features → In-App Purchases
   - What's the status of `com.claritycodedit.premium`?
   - Copy/paste the status

2. **Console Output:**
   - Copy the entire log output from Console.app
   - Paste here

3. **What Happens:**
   - Click button → Nothing happens?
   - Click button → Sheet appears then disappears?
   - Click button → Error message?

---

## Quick Answer Guide:

**Q: What does the button say?**
- "Unlock Premium $14.99" (no product loaded)
- "Unlock Premium [real price]" (product loaded ✅)

**Q: What happens when you click?**
- Nothing (check console for errors)
- Sheet appears (good!)
- Sheet disappears immediately (sign-in issue)
- Error message (paste the error)

**Q: What's in Console after clicking?**
- "PURCHASE BUTTON TAPPED!" (button works)
- "Purchase button clicked" (purchase started)
- "Purchase error: ..." (failed - paste error)
- Nothing (button not triggering)

---

## 🎯 Most Likely: IAP Not Approved

**Check App Store Connect RIGHT NOW:**

1. Log in to appstoreconnect.apple.com
2. Your app → Features → In-App Purchases
3. Find: "Clarity Code Premium"
4. Look at **STATUS**

**If "Waiting for Review":**
- ⏳ Still being reviewed
- ⏳ Wait 1-2 days
- ❌ Won't work in TestFlight until approved

**If "Ready to Submit":**
- ❌ Not submitted yet!
- ✅ Click "Submit for Review" NOW
- ⏳ Wait 1-2 days for approval

**If "Approved":**
- ✅ Approved!
- ⏳ Wait 2-4 hours for servers to sync
- 🔄 Try again later

---

**Most Important:** Check IAP status in App Store Connect FIRST before anything else!
