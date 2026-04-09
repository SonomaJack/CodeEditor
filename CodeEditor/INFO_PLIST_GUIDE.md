# Info.plist Configuration Guide

## URL Scheme Registration (Optional)

While the URL scheme handler has been implemented in the code, you need to register the custom URL scheme in your Info.plist file for it to work with external links.

### Why Add This?
- Allows `codeeditor://` URLs to open your app
- Enables deep linking from documentation, web pages, or other apps
- Prevents system errors when encountering codeeditor:// URLs

### How to Add URL Scheme

#### Method 1: Using Xcode UI (Recommended)

1. Open your project in Xcode
2. Select your **CodeEditor** target in the project navigator
3. Click the **Info** tab
4. Scroll down to find **URL Types** section (or add it if it doesn't exist)
5. Click the **+** button to add a new URL Type
6. Fill in the following:
   - **Identifier**: `com.codeeditor.urlscheme`
   - **URL Schemes**: `codeeditor` (just type "codeeditor", no slashes)
   - **Role**: `Editor` (select from dropdown)

7. Click outside to save

#### Method 2: Editing Info.plist Directly

If you prefer to edit the Info.plist file directly:

1. Open `Info.plist` in Xcode (as Source Code)
2. Add this XML inside the `<dict>` tag:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>com.codeeditor.urlscheme</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>codeeditor</string>
        </array>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
    </dict>
</array>
```

### Verify Installation

After adding the URL scheme:

1. Build and run your app
2. Quit the app
3. Open Terminal and run:
   ```bash
   open codeeditor://help
   ```
4. Your app should launch and open the help window

### Supported URLs

Once registered, these URLs will work:

| URL | Action |
|-----|--------|
| `codeeditor://help` | Opens help window |
| `codeeditor://settings` | Opens settings |
| `codeeditor://feedback` | Opens feedback form |

### Code Reference

The URL handling is implemented in `CodeEditorApp.swift`:

```swift
.onOpenURL { url in
    handleURL(url)
}

private func handleURL(_ url: URL) {
    guard url.scheme == "codeeditor" else { return }
    
    switch url.host {
    case "help":
        NotificationCenter.default.post(name: .showHelpWindow, object: nil)
    case "settings":
        NotificationCenter.default.post(name: .showSettings, object: nil)
    case "feedback":
        NotificationCenter.default.post(name: .showFeedback, object: nil)
    default:
        print("⚠️ Unknown URL: \(url)")
    }
}
```

## Is This Required?

**No, this is optional!** The help system works perfectly without URL scheme registration because:

- Help is accessed via ⌘/ keyboard shortcut
- Help is accessed via Help menu
- All functionality uses NotificationCenter internally

URL scheme registration is only needed if you want:
- External links to open your app
- Deep linking from documentation
- Integration with other apps or web pages

## Troubleshooting

### URLs Not Opening App

**Problem**: `codeeditor://help` doesn't launch the app  
**Solution**: 
1. Verify Info.plist has URL scheme registered
2. Rebuild and reinstall the app
3. Restart macOS if needed (URL scheme cache)

### App Opens But Nothing Happens

**Problem**: App opens but help doesn't show  
**Solution**: 
1. Check that `handleURL()` function exists in CodeEditorApp.swift
2. Verify notification names match (.showHelpWindow, etc.)
3. Check console for debug messages

### Multiple Apps Handle Same URL

**Problem**: Wrong app opens for codeeditor:// URLs  
**Solution**: 
1. Use unique URL scheme (e.g., `claritycodeedit://`)
2. Update Info.plist and handleURL() function
3. Rebuild app

## Complete Info.plist Example

Here's what a complete URL Types section looks like:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Your existing keys here -->
    
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>com.codeeditor.urlscheme</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>codeeditor</string>
            </array>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
        </dict>
    </array>
    
    <!-- Your other keys here -->
</dict>
</plist>
```

## Future URL Schemes

You could extend this system to support more URL patterns:

```swift
// In handleURL(_ url: URL)
switch url.host {
case "help":
    // Show help window
case "settings":
    // Show settings
case "feedback":
    // Show feedback
case "open":
    // Open a specific file: codeeditor://open?path=/path/to/file.swift
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
       let path = components.queryItems?.first(where: { $0.name == "path" })?.value {
        // Open file at path
    }
case "new":
    // Create new file: codeeditor://new?language=swift
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
       let lang = components.queryItems?.first(where: { $0.name == "language" })?.value {
        // Create new file with specified language
    }
default:
    print("⚠️ Unknown URL: \(url)")
}
```

---

**Note**: This configuration is optional for the current implementation. The help system works perfectly without it!
