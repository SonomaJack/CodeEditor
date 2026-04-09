# Changelog

All notable changes to Clarity Code Edit will be documented in this file.

## [1.0.0] - 2026-04-08

### Added
- **HelpView.swift**: Comprehensive in-app help documentation
  - Getting Started guide
  - File Management documentation
  - Editing features guide
  - Find & Replace instructions
  - Programming Languages reference
  - Complete keyboard shortcuts list
  - Premium features overview
  - Searchable sidebar navigation
  - Markdown-formatted content with visual formatting
  
- **USER_GUIDE.md**: Complete user guide documentation file
  - Quick reference for all features
  - Keyboard shortcuts table
  - Tips and tricks
  - Troubleshooting section

### Fixed
- **URL Scheme Handler**: Added proper handling for `codeeditor://` URL scheme
  - Implemented `.onOpenURL()` handler in CodeEditorApp
  - Handles help, settings, and feedback URLs
  - Prevents system errors when clicking internal links
  
- **Infinite Loop Bug**: Fixed circular notification loop in help system
  - Removed duplicate `.showHelpWindow` notification handler from CodeEditorView
  - Removed unnecessary `showHelp()` function that was re-posting notifications
  - Help window now properly handled only in ContentView
  - No more hanging or cascading errors when accessing help

### Changed
- Updated help menu to use new comprehensive HelpView
- Replaced placeholder help content with full documentation
- Help window now displays rich, categorized content instead of basic shortcuts

### Technical Details
- Help system now uses single notification path: Menu → ContentView → HelpView sheet
- URL scheme registration prepared for future external link support
- All help content uses SwiftUI's AttributedString for markdown rendering
- Modular help sections for easy maintenance and updates

---

## Bug Fixes Summary (2026-04-08)

### Issue 1: URL Scheme Errors
**Problem**: Clicking help menu created cascade of errors trying to open `codeeditor://help`  
**Root Cause**: App not registered to handle custom URL scheme  
**Solution**: Added `.onOpenURL()` handler with proper URL routing  

### Issue 2: Application Hang
**Problem**: App hung when accessing help (Thread 1 infinite loop)  
**Root Cause**: Circular notification loop - help notification triggered function that posted same notification  
**Solution**: Removed duplicate notification handler, centralized help handling in ContentView  

### Code Changes Made
1. `CodeEditorApp.swift`:
   - Added `.onOpenURL()` modifier to WindowGroup
   - Added `handleURL()` function to route custom URLs to appropriate notifications
   
2. `CodeEditorView.swift`:
   - Removed `.onReceive(.showHelpWindow)` handler (duplicate)
   - Removed `showHelp()` function (unnecessary)
   
3. `ContentView.swift`:
   - Replaced placeholder help content with `HelpView()`
   - Kept proper notification handler for showing help sheet
   
4. `HelpView.swift` (NEW):
   - Created comprehensive help documentation view
   - 7 categorized help sections
   - Fully searchable and navigable
   
5. `USER_GUIDE.md` (NEW):
   - Complete text reference guide
   - All features documented
   - Keyboard shortcuts, tips, and troubleshooting

---

## Version History

### [1.0.0] - 2026-04-08
- Initial release
- Full help documentation system
- Bug fixes for URL handling and notification loops
- 21+ supported programming languages
- Premium features system
- Find and replace functionality
- Multi-file editing
- Syntax highlighting
- Code completion
- Print support

---

## Next Steps / TODO

### Potential Future Enhancements
- [ ] Export help documentation as PDF
- [ ] Add search functionality within help view
- [ ] Create video tutorials
- [ ] Add tooltips for first-time users
- [ ] Interactive help overlays
- [ ] Help context based on current feature
- [ ] Localization for multiple languages

### Known Issues
- None currently reported

---

**Note**: This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) principles.
