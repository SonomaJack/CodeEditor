# Clarity Code Edit

A powerful, native macOS code editor with syntax highlighting for 21+ programming languages.

## ✨ Features

### 📝 Code Editing
- Native macOS text editing with NSTextView
- Real-time syntax highlighting for 21+ languages
- Monospaced font optimized for code
- Line numbers with current line highlighting
- Full horizontal and vertical scrolling
- Undo/redo support
- Smart text selection

### 🔍 Find & Search
- **Find**: Quick search with keyboard shortcuts (⌘F)
- **Find and Replace**: Powerful replace functionality with regex support (Premium)
- **Multi-File Search**: Search across all open files (Premium)
- **Column-Restricted Search**: Search within specific columns (Premium)
- Case sensitivity and whole word matching
- Regular expression support

### 📂 File Management
- Open multiple files with tab-based interface
- Recent files menu
- Auto-save option
- UTF-8, ASCII, and ISO-8859-1 encoding support
- File modification indicators
- Context menu for quick actions
- Drag and drop support

### 💻 Supported Languages

#### Free Languages
- Plain Text
- Markdown
- JSON
- XML
- CSV

#### Premium Languages (21 Total)
- Swift, Python, JavaScript, TypeScript
- Java, Apex (Salesforce)
- C++, C, C#
- Go, Rust, Ruby, PHP
- SQL, HTML, CSS, YAML

### 🎨 Editor Features
- **Zoom**: Adjust font size (8pt-24pt) with ⌘+, ⌘-, ⌘0
- **Go to Line**: Jump to specific line numbers (⌘L)
- **Code Completion**: Intelligent suggestions as you type (Premium)
- **Snippets**: Insert common code patterns (Premium)
- **Split View**: Edit two files side-by-side (Premium)
- **Themes**: Premium color schemes (Premium)

### 🖨️ Printing
- Print with preserved syntax highlighting
- Custom headers and footers (Premium)
- Page numbers and margins
- Professional formatting

### ⚙️ Customization
- Adjustable font size
- Toggle status bar
- Toggle line numbers
- Auto-detect language from content
- Auto-save configuration
- Premium theme selection

## 🚀 Getting Started

### Creating a New File
1. Press **⌘N** or click the **+** button
2. Enter a filename (optional)
3. Select your language or enable auto-detection
4. Start coding!

### Opening Files
1. Press **⌘O** or click the folder icon
2. Select your code file
3. The editor automatically detects the language

### Quick Tips
- 💡 Enable auto-detection (🪄 icon) for smart language detection
- 💡 Use ⌘L to quickly jump to any line
- 💡 Right-click files for quick actions
- 💡 Status bar shows cursor position and file stats

## ⌨️ Essential Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| New File | ⌘N |
| Open File | ⌘O |
| Save | ⌘S |
| Find | ⌘F |
| Find and Replace | ⌥⌘H |
| Go to Line | ⌘L |
| Zoom In/Out | ⌘+/⌘- |
| Print | ⌘P |
| Help | ⌘/ |
| Settings | ⌘, |

[See complete shortcut list in Help (⌘/)]

## 🏆 Premium Features

Unlock all features with a one-time premium upgrade:

✅ All 21 programming languages  
✅ Find and Replace with regex  
✅ Column-restricted search  
✅ Code completion  
✅ Print with headers & footers  
✅ Premium color themes  
✅ Split view editing  
✅ Code snippets & templates  
✅ Multi-file search  
✅ Git integration  
✅ Advanced customization  

## 📚 Documentation

- **In-App Help**: Press ⌘/ to access comprehensive help
- **User Guide**: See [USER_GUIDE.md](USER_GUIDE.md) for complete documentation
- **Features**: See [FEATURES.md](FEATURES.md) for technical details
- **Changelog**: See [CHANGELOG.md](CHANGELOG.md) for version history

## 🛠️ Technical Details

### Architecture
- **SwiftUI** for modern, native macOS interface
- **NSTextView** for high-performance text editing
- **AttributedString** for syntax highlighting
- **StoreKit** for in-app purchases
- **Notification-based** event system

### File Structure
```
CodeEditor/
├── CodeEditorApp.swift          # App entry point, menu commands, URL handling
├── ContentView.swift            # Main UI, file management, tab interface
├── CodeEditorView.swift         # Editor view, toolbar, panels
├── CodeTextView.swift           # NSTextView wrapper, syntax highlighting
├── CodeDocument.swift           # Document model, load/save operations
├── HelpView.swift               # In-app help documentation
├── SettingsView.swift           # Settings and preferences
├── FindView.swift               # Find panel UI
├── ReplaceView.swift            # Replace panel UI
├── SyntaxHighlighter.swift      # Syntax highlighting engine
├── CodeCompletionEngine.swift   # Code completion logic
└── StoreManager.swift           # In-app purchase handling
```

### Requirements
- macOS 13.0 or later
- Xcode 15.0 or later (for development)

## 🐛 Bug Reports & Feedback

Use **Help → Send Feedback** in the app or access via **Settings → About**.

## 📝 Recent Changes (v1.0.0)

### Added
- Comprehensive in-app help system
- Complete keyboard shortcut documentation
- User guide and changelog files

### Fixed
- URL scheme handling for internal links
- Infinite loop bug in help notification system
- Application hang when accessing help menu

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

## 🎓 Salesforce (Apex) Development

Special support for Salesforce developers:

- **.cls** and **.trigger** file support
- Apex syntax highlighting (keywords, annotations, DML, SOQL)
- 60+ Apex-specific code completion suggestions
- Trigger pattern recognition
- Salesforce-specific data types and collections

Perfect for developing Apex classes, triggers, test classes, and more!

## 🔐 Privacy

- All editing happens locally on your Mac
- No data sent to external servers
- Files saved with standard macOS permissions
- StoreKit for secure in-app purchases

## 📄 License

© 2026 Clarity Code Edit. All rights reserved.

---

## Quick Links

- [User Guide](USER_GUIDE.md) - Complete documentation
- [Features](FEATURES.md) - Technical feature list
- [Changelog](CHANGELOG.md) - Version history
- **Help**: Press ⌘/ in the app

---

**Made with ❤️ for macOS developers**
