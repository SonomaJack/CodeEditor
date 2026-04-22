# 📸 IAP Screenshot Guide

## Why You Need This

Apple requires a screenshot for your In-App Purchase to complete the review. This screenshot shows reviewers what users get when they purchase Premium.

---

## 🎯 What to Screenshot

### Option 1: Premium Feature in Action (RECOMMENDED)

**What to show:**
- Your app editing a Swift or Python file
- Syntax highlighting clearly visible
- Premium language badge/indicator visible
- Clean, professional interface

**How to capture:**
1. Open Clarity Code Edit
2. Create or open a Swift file with code like:
   ```swift
   func calculateSum(_ a: Int, _ b: Int) -> Int {
       return a + b
   }
   ```
3. Make sure syntax highlighting is working (keywords colored)
4. Press **⇧⌘4** (Shift-Command-4)
5. Drag to select the app window
6. Screenshot saves to Desktop

**File name:** `Premium-Syntax-Highlighting.png`

---

### Option 2: Purchase Dialog

**What to show:**
- The StoreKit purchase sheet
- $14.99 price clearly visible
- "Clarity Code Premium" product name
- App in background showing premium feature being unlocked

**How to capture:**
1. Open Clarity Code Edit
2. Try to open a Swift/Python file (triggers premium gate)
3. Premium purchase sheet appears
4. Press **⇧⌘4** (Shift-Command-4)
5. Capture the purchase dialog
6. Screenshot saves to Desktop

**File name:** `Premium-Purchase-Dialog.png`

---

### Option 3: Before/After Comparison

**What to show:**
- Split screen or side-by-side
- Left: Free tier (Markdown or JSON)
- Right: Premium (Swift with syntax highlighting)
- Clear visual difference

**How to create:**
1. Take screenshot of free feature (Markdown)
2. Take screenshot of premium feature (Swift)
3. Use Preview or any image editor to combine side-by-side
4. Add text labels: "Free" and "Premium"

**File name:** `Free-vs-Premium-Comparison.png`

---

## ✅ Screenshot Requirements

### Technical Requirements:
- **Minimum size:** 1280 x 800 pixels
- **Maximum size:** 2880 x 1800 pixels
- **Format:** PNG or JPG
- **File size:** Under 8 MB
- **Transparency:** Not allowed (no transparent backgrounds)

### Content Requirements:
- Shows actual app functionality
- Demonstrates what premium unlocks
- Professional appearance
- No placeholder content
- No Lorem Ipsum text
- Real code examples

### Recommended Sizes:
- **Standard:** 1280 x 800 (works for all Macs)
- **Retina:** 2560 x 1600 (higher quality)
- **Best:** Match your Mac's display resolution

---

## 📝 Quick Capture Workflow

### For macOS Screenshot:

**Full Window:**
1. Press **⇧⌘3** (Shift-Command-3) - captures entire screen
2. Or **⇧⌘4** then **Space** - captures specific window

**Selected Area:**
1. Press **⇧⌘4** (Shift-Command-4)
2. Drag to select area
3. Release to capture

**With Delay (to show dialogs):**
1. Open Screenshot app (⇧⌘5)
2. Click "Options" → "Timer: 5 seconds"
3. Trigger your purchase dialog
4. Screenshot captures automatically after 5 seconds

---

## 🎨 Making It Look Professional

### Before Screenshot:
- [ ] Close unnecessary windows
- [ ] Use professional code example (no profanity, no dummy text)
- [ ] Clean desktop background
- [ ] Hide desktop icons (optional)
- [ ] Set menu bar to auto-hide (optional)

### Code Examples to Use:

**Swift:**
```swift
import Foundation

struct User: Codable {
    let id: Int
    let name: String
    let email: String
    
    func sendNotification() {
        print("Sending notification to \(name)")
    }
}
```

**Python:**
```python
def calculate_fibonacci(n):
    """Calculate Fibonacci sequence up to n terms."""
    sequence = [0, 1]
    
    for i in range(2, n):
        sequence.append(sequence[i-1] + sequence[i-2])
    
    return sequence

# Generate first 10 Fibonacci numbers
result = calculate_fibonacci(10)
print(result)
```

**JavaScript:**
```javascript
class ShoppingCart {
    constructor() {
        this.items = [];
        this.total = 0;
    }
    
    addItem(item, price) {
        this.items.push({ item, price });
        this.total += price;
    }
    
    checkout() {
        console.log(`Total: $${this.total}`);
    }
}
```

---

## 📤 Uploading to App Store Connect

### Step 1: Navigate to IAP
1. Log in to App Store Connect
2. Go to your app: **Clarity Code Edit**
3. Click **Features** → **In-App Purchases**
4. Click on **"Clarity Code Premium"** (`com.claritycodedit.premium`)

### Step 2: Add Screenshot
1. Scroll to **"Review Information"** section
2. Click **"Add Screenshot"** or **"+"**
3. Select your screenshot file
4. Wait for upload to complete
5. Screenshot appears in preview

### Step 3: Verify Upload
- [ ] Screenshot is visible in review section
- [ ] Image is clear and readable
- [ ] File size under 8 MB
- [ ] Correct format (PNG/JPG)

### Step 4: Save Changes
1. Click **"Save"** at top of page
2. Verify no errors
3. Screenshot is now attached to IAP

### Step 5: Submit IAP for Review
1. Scroll to bottom of IAP page
2. Click **"Submit for Review"**
3. Status changes to **"Waiting for Review"**
4. ✅ Done!

---

## 🔍 Verification

Before submitting, verify:
- [ ] Screenshot clearly shows premium feature
- [ ] Code is readable and professional
- [ ] Syntax highlighting is visible
- [ ] Screenshot size meets requirements (1280x800+)
- [ ] IAP status is "Waiting for Review"

---

## 💡 Tips

### Best Practices:
1. **Use real code** - Don't use "Lorem Ipsum" or placeholder text
2. **Show value** - Make it obvious why someone would pay $14.99
3. **Professional appearance** - Clean interface, no errors visible
4. **Good lighting** - Use light mode for better readability in screenshots
5. **Highlight differences** - Show what makes premium worth it

### What NOT to Include:
- ❌ Empty editor windows
- ❌ Lorem Ipsum or dummy text
- ❌ Error messages or crashes
- ❌ Profanity or inappropriate content
- ❌ Personal information (names, emails, etc.)
- ❌ Other apps visible in background
- ❌ Cluttered desktop

### Ideal Screenshot Shows:
- ✅ Your app name in title bar
- ✅ Professional code example
- ✅ Syntax highlighting working perfectly
- ✅ Clean, modern interface
- ✅ Premium feature clearly demonstrated
- ✅ $14.99 price (if showing purchase dialog)

---

## 🎬 Quick Start

**Fastest way to get this done:**

1. **Open your app**
2. **Paste this Swift code:**
   ```swift
   struct ContentView: View {
       @State private var count = 0
       
       var body: some View {
           VStack {
               Text("Count: \(count)")
                   .font(.largeTitle)
               
               Button("Increment") {
                   count += 1
               }
           }
       }
   }
   ```
3. **Press ⇧⌘4** and capture the window
4. **Upload to App Store Connect** → IAP → Review Information
5. **Submit IAP for review**
6. **Done!** ✅

---

## 📊 Example File Names

Good file names for organization:
- `ClarityCode-Premium-Swift-Highlighting.png`
- `ClarityCode-Premium-Purchase-Dialog.png`
- `ClarityCode-Premium-Python-Example.png`
- `ClarityCode-Free-vs-Premium.png`

---

## 🆘 Troubleshooting

### Screenshot Won't Upload
- Check file size (under 8 MB)
- Check format (PNG or JPG only)
- Check dimensions (1280x800 minimum)
- Try converting to PNG if using JPG
- Compress if needed (use Preview → Export → reduce quality)

### Image Too Large
- Open in Preview app
- Tools → Adjust Size
- Change resolution to 1280 x 800
- Save

### Image Too Small
- Must be at least 1280 x 800
- Retake screenshot at higher resolution
- Don't upscale small images (looks blurry)

---

## ✅ Checklist

Before uploading:
- [ ] Screenshot is 1280x800 or larger
- [ ] Shows premium feature clearly
- [ ] Professional code example
- [ ] No personal information visible
- [ ] File size under 8 MB
- [ ] PNG or JPG format
- [ ] No transparency

After uploading:
- [ ] Screenshot visible in IAP settings
- [ ] No upload errors
- [ ] IAP saved successfully
- [ ] IAP submitted for review
- [ ] Status shows "Waiting for Review"

---

**Need help?** See `APP_REVIEW_REJECTION_FIX.md` for complete rejection fix guide.

---

*Last Updated: April 16, 2026*
