# COMMIT MESSAGE FOR GITHUB

Use this comprehensive commit message for your next commit:

---

## Commit Title:
```
Major Update: Feedback System, Line Number Fixes, Enhanced Find/Replace with Special Characters
```

## Commit Body:
```
This major update includes significant improvements to the Code Editor app with new features, bug fixes, and comprehensive testing infrastructure.

### ✨ New Features

#### Feedback System
- Added "Send Feedback" to Help menu and Settings → About
- Feedback form with Bug Report, Feature Request, and General categories
- Optional email field for follow-up responses
- System information auto-included (app version, macOS version, premium status)
- Dual submission methods: Open Email & Copy to Clipboard
- Success messages with auto-hide after 3 seconds

#### Special Characters in Find/Replace
- Special character picker with visual menu
- Supports: Tab (\t), Newline (\n), CR (\r), CR+LF (\r\n), Space, NBSP
- User-friendly interface with descriptions
- Works in both Find and Replace fields
- Proper handling of line break searches across entire document

#### Replace Enhancements
- Undo support with stack-based history (up to 10 operations)
- Completion messages showing count of replacements
- "Replaced X occurrence(s)" feedback
- Undo button with visual feedback (⟲ icon)
- Proper handling of column-restricted replace all

#### Drag and Drop
- Drop files on sidebar, editor area, or welcome screen
- Visual feedback with dashed blue border during drag
- Supports single and multiple file drops
- Accepts all text file types
- Auto-opens and selects dropped files

#### Context Menu Enhancements
- "Show in Finder" option for files in sidebar
- Opens Finder and selects the file
- Properly disabled for unsaved files
- Context menu: Save, Save As, Show in Finder, Close

### 🐛 Bug Fixes

#### Line Number Display
- Fixed "all 1s" issue when pasting text
- Fixed blank line numbers not appearing
- Fixed line numbers for newly created blank lines (pressing Return)
- Fixed line numbers scrolling with text content
- Fixed separator line extending above text area
- Line numbers now work for typed text, pasted text, and loaded files
- Position estimation for blank lines without layout rects

#### Find and Replace
- Fixed column-restricted Replace All (now replaces all matches, not just first)
- Fixed newline/CR/CRLF searches (added special document-wide search)
- Fixed search results for line break characters
- Proper line-by-line replacement to maintain column positions
- Find/Replace cursor auto-focuses on open

#### UI Fixes
- Fixed sidebar rounded rectangle overlaying status bar
- Added proper clipping to sidebar content
- Fixed separator line drawing only within text bounds
- Better visual hierarchy and layering

#### Print Fixes
- Fixed text truncation on right side
- Proper margin calculation (36pt left, 36pt right)
- Headers and footers align correctly with content
- No text cutoff when printing

### 🎨 UI/UX Improvements

#### Cursor Position Tracking
- Real-time line and column position updates in status bar
- Updates on cursor movement (click, arrow keys)
- Updates during text editing
- Shows selection length when text selected

#### Premium Features Thank You
- Custom thank you message after purchase
- "Thank you for your purchase of Code Editor..."
- Feedback guidance in Premium settings
- Better user communication and appreciation

#### File Opening
- Opens any text file (not just recognized code files)
- Defaults to Plain Text for unknown extensions
- More flexible and user-friendly

### 🧪 Testing Infrastructure

#### Unit Tests (Swift Testing)
- FindReplaceTests.swift: 15+ test cases
  - Find single/multiple occurrences
  - Case sensitive search
  - Replace operations
  - Line break handling
  - Column-restricted search
  - Whole word search
  - Special characters

- CodeDocumentTests.swift: 11+ test cases
  - Document creation
  - Language detection
  - File extensions
  - Unicode handling
  - Large file handling

#### UI Tests (XCTest)
- CodeEditorUITests.swift: 20+ test cases
  - File operations (create, open)
  - Find and Replace panels
  - Settings navigation
  - Keyboard shortcuts
  - Performance tests
  - Menu interaction

#### Test Plan
- TEST_PLAN.md: Comprehensive manual testing checklist
- 300+ test cases across 17 categories
- Covers all features, edge cases, and regressions
- Sign-off section for QA

#### Bug Tracking
- GitHub issue templates for Bug Reports
- GitHub issue templates for Feature Requests
- Severity and priority classifications
- Environment and reproduction information

### 📚 Documentation
- Comprehensive test plan with 17 major sections
- Bug report template with severity levels
- Feature request template with use cases
- All templates follow GitHub best practices

### 🔧 Technical Improvements

#### Line Number Implementation
- Uses NSString.enumerateSubstrings for accurate line detection
- Handles all line ending types (LF, CR, CRLF)
- Position estimation fallback for unlaid-out lines
- Proper scroll notifications and redrawing
- Performance optimized for large files

#### Find/Replace Algorithm
- Special handling for line break searches
- Document-wide search when searching for \n or \r
- Line-by-line processing for column restrictions
- Right-to-left replacement to maintain positions
- Grouped replacements by line number

#### Undo System
- Stack-based undo history
- Limits to 10 states to prevent memory issues
- State saved before each replace operation
- Works with both single replace and replace all

### 📝 Files Changed
- CodeTextView.swift: Line number fixes, cursor tracking
- FindView.swift: Special characters, focus support
- ReplaceView.swift: Undo, messages, special chars, line breaks
- ContentView.swift: Drag & drop, Show in Finder
- SettingsView.swift: Thank you message
- FeedbackView.swift: New file for feedback system
- CodeEditorApp.swift: Feedback notification
- PrintCoordinator.swift: Margin fixes
- TEST_PLAN.md: New comprehensive test plan
- CodeEditorTests/*: New unit test files
- CodeEditorUITests/*: New UI test files
- .github/ISSUE_TEMPLATE/*: New bug/feature templates

### 🎯 Next Steps
- Run comprehensive test suite (TEST_PLAN.md)
- Beta testing with real users
- Performance testing with large files (10MB+)
- Accessibility audit with VoiceOver
- App Store submission preparation

### 📊 Impact
- Improved user satisfaction with feedback system
- Better reliability with fixed line numbers
- Enhanced productivity with special character support
- Professional polish with undo and progress messages
- Comprehensive test coverage for future development

---

Co-authored-by: AI Assistant <assistant@example.com>
```

---

## How to Use This Commit Message:

### Option 1: Copy to File
```bash
# Copy the commit message body to a file
cat > commit_message.txt << 'EOF'
[paste the commit body here]
EOF

# Commit with the message from file
git add .
git commit -F commit_message.txt
git push origin main
```

### Option 2: Use Git Commit with Editor
```bash
git add .
git commit
# Your editor will open, paste the message there
# Save and close
git push origin main
```

### Option 3: Shorter Version (if too long)
```bash
git add .
git commit -m "Major update: Feedback system, line number fixes, enhanced find/replace" \
           -m "- Added feedback system with email and clipboard options" \
           -m "- Fixed line number display issues (blanks, paste, scroll)" \
           -m "- Added special character support in find/replace" \
           -m "- Added undo support for replace operations" \
           -m "- Fixed column-restricted replace all" \
           -m "- Added drag and drop file opening" \
           -m "- Added comprehensive test suite (300+ tests)" \
           -m "- Fixed print text truncation" \
           -m "- Added cursor position tracking"
git push origin main
```
