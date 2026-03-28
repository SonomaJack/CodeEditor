//
//  HelpView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/28/26.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("Code Editor Help")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Version 1.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom)
                
                Divider()
                
                // Getting Started
                HelpSection(
                    title: "Getting Started",
                    icon: "play.circle.fill",
                    color: .green
                ) {
                    HelpItem(title: "Create a New File", shortcut: "⌘N") {
                        Text("Create a new file to start coding.")
                    }
                    
                    HelpItem(title: "Open File", shortcut: "⌘O") {
                        Text("Open an existing code file from your Mac.")
                    }
                    
                    HelpItem(title: "Save File", shortcut: "⌘S") {
                        Text("Save your work to a file on your Mac.")
                    }
                }
                
                Divider()
                
                // Find and Replace
                HelpSection(
                    title: "Find and Replace",
                    icon: "magnifyingglass.circle.fill",
                    color: .blue
                ) {
                    HelpItem(title: "Find", shortcut: "⌘F") {
                        Text("Search for text in your document. Features incremental search - results appear as you type!")
                    }
                    
                    HelpItem(title: "Find and Replace", shortcut: "⌥⌘H") {
                        Text("Search and replace text in your document with powerful options.")
                    }
                    
                    HelpItem(title: "Find Next", shortcut: "⌘G") {
                        Text("Jump to the next search result.")
                    }
                    
                    HelpItem(title: "Find Previous", shortcut: "⇧⌘G") {
                        Text("Jump to the previous search result.")
                    }
                    
                    Text("Search Options:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("**Aa** - Match case sensitivity", systemImage: "textformat")
                        Label("**.*** - Use regular expressions", systemImage: "asterisk.circle")
                        Label("**W** - Match whole words only", systemImage: "w.square")
                        Label("**Column Search** - Search within specific column ranges", systemImage: "tablecells")
                    }
                    .font(.system(size: 13))
                    .padding(.leading)
                }
                
                Divider()
                
                // Editor Features
                HelpSection(
                    title: "Editor Features",
                    icon: "text.alignleft",
                    color: .orange
                ) {
                    HelpItem(title: "Syntax Highlighting") {
                        Text("Automatic syntax highlighting for Swift, Python, JavaScript, HTML, CSS, and more.")
                    }
                    
                    HelpItem(title: "Line Numbers") {
                        Text("Toggle line numbers on/off using the toolbar button.")
                    }
                    
                    HelpItem(title: "Code Completion") {
                        Text("Intelligent code suggestions appear as you type. Select from the list to insert.")
                    }
                    
                    HelpItem(title: "Language Selection") {
                        Text("Choose your programming language from the dropdown menu to enable proper syntax highlighting.")
                    }
                }
                
                Divider()
                
                // Printing
                HelpSection(
                    title: "Printing",
                    icon: "printer.fill",
                    color: .purple
                ) {
                    HelpItem(title: "Print", shortcut: "⌘P") {
                        Text("Print your code with syntax highlighting and line numbers.")
                    }
                }
                
                Divider()
                
                // Keyboard Shortcuts
                HelpSection(
                    title: "All Keyboard Shortcuts",
                    icon: "command.circle.fill",
                    color: .indigo
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        ShortcutRow(action: "New File", shortcut: "⌘N")
                        ShortcutRow(action: "Open File", shortcut: "⌘O")
                        ShortcutRow(action: "Save", shortcut: "⌘S")
                        ShortcutRow(action: "Print", shortcut: "⌘P")
                        
                        Divider().padding(.vertical, 4)
                        
                        ShortcutRow(action: "Find", shortcut: "⌘F")
                        ShortcutRow(action: "Find and Replace", shortcut: "⌥⌘H")
                        ShortcutRow(action: "Find Next", shortcut: "⌘G")
                        ShortcutRow(action: "Find Previous", shortcut: "⇧⌘G")
                        
                        Divider().padding(.vertical, 4)
                        
                        ShortcutRow(action: "Help", shortcut: "⌘/")
                    }
                    .font(.system(size: 13, design: .monospaced))
                }
                
                Divider()
                
                // Tips and Tricks
                HelpSection(
                    title: "Tips and Tricks",
                    icon: "lightbulb.fill",
                    color: .yellow
                ) {
                    TipItem(icon: "⚡️", tip: "Incremental search shows results as you type - no need to press Enter!")
                    TipItem(icon: "🎯", tip: "Use column search to find text only in specific parts of each line")
                    TipItem(icon: "🔄", tip: "Press Enter in the Find field to jump to the next match")
                    TipItem(icon: "💡", tip: "The orange dot indicates unsaved changes")
                    TipItem(icon: "📝", tip: "Code completion suggestions appear automatically as you type")
                }
                
                Divider()
                
                // Footer
                HStack {
                    Spacer()
                    Text("Code Editor - A Modern Code Editing Experience")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.top)
            }
            .padding(24)
        }
        .frame(width: 700, height: 600)
        .background(Color(nsColor: .textBackgroundColor))
    }
}

// MARK: - Helper Views

struct HelpSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title2)
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            content
                .padding(.leading, 8)
        }
    }
}

struct HelpItem<Content: View>: View {
    let title: String
    var shortcut: String? = nil
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.headline)
                
                if let shortcut = shortcut {
                    Spacer()
                    Text(shortcut)
                        .font(.system(size: 12, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            
            content
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ShortcutRow: View {
    let action: String
    let shortcut: String
    
    var body: some View {
        HStack {
            Text(action)
            Spacer()
            Text(shortcut)
                .foregroundStyle(.secondary)
        }
    }
}

struct TipItem: View {
    let icon: String
    let tip: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(icon)
                .font(.title3)
            
            Text(tip)
                .font(.body)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    HelpView()
}
