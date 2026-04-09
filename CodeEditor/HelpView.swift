//
//  HelpView.swift
//  CodeEditor
//
//  Created by J Bretcher on 4/8/26.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: HelpSection = .gettingStarted
    
    enum HelpSection: String, CaseIterable, Identifiable {
        case gettingStarted = "Getting Started"
        case fileManagement = "File Management"
        case editing = "Editing"
        case findAndReplace = "Find & Replace"
        case languages = "Languages"
        case shortcuts = "Keyboard Shortcuts"
        case premium = "Premium Features"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .gettingStarted: return "star.fill"
            case .fileManagement: return "folder.fill"
            case .editing: return "pencil.line"
            case .findAndReplace: return "magnifyingglass"
            case .languages: return "chevron.left.forwardslash.chevron.right"
            case .shortcuts: return "command"
            case .premium: return "crown.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Sidebar navigation
            VStack(alignment: .leading, spacing: 8) {
                Text("Help Topics")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                
                Divider()
                    .padding(.vertical, 8)
                
                ForEach(HelpSection.allCases) { section in
                    Button(action: { selectedSection = section }) {
                        HStack(spacing: 8) {
                            Image(systemName: section.icon)
                                .frame(width: 20)
                                .foregroundStyle(selectedSection == section ? .white : .blue)
                            Text(section.rawValue)
                                .foregroundStyle(selectedSection == section ? .white : .primary)
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedSection == section ? Color.accentColor : Color.clear)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 8)
                }
                
                Spacer()
                
                Divider()
                
                // Version info
                VStack(alignment: .leading, spacing: 4) {
                    Text("Clarity Code Edit")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Version 1.0.0")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .frame(width: 200)
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Content area
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    switch selectedSection {
                    case .gettingStarted:
                        gettingStartedContent
                    case .fileManagement:
                        fileManagementContent
                    case .editing:
                        editingContent
                    case .findAndReplace:
                        findAndReplaceContent
                    case .languages:
                        languagesContent
                    case .shortcuts:
                        keyboardShortcutsContent
                    case .premium:
                        premiumFeaturesContent
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 800, height: 600)
    }
    
    // MARK: - Getting Started
    
    private var gettingStartedContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSectionHeader(title: "Getting Started", icon: "star.fill")
            
            Text("Welcome to Clarity Code Edit, a powerful code editor for macOS!")
                .font(.title3)
            
            HelpTopic(
                title: "Creating Your First File",
                icon: "plus.circle.fill",
                content: """
                1. Click the **+** button in the sidebar, or press ⌘N
                2. Choose a filename (optional)
                3. Select your programming language
                4. Click **Create** to start coding
                
                The editor will automatically detect the language as you type if you enable auto-detection.
                """
            )
            
            HelpTopic(
                title: "Opening Existing Files",
                icon: "folder.fill",
                content: """
                1. Click the **folder** icon in the sidebar, or press ⌘O
                2. Navigate to your code file
                3. Select and open it
                
                Supported file types include Swift, Python, JavaScript, TypeScript, Java, Apex, C++, C, C#, Go, Rust, Ruby, PHP, SQL, HTML, CSS, Markdown, JSON, XML, YAML, CSV, and more!
                """
            )
            
            HelpTopic(
                title: "The Interface",
                icon: "rectangle.3.group.fill",
                content: """
                • **Sidebar**: Shows all open files and provides quick access to file operations
                • **Editor Toolbar**: Contains language selector, find/replace, print, and view options
                • **Code Editor**: The main editing area with syntax highlighting and line numbers
                • **Status Bar**: Shows cursor position, file statistics, and encoding info
                """
            )
            
            HelpTip(text: "Pro Tip: You can open multiple files and switch between them using the sidebar tabs.")
        }
    }
    
    // MARK: - File Management
    
    private var fileManagementContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSectionHeader(title: "File Management", icon: "folder.fill")
            
            HelpTopic(
                title: "Creating New Files",
                icon: "doc.badge.plus",
                content: """
                **Keyboard Shortcut**: ⌘N
                
                1. Press ⌘N or click the + button in the sidebar
                2. Enter a filename (optional - you can leave it as "Untitled")
                3. Toggle "Auto-detect language from content" to enable smart language detection
                4. If auto-detect is off, manually select the language from the dropdown
                5. Click Create
                
                The editor will create a new document ready for editing.
                """
            )
            
            HelpTopic(
                title: "Opening Files",
                icon: "folder.badge.plus",
                content: """
                **Keyboard Shortcut**: ⌘O
                
                • Click the folder icon or press ⌘O
                • Navigate to your file
                • The editor supports all major code file formats
                • Files are automatically detected by extension
                
                **Recent Files**: Access recently opened files from the **File → Open Recent** menu.
                """
            )
            
            HelpTopic(
                title: "Saving Files",
                icon: "square.and.arrow.down",
                content: """
                **Keyboard Shortcut**: ⌘S (Save), ⇧⌘S (Save As)
                
                **First-time save**:
                1. Press ⌘S or ⇧⌘S
                2. Choose a location and filename
                3. The file extension will match your selected language
                
                **Subsequent saves**:
                • Press ⌘S to quickly save changes
                • An orange dot indicates unsaved changes
                • Auto-save can be enabled in Settings
                
                **Right-click menu**: Right-click any file in the sidebar for save options.
                """
            )
            
            HelpTopic(
                title: "Managing Multiple Files",
                icon: "doc.on.doc",
                content: """
                • Open multiple files - they appear as tabs in the sidebar
                • Click any tab to switch to that file
                • The X button closes files (you'll be prompted if there are unsaved changes)
                • The sidebar shows which file is currently active
                • Modified files show an orange indicator dot
                
                **Premium Feature**: Split view allows editing two files side-by-side.
                """
            )
            
            HelpTopic(
                title: "File Context Menu",
                icon: "ellipsis.circle",
                content: """
                Right-click any file in the sidebar to access:
                • **Save**: Save the file
                • **Save As**: Save a copy with a new name
                • **Show in Finder**: Reveal the file in Finder
                • **Close**: Close the file
                
                These actions are also available via keyboard shortcuts and menu bar.
                """
            )
        }
    }
    
    // MARK: - Editing
    
    private var editingContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSectionHeader(title: "Editing", icon: "pencil.line")
            
            HelpTopic(
                title: "Text Editing",
                icon: "text.cursor",
                content: """
                The editor provides native macOS text editing with these features:
                
                • **Syntax Highlighting**: Automatic color-coding based on language
                • **Line Numbers**: Toggle on/off with the line numbers button
                • **Monospaced Font**: Optimized for code with consistent spacing
                • **Smart Quotes Disabled**: Types straight quotes for code
                • **Undo/Redo**: Standard ⌘Z and ⇧⌘Z support
                • **Full Scrolling**: Both horizontal and vertical scrolling
                """
            )
            
            HelpTopic(
                title: "Font Size & Zoom",
                icon: "textformat.size",
                content: """
                **Keyboard Shortcuts**:
                • ⌘+ : Zoom In (increase font size)
                • ⌘- : Zoom Out (decrease font size)
                • ⌘0 : Reset Zoom (back to default)
                
                The current font size is displayed in the toolbar (e.g., "13pt").
                Font sizes range from 8pt to 24pt.
                
                You can also set a default font size in Settings (⌘,).
                """
            )
            
            HelpTopic(
                title: "Line Numbers",
                icon: "list.number",
                content: """
                Click the line numbers button in the toolbar to show/hide line numbers.
                
                • Line numbers appear in the left gutter
                • Current cursor line is highlighted
                • Helps with navigation and debugging
                • Preference is saved per document
                """
            )
            
            HelpTopic(
                title: "Go to Line",
                icon: "arrow.right.to.line",
                content: """
                **Keyboard Shortcut**: ⌘L
                
                1. Press ⌘L to open the Go to Line dialog
                2. Enter the line number
                3. Press Enter or click Go
                
                The editor will scroll to and highlight the specified line.
                Great for jumping to specific locations in large files!
                """
            )
            
            HelpTopic(
                title: "Code Completion (Premium)",
                icon: "lightbulb.fill",
                content: """
                Premium users get intelligent code completion:
                
                • Automatic suggestions as you type
                • Language-specific keywords and patterns
                • Common code structures and snippets
                • Up to 10 suggestions shown at once
                • Click a suggestion to insert it
                
                Supports completion for all premium languages including Swift, Python, JavaScript, Java, Apex, and more.
                """
            )
            
            HelpTopic(
                title: "Code Snippets (Premium)",
                icon: "curlybraces",
                content: """
                **Keyboard Shortcut**: ⌥⌘K
                
                Access pre-built code templates and snippets:
                • Common code patterns
                • Language-specific templates
                • Quick insertion of boilerplate code
                • Customizable snippets
                
                Press ⌥⌘K to open the snippets panel.
                """
            )
        }
    }
    
    // MARK: - Find and Replace
    
    private var findAndReplaceContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSectionHeader(title: "Find & Replace", icon: "magnifyingglass")
            
            HelpTopic(
                title: "Find",
                icon: "magnifyingglass",
                content: """
                **Keyboard Shortcut**: ⌘F
                
                **Basic Find**:
                1. Press ⌘F to open the Find panel
                2. Type your search term
                3. Use the arrow buttons or keyboard shortcuts to navigate results:
                   • ⌘G : Find Next
                   • ⇧⌘G : Find Previous
                
                **Find Options**:
                • **Case Sensitive**: Match exact capitalization
                • **Whole Words**: Match complete words only
                • **Regular Expression**: Use regex patterns for advanced searching
                
                The editor highlights all matches and shows the current match count.
                """
            )
            
            HelpTopic(
                title: "Find and Replace (Premium)",
                icon: "arrow.triangle.2.circlepath",
                content: """
                **Keyboard Shortcut**: ⌥⌘H
                
                Premium users can find and replace text:
                
                1. Press ⌥⌘H to open the Replace panel
                2. Enter search term in "Find" field
                3. Enter replacement text in "Replace with" field
                4. Choose your options:
                   • Replace individual matches with "Replace"
                   • Replace all matches at once with "Replace All"
                
                **Advanced Options**:
                • Case sensitivity
                • Whole word matching
                • Regular expressions
                • Column-restricted search (search within specific columns)
                """
            )
            
            HelpTopic(
                title: "Multi-File Search (Premium)",
                icon: "doc.text.magnifyingglass",
                content: """
                **Keyboard Shortcut**: ⇧⌘F
                
                Search across all open files:
                
                1. Press ⇧⌘F to open the multi-file search panel
                2. Enter your search term
                3. View results from all open documents
                4. Click any result to jump to that location
                
                Perfect for finding function definitions, variable usage, or patterns across your entire project.
                """
            )
            
            HelpTopic(
                title: "Column-Restricted Search (Premium)",
                icon: "tablecells",
                content: """
                Available in the Find and Replace panel:
                
                • Limit searches to specific column ranges
                • Useful for structured data or formatted code
                • Specify start and end columns
                • Great for working with CSV files or aligned text
                
                Enable the "Column Restricted" option and enter your column range.
                """
            )
            
            HelpTip(text: "Regular expressions allow powerful pattern matching. For example, \\d+ matches one or more digits.")
        }
    }
    
    // MARK: - Languages
    
    private var languagesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSectionHeader(title: "Programming Languages", icon: "chevron.left.forwardslash.chevron.right")
            
            HelpTopic(
                title: "Supported Languages",
                icon: "list.bullet",
                content: """
                **Free Languages**:
                • Plain Text
                • Markdown
                • JSON
                • XML
                • CSV
                
                **Premium Languages** (21 total):
                • Swift, Python, JavaScript, TypeScript
                • Java, Apex (Salesforce)
                • C++, C, C#
                • Go, Rust, Ruby, PHP
                • SQL, HTML, CSS
                • YAML
                
                Each language has custom syntax highlighting optimized for readability.
                """
            )
            
            HelpTopic(
                title: "Language Selection",
                icon: "text.badge.checkmark",
                content: """
                **Manual Selection**:
                • Use the language dropdown in the toolbar
                • Choose from available languages
                • Premium languages show a lock icon if not unlocked
                
                **Automatic Detection**:
                • Enable the magic wand icon (🪄) for auto-detection
                • The editor analyzes file extensions and content
                • Language updates automatically as you type
                • Disable auto-detection to manually control the language
                
                The status bar shows the current language and whether auto-detection is active.
                """
            )
            
            HelpTopic(
                title: "Syntax Highlighting",
                icon: "paintbrush.fill",
                content: """
                All languages include color-coded syntax highlighting:
                
                • **Keywords**: Language-specific reserved words
                • **Strings**: Text in quotes
                • **Comments**: Single-line and multi-line comments
                • **Numbers**: Numeric literals
                • **Functions**: Function names and calls
                • **Types**: Data types and classes
                • **Operators**: Mathematical and logical operators
                
                Colors are optimized for both light and dark mode.
                """
            )
            
            HelpTopic(
                title: "Salesforce (Apex) Development",
                icon: "cloud.fill",
                content: """
                Full support for Salesforce development:
                
                **File Types**:
                • .cls (Apex Classes)
                • .trigger (Apex Triggers)
                
                **Syntax Highlighting**:
                • Access modifiers (public, private, global, with sharing)
                • Data types (Integer, String, Boolean, List, Set, Map)
                • DML operations (insert, update, delete, upsert)
                • SOQL keywords (SELECT, FROM, WHERE, ORDER BY)
                • Annotations (@isTest, @future, @AuraEnabled)
                • Trigger events (before insert, after update, etc.)
                
                **Code Completion** (Premium):
                • 60+ Apex-specific suggestions
                • Common patterns and boilerplate
                • Salesforce-specific constructs
                """
            )
            
            HelpTopic(
                title: "File Type Detection",
                icon: "doc.text.magnifyingglass",
                content: """
                The editor automatically detects languages based on:
                
                **File Extensions**:
                • .swift → Swift
                • .py → Python
                • .js, .jsx → JavaScript
                • .ts, .tsx → TypeScript
                • .java → Java
                • .cls, .trigger → Apex
                • And many more...
                
                **Content Analysis**:
                When files have no extension or are ambiguous, the editor analyzes:
                • Import statements
                • Syntax patterns
                • Document structure
                • Special markers (DOCTYPE, XML declarations, etc.)
                """
            )
        }
    }
    
    // MARK: - Keyboard Shortcuts
    
    private var keyboardShortcutsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSectionHeader(title: "Keyboard Shortcuts", icon: "command")
            
            VStack(alignment: .leading, spacing: 16) {
                ShortcutGroup(title: "File Management", shortcuts: [
                    ("⌘N", "New File"),
                    ("⌘O", "Open File"),
                    ("⌘S", "Save"),
                    ("⇧⌘S", "Save As"),
                    ("⌘P", "Print"),
                    ("⌘W", "Close File")
                ])
                
                ShortcutGroup(title: "Editing", shortcuts: [
                    ("⌘Z", "Undo"),
                    ("⇧⌘Z", "Redo"),
                    ("⌘X", "Cut"),
                    ("⌘C", "Copy"),
                    ("⌘V", "Paste"),
                    ("⌘A", "Select All"),
                    ("⌘L", "Go to Line")
                ])
                
                ShortcutGroup(title: "Find & Replace", shortcuts: [
                    ("⌘F", "Find"),
                    ("⌘G", "Find Next"),
                    ("⇧⌘G", "Find Previous"),
                    ("⌥⌘H", "Find and Replace"),
                    ("⇧⌘F", "Find in All Files")
                ])
                
                ShortcutGroup(title: "View", shortcuts: [
                    ("⌘+", "Zoom In"),
                    ("⌘-", "Zoom Out"),
                    ("⌘0", "Reset Zoom"),
                    ("⌥⌘D", "Split View")
                ])
                
                ShortcutGroup(title: "Code", shortcuts: [
                    ("⌥⌘K", "Insert Snippet")
                ])
                
                ShortcutGroup(title: "Application", shortcuts: [
                    ("⌘,", "Settings"),
                    ("⌘/", "Help"),
                    ("⌘Q", "Quit")
                ])
            }
            
            HelpTip(text: "Symbols: ⌘ = Command, ⌥ = Option, ⇧ = Shift, ⌃ = Control")
        }
    }
    
    // MARK: - Premium Features
    
    private var premiumFeaturesContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HelpSectionHeader(title: "Premium Features", icon: "crown.fill")
            
            Text("Unlock the full power of Clarity Code Edit with Premium!")
                .font(.title3)
            
            FeatureCard(
                icon: "paintpalette",
                title: "All 21 Programming Languages",
                description: "Access Swift, Python, JavaScript, TypeScript, Java, Apex (Salesforce), C++, C, C#, Go, Rust, Ruby, PHP, SQL, HTML, CSS, YAML, and more with full syntax highlighting."
            )
            
            FeatureCard(
                icon: "arrow.triangle.2.circlepath",
                title: "Find and Replace",
                description: "Powerful search and replace functionality with support for case sensitivity, whole words, and regular expressions. Replace one match or all at once."
            )
            
            FeatureCard(
                icon: "tablecells",
                title: "Column-Restricted Search",
                description: "Limit searches to specific column ranges - perfect for structured data, CSV files, or precisely formatted code."
            )
            
            FeatureCard(
                icon: "lightbulb.fill",
                title: "Code Completion",
                description: "Intelligent, language-aware code suggestions as you type. Get keyword suggestions, common patterns, and code snippets tailored to your language."
            )
            
            FeatureCard(
                icon: "printer",
                title: "Print with Headers & Footers",
                description: "Print your code with preserved syntax highlighting, custom headers and footers, page numbers, and professional formatting."
            )
            
            FeatureCard(
                icon: "paintbrush.pointed",
                title: "Premium Color Themes",
                description: "Choose from multiple professionally designed color schemes optimized for different programming languages and lighting conditions."
            )
            
            FeatureCard(
                icon: "rectangle.split.3x1",
                title: "Split View Editing",
                description: "Edit two files side-by-side. Perfect for comparing code, copying between files, or working with related files simultaneously."
            )
            
            FeatureCard(
                icon: "curlybraces",
                title: "Code Snippets & Templates",
                description: "Quick access to common code patterns, boilerplate code, and language-specific templates. Insert entire code blocks with a single click."
            )
            
            FeatureCard(
                icon: "doc.text.magnifyingglass",
                title: "Multi-File Search",
                description: "Search across all open files at once. Find function definitions, variable usage, or any pattern across your entire project."
            )
            
            FeatureCard(
                icon: "arrow.triangle.branch",
                title: "Git Integration",
                description: "Built-in Git support for version control. View diffs, commit changes, and manage your repository without leaving the editor."
            )
            
            FeatureCard(
                icon: "doc.on.doc.fill",
                title: "Multiple File Tabs",
                description: "Work with unlimited open files. Easily switch between files with the sidebar, and manage all your code in one window."
            )
            
            FeatureCard(
                icon: "gearshape.2.fill",
                title: "Advanced Customization",
                description: "Fine-tune every aspect of your editing experience with advanced settings for fonts, themes, behaviors, and more."
            )
            
            Divider()
            
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("To upgrade to Premium, go to **Settings → Premium** or click on any locked feature.")
                    .font(.callout)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Helper Views

struct HelpSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(.blue)
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding(.bottom, 8)
    }
}

struct HelpTopic: View {
    let title: String
    let icon: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .frame(width: 24)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            Text(.init(content)) // Use AttributedString for markdown
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 32)
        }
        .padding(.vertical, 8)
    }
}

struct HelpTip: View {
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
            Text(text)
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ShortcutGroup: View {
    let title: String
    let shortcuts: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            
            VStack(spacing: 6) {
                ForEach(shortcuts, id: \.1) { shortcut in
                    HStack {
                        Text(shortcut.0)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor)
                            .cornerRadius(6)
                            .frame(width: 80, alignment: .center)
                        
                        Text(shortcut.1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer()
                    }
                }
            }
            .padding(.leading, 16)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(10)
    }
}

#Preview {
    HelpView()
}
