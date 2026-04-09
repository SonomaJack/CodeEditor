feat: Improve premium feature UX and fix purchase flow

## Major Changes

### Premium File Opening - Graceful Degradation
- Changed premium file blocking to graceful degradation approach
- Premium language files now open as Plain Text instead of being blocked
- Non-blocking upgrade prompt allows users to continue working
- Better UX: users can read/edit files immediately while seeing upgrade option

### Fixed Missing Purchase Button
- Added fallback purchase button in PremiumFeatureView
- Button now shows even if StoreKit products fail to load
- Added .task modifier to auto-load products when sheet appears
- Always shows "Restore Purchases" and "Not Now" options
- Displays $4.99 fallback price if real pricing unavailable

### Settings Feedback Flow
- Fixed feedback button in Settings → About
- Now dismisses Settings before opening Feedback sheet
- Prevents SwiftUI sheet conflict with smooth transition

### Premium Feature Gating
- Disabled debug premium override (overridePremiumForTesting = false)
- Updated free language list: Plain Text, Markdown, JSON, XML, CSV
- Removed Swift from free tier (now premium)
- All programming languages require premium purchase

### Language Detection Improvements
- Reordered content-based detection to prioritize programming languages
- Swift detection now runs before Markdown detection
- Prevents Swift files with # directives from being misidentified as Markdown
- Improved Markdown detection to be more conservative
- Enhanced Swift detection with additional import checks

### Help Documentation Updates
- Updated HelpView with accurate free vs premium language lists
- Added "Upgrade to Premium" call-to-action in languages section
- Updated README_IAP.md with complete feature breakdown
- Updated PremiumFeatureView to show "All 21 programming languages"

## Files Modified

### Core Functionality
- `FeatureAccess.swift`: Disabled debug override, updated free languages
- `ContentView.swift`: Added premium gate for file opening, graceful degradation
- `CodeDocument.swift`: Reordered language detection priority
- `SettingsView.swift`: Fixed feedback button with dismiss/delay pattern

### UI/Premium Flow
- `PremiumFeatureView.swift`: Added fallback purchase button, auto-load products
- `HelpView.swift`: Updated language lists and premium messaging
- `README_IAP.md`: Comprehensive free vs premium feature documentation

### Documentation
- Created `PREMIUM_FEATURES_UPDATE.md`: Complete premium changes documentation
- Created `PREMIUM_UX_IMPROVEMENTS.md`: UX improvement rationale and flows
- Updated `IMPLEMENTATION_SUMMARY.md`: Help system implementation details

## Breaking Changes
- **Premium override disabled**: Debug builds now require actual purchase
- **Free languages changed**: Swift removed, Markdown/JSON/XML added
- **File opening behavior**: Premium files open as Plain Text vs. blocked

## Benefits

### User Experience
- ✅ Can open and edit all files (no blocking)
- ✅ Non-intrusive premium prompts
- ✅ Clear upgrade path with purchase button
- ✅ Better language detection accuracy
- ✅ Smooth settings/feedback navigation

### Business Impact
- ✅ Better conversion potential (users see value)
- ✅ Professional free tier (documentation/data files)
- ✅ Clear premium value proposition
- ✅ Working purchase flow in all scenarios

### Technical
- ✅ Robust premium gating
- ✅ Fallback mechanisms for StoreKit issues
- ✅ Accurate language detection
- ✅ Comprehensive documentation

## Testing Notes

To test premium features during development, temporarily set in FeatureAccess.swift:
```swift
static let overridePremiumForTesting = true
```
⚠️ **Remember to set back to `false` before committing!**

## Migration Notes

Users upgrading from previous version:
- Existing Swift files will open as Plain Text for free users
- Premium users: no changes (all features remain unlocked)
- Free users: can still access all files, just without syntax highlighting
- Purchase flow more reliable with fallback button

## Related Issues

Fixes:
- Premium screen missing purchase button
- Swift files incorrectly detected as Markdown
- Settings feedback button doing nothing
- Files blocked for free users (now graceful degradation)
- Help documentation inaccurate about free/premium split

---

**Version**: 1.0.0
**Date**: April 8, 2026
**Type**: Feature enhancement + Bug fixes
