# Code Editor - Comprehensive Test Plan

## Test Execution Date: _____________
## Tester: _____________
## Build Version: 1.0.0

---

## 1. File Operations

### 1.1 New File Creation
- [ ] Create new file via File → New File (⌘N)
- [ ] Create new file via + button in sidebar
- [ ] New file appears in sidebar
- [ ] New file is selected automatically
- [ ] Default language is set correctly
- [ ] Can create multiple new files

### 1.2 Opening Files
- [ ] Open file via File → Open (⌘O)
- [ ] Open multiple files at once
- [ ] Drag and drop single file
- [ ] Drag and drop multiple files
- [ ] File opens with correct syntax highlighting
- [ ] File content loads completely
- [ ] Opening same file twice selects existing tab
- [ ] Open files of all supported languages (21 languages)
- [ ] Open unsupported file types (should open as Plain Text)

### 1.3 Saving Files
- [ ] Save new file (⌘S) - shows Save As dialog
- [ ] Save existing file (⌘S)
- [ ] Save As (⌘⇧S) for new file
- [ ] Save As for existing file
- [ ] Modified indicator appears when editing
- [ ] Modified indicator clears after save
- [ ] Last save date updates correctly

### 1.4 Closing Files
- [ ] Close file via sidebar context menu
- [ ] Close modified file shows warning dialog
- [ ] "Save" option saves and closes
- [ ] "Don't Save" option closes without saving
- [ ] "Cancel" option keeps file open
- [ ] Close all files works correctly
- [ ] App remains stable with no files open

---

## 2. Editing Features

### 2.1 Basic Text Editing
- [ ] Type text
- [ ] Delete text (backspace)
- [ ] Delete text (forward delete)
- [ ] Cut (⌘X)
- [ ] Copy (⌘C)
- [ ] Paste (⌘V)
- [ ] Paste large amounts of text
- [ ] Undo (⌘Z)
- [ ] Redo (⌘⇧Z)
- [ ] Select all (⌘A)
- [ ] Line breaks work correctly
- [ ] Tab characters work

### 2.2 Cursor and Selection
- [ ] Cursor position updates in status bar
- [ ] Line number updates when moving cursor
- [ ] Column number updates when moving cursor
- [ ] Selection length shows in status bar
- [ ] Arrow keys move cursor
- [ ] Home/End keys work
- [ ] Page Up/Down keys work
- [ ] Click to position cursor

### 2.3 Line Numbers
- [ ] Line numbers appear when enabled
- [ ] Line numbers hide when disabled
- [ ] Toggle via toolbar button works
- [ ] Line numbers scroll with text
- [ ] Line numbers show for all lines (no blanks)
- [ ] Line numbers show for empty/blank lines
- [ ] Line numbers show when typing new lines
- [ ] Line numbers show when pasting text
- [ ] Line numbers are correctly aligned
- [ ] Separator line doesn't extend above text
- [ ] Font size changes update line numbers

---

## 3. Find and Replace

### 3.1 Basic Find (⌘F)
- [ ] Find panel opens
- [ ] Cursor auto-focuses in search field
- [ ] Find Next (⌘G) works
- [ ] Find Previous (⌘⇧G) works
- [ ] Find All shows all results
- [ ] Result count displays correctly
- [ ] Click result navigates to location
- [ ] Search highlights in yellow
- [ ] Clear search removes highlights
- [ ] Incremental search as you type

### 3.2 Find Options
- [ ] Case sensitive toggle works
- [ ] Regex toggle works
- [ ] Whole word toggle works
- [ ] Options persist during session

### 3.3 Column Search (Premium)
- [ ] Column search option appears
- [ ] Lock icon shows for non-premium users
- [ ] Column search works with start column only
- [ ] Column search works with start and end columns
- [ ] Empty end column searches to end of line
- [ ] Invalid column numbers handled gracefully
- [ ] Column search with Find All
- [ ] Column search with Find Next/Previous

### 3.4 Find and Replace (⌥⌘H)
- [ ] Replace panel opens
- [ ] Replace single occurrence works
- [ ] Replace All works
- [ ] Replace All shows count message
- [ ] Replace with empty string works
- [ ] Replace count is accurate
- [ ] Column-restricted replace works
- [ ] Replace All with columns works correctly (multiple matches)

### 3.5 Special Characters in Find/Replace
- [ ] Tab (\t) - Find works
- [ ] Tab (\t) - Replace works
- [ ] Newline (\n) - Find works
- [ ] Newline (\n) - Replace works
- [ ] Carriage Return (\r) - Find works
- [ ] Carriage Return (\r) - Replace works
- [ ] CR+LF (\r\n) - Find works
- [ ] CR+LF (\r\n) - Replace works
- [ ] Space - Find works
- [ ] Space - Replace works
- [ ] Non-breaking space - Find works
- [ ] Non-breaking space - Replace works
- [ ] Special char menu displays correctly
- [ ] Special char inserts in Find field
- [ ] Special char inserts in Replace field

### 3.6 Replace Undo
- [ ] Undo button appears after replace
- [ ] Undo button is disabled before replace
- [ ] Undo works after single replace
- [ ] Undo works after Replace All
- [ ] Multiple undos work (up to 10)
- [ ] Undo message displays
- [ ] Document reverts correctly

---

## 4. Syntax Highlighting

### 4.1 Language Detection
- [ ] .swift files → Swift
- [ ] .py files → Python
- [ ] .js files → JavaScript
- [ ] .java files → Java
- [ ] .cpp files → C++
- [ ] .html files → HTML
- [ ] .css files → CSS
- [ ] .md files → Markdown
- [ ] Unknown extensions → Plain Text

### 4.2 Syntax Highlighting Quality
- [ ] Keywords highlighted correctly
- [ ] Strings highlighted correctly
- [ ] Comments highlighted correctly
- [ ] Functions highlighted correctly
- [ ] Highlighting updates as you type
- [ ] Highlighting works after paste
- [ ] No performance issues with large files
- [ ] Highlighting preserved during search

### 4.3 Language Switching
- [ ] Language picker shows all languages
- [ ] Free languages accessible
- [ ] Premium languages show lock icon
- [ ] Changing language updates highlighting
- [ ] Premium gate appears for locked languages

---

## 5. Printing

### 5.1 Basic Printing
- [ ] Print dialog opens (⌘P)
- [ ] Print preview shows correctly
- [ ] Content fits on page
- [ ] No text truncation on right side
- [ ] Left margin is appropriate (36pt)
- [ ] Right margin is appropriate (36pt)

### 5.2 Print Headers/Footers (Premium)
- [ ] Header shows filename or path
- [ ] Footer shows print date
- [ ] Footer shows page number
- [ ] Footer shows "Page X of Y" format
- [ ] Footer shows last saved date
- [ ] Headers/footers align correctly

### 5.3 Print with Line Numbers
- [ ] Line numbers appear in print
- [ ] Line numbers are styled gray
- [ ] Line numbers aligned correctly
- [ ] Separator character shows (│)

---

## 6. Settings

### 6.1 General Settings
- [ ] Settings window opens (⌘,)
- [ ] Font size slider works (8-24pt)
- [ ] Font size displays current value
- [ ] Font size changes apply to new files
- [ ] Status bar toggle works
- [ ] Auto-save toggle works
- [ ] Settings persist after restart

### 6.2 Premium Settings
- [ ] Shows "Premium Unlocked" if purchased
- [ ] Shows purchase button if not premium
- [ ] Feature list displays all 12 features
- [ ] Purchase button shows price
- [ ] Restore Purchases button works
- [ ] Thank you message appears after purchase

### 6.3 About Settings
- [ ] App name displays
- [ ] Version number displays
- [ ] Build number displays
- [ ] Copyright displays
- [ ] Send Feedback button works

---

## 7. Feedback System

### 7.1 Feedback Access
- [ ] Help → Send Feedback opens form
- [ ] Settings → About → Send Feedback opens form
- [ ] Form displays correctly

### 7.2 Feedback Form
- [ ] Feedback type picker works (Bug/Feature/General)
- [ ] Email field accepts input
- [ ] Feedback text area accepts input
- [ ] System info toggle works
- [ ] System info displays correctly
- [ ] Copy to Clipboard works
- [ ] Copy success message shows
- [ ] Open Email button works
- [ ] Email pre-fills correctly
- [ ] Cancel button works

---

## 8. Drag and Drop

### 8.1 Drop Zones
- [ ] Drop on sidebar works
- [ ] Drop on main editor area works
- [ ] Drop on welcome screen works
- [ ] Visual feedback shows (dashed border)
- [ ] Border appears during drag
- [ ] Border disappears after drop

### 8.2 Drop Behavior
- [ ] Single file drop works
- [ ] Multiple file drop works
- [ ] All files open correctly
- [ ] Files appear in sidebar
- [ ] First file is selected
- [ ] Duplicate files don't open twice

---

## 9. Context Menus

### 9.1 Sidebar File Context Menu
- [ ] Right-click file shows menu
- [ ] Save option works
- [ ] Save As option works
- [ ] Show in Finder works
- [ ] Show in Finder opens Finder
- [ ] Show in Finder selects file
- [ ] Close option works
- [ ] Disabled states correct (Save when not modified)

---

## 10. Premium Features

### 10.1 Premium Gating
- [ ] Premium languages show lock icon
- [ ] Clicking locked language shows gate
- [ ] Find and Replace shows gate for non-premium
- [ ] Column search shows gate for non-premium
- [ ] Code completion shows gate for non-premium
- [ ] Printing shows gate for non-premium
- [ ] Gate displays feature description
- [ ] Gate shows price
- [ ] Purchase from gate works

### 10.2 Premium Purchase
- [ ] Purchase flow completes
- [ ] App Store dialog appears
- [ ] Payment processes
- [ ] Premium features unlock immediately
- [ ] Settings shows "Premium Unlocked"
- [ ] Thank you message appears
- [ ] Restore Purchases works

---

## 11. Status Bar

### 11.1 Status Bar Display
- [ ] Status bar shows when enabled
- [ ] Status bar hides when disabled
- [ ] Language indicator shows
- [ ] Line and column show
- [ ] Line updates on cursor move
- [ ] Column updates on cursor move
- [ ] Selection count shows
- [ ] Character count shows
- [ ] Line count shows
- [ ] Encoding shows (UTF-8)
- [ ] Modified indicator shows
- [ ] All values update correctly

---

## 12. User Interface

### 12.1 Sidebar
- [ ] Sidebar shows file list
- [ ] File icons display
- [ ] File names display
- [ ] Language labels display
- [ ] Modified indicators show
- [ ] Selection highlights
- [ ] Clicking file selects it
- [ ] Empty state shows
- [ ] Scroll works with many files
- [ ] Sidebar doesn't overlay status bar

### 12.2 Tabs
- [ ] Tabs appear with multiple files
- [ ] Tab shows filename
- [ ] Tab shows modified indicator
- [ ] Clicking tab selects file
- [ ] Close button works
- [ ] Tabs scroll horizontally
- [ ] Active tab highlighted

### 12.3 Welcome Screen
- [ ] Welcome screen shows when no files
- [ ] App icon displays
- [ ] Create New File button works
- [ ] Open File button works
- [ ] Drag and drop hint shows

---

## 13. Performance

### 13.1 File Size Tests
- [ ] Open 1KB file - fast
- [ ] Open 10KB file - fast
- [ ] Open 100KB file - acceptable
- [ ] Open 1MB file - check performance
- [ ] Open 10MB file - check performance
- [ ] Syntax highlighting performance
- [ ] Scrolling performance
- [ ] Search performance in large files

### 13.2 Multiple Files
- [ ] 5 files open - smooth
- [ ] 10 files open - smooth
- [ ] 20 files open - acceptable
- [ ] Switching between files - fast
- [ ] Memory usage reasonable

---

## 14. Edge Cases and Error Handling

### 14.1 File Operations
- [ ] Open read-only file
- [ ] Open file without permissions
- [ ] Save to read-only location
- [ ] File deleted while open
- [ ] File modified externally
- [ ] Disk full during save
- [ ] Network drive files

### 14.2 Text Content
- [ ] Empty file
- [ ] File with only whitespace
- [ ] File with very long lines
- [ ] File with thousands of lines
- [ ] File with special Unicode characters
- [ ] File with emoji
- [ ] File with mixed line endings

### 14.3 Search Edge Cases
- [ ] Search for empty string
- [ ] Search with no matches
- [ ] Search with thousands of matches
- [ ] Replace with longer text
- [ ] Replace with shorter text
- [ ] Replace with same text
- [ ] Regex with invalid pattern

---

## 15. Keyboard Shortcuts

### 15.1 File Operations
- [ ] ⌘N - New File
- [ ] ⌘O - Open
- [ ] ⌘S - Save
- [ ] ⌘⇧S - Save As
- [ ] ⌘P - Print

### 15.2 Edit Operations
- [ ] ⌘Z - Undo
- [ ] ⌘⇧Z - Redo
- [ ] ⌘X - Cut
- [ ] ⌘C - Copy
- [ ] ⌘V - Paste
- [ ] ⌘A - Select All

### 15.3 Find Operations
- [ ] ⌘F - Find
- [ ] ⌘G - Find Next
- [ ] ⌘⇧G - Find Previous
- [ ] ⌥⌘H - Find and Replace
- [ ] ⌘L - Go to Line

### 15.4 View Operations
- [ ] ⌘+ - Zoom In
- [ ] ⌘- - Zoom Out
- [ ] ⌘0 - Reset Zoom

### 15.5 Other
- [ ] ⌘, - Settings
- [ ] ⌘/ - Help

---

## 16. Regression Tests

### 16.1 Previously Fixed Issues
- [ ] Line numbers don't show all "1"s when pasting
- [ ] Line numbers show for blank lines
- [ ] Line numbers scroll with text
- [ ] Separator line doesn't extend above text
- [ ] Sidebar doesn't overlay status bar
- [ ] Find works with special characters
- [ ] Replace All works with column search
- [ ] Print doesn't truncate text on right

---

## 17. Accessibility

### 17.1 VoiceOver
- [ ] VoiceOver reads sidebar items
- [ ] VoiceOver reads text content
- [ ] VoiceOver reads buttons
- [ ] VoiceOver navigates menus

### 17.2 Keyboard Navigation
- [ ] Tab navigates between controls
- [ ] All features accessible via keyboard
- [ ] Shortcuts don't conflict

---

## Test Results Summary

**Total Tests:** _____
**Passed:** _____
**Failed:** _____
**Blocked:** _____
**Not Tested:** _____

### Critical Issues Found:
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

### Medium Issues Found:
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

### Minor Issues Found:
1. ___________________________________________
2. ___________________________________________
3. ___________________________________________

### Notes:
_________________________________________________
_________________________________________________
_________________________________________________

---

## Sign-off

Tester Signature: _______________ Date: ___________
