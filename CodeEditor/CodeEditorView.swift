//
//  CodeEditorView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI

struct CodeEditorView: View {
    @Bindable var document: CodeDocument
    @Binding var triggerPrint: Bool
    @State private var suggestions: [CompletionSuggestion] = []
    @State private var showSuggestions = false
    @State private var cursorPosition = 0
    @State private var showPrintPanel = false
    @State private var showFind = false
    @State private var showReplace = false
    @State private var highlightRange: HighlightRange? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor toolbar
            HStack {
                Text(document.filename)
                    .font(.headline)
                
                Spacer()
                
                // Line numbers toggle
                Button(action: { document.showLineNumbers.toggle() }) {
                    Label("Line Numbers", systemImage: document.showLineNumbers ? "list.number" : "list.bullet")
                }
                .help(document.showLineNumbers ? "Hide line numbers" : "Show line numbers")
                
                Picker("Language", selection: $document.language) {
                    ForEach(CodeLanguage.allCases) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180)
                
                Button(action: { 
                    showFind.toggle()
                    if showFind {
                        showReplace = false
                    }
                }) {
                    Label("Find", systemImage: "magnifyingglass")
                }
                .help("Find")
                .keyboardShortcut("f", modifiers: .command)
                
                Button(action: { 
                    showReplace.toggle()
                    if showReplace {
                        showFind = false
                    }
                }) {
                    Label("Replace", systemImage: "arrow.triangle.2.circlepath")
                }
                .help("Find and replace")
                .keyboardShortcut("h", modifiers: [.command, .option])
                
                Button(action: printDocument) {
                    Label("Print", systemImage: "printer")
                }
                .help("Print document")
                
                if let fileURL = document.fileURL {
                    Button(action: saveDocument) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    .disabled(!document.isModified)
                    .help("Save file to \(fileURL.path)")
                }
                
                if document.isModified {
                    Circle()
                        .fill(.orange)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Find Panel
            if showFind {
                FindView(
                    isPresented: $showFind,
                    documentContent: $document.content,
                    onResultSelected: { result in
                        highlightRange = HighlightRange(
                            lineNumber: result.lineNumber,
                            columnStart: result.columnStart,
                            columnEnd: result.columnEnd
                        )
                    }
                )
                
                Divider()
            }
            
            // Replace Panel
            if showReplace {
                ReplaceView(
                    isPresented: $showReplace,
                    documentContent: $document.content,
                    isModified: $document.isModified,
                    onResultSelected: { result in
                        highlightRange = HighlightRange(
                            lineNumber: result.lineNumber,
                            columnStart: result.columnStart,
                            columnEnd: result.columnEnd
                        )
                    }
                )
                
                Divider()
            }
            
            // Code editor with line numbers
            HStack(spacing: 0) {
                if document.showLineNumbers {
                    LineNumberView(text: document.content)
                        .frame(width: 40)
                }
                
                CodeTextView(
                    text: $document.content,
                    isModified: $document.isModified,
                    language: document.language,
                    showLineNumbers: document.showLineNumbers,
                    onTextChange: updateSuggestions
                )
            }
            
            // Completion suggestions
            if showSuggestions && !suggestions.isEmpty {
                Divider()
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(suggestions.prefix(10)) { suggestion in
                            SuggestionRow(suggestion: suggestion) {
                                insertSuggestion(suggestion)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .onChange(of: triggerPrint) { _, _ in
            printDocument()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showFind)) { _ in
            showFind = true
            showReplace = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .showReplace)) { _ in
            showReplace = true
            showFind = false
        }
        .onReceive(NotificationCenter.default.publisher(for: .showHelpWindow)) { _ in
            showHelp()
        }
    }
    
    private func saveDocument() {
        do {
            try document.save()
        } catch {
            print("Error saving document: \(error.localizedDescription)")
        }
    }
    
    private func printDocument() {
        PrintCoordinator.printDocument(document, from: NSApp.keyWindow)
    }
    
    private func showHelp() {
        if let url = URL(string: "codeeditor://help") {
            NSWorkspace.shared.open(url)
        }
        // Alternative: Show help window
        NotificationCenter.default.post(name: .showHelpWindow, object: nil)
    }
    
    private func updateSuggestions() {
        cursorPosition = document.content.count
        let newSuggestions = CodeCompletionEngine.getSuggestions(
            for: document.content,
            language: document.language,
            cursorPosition: cursorPosition
        )
        
        suggestions = newSuggestions
        showSuggestions = !newSuggestions.isEmpty
    }
    
    private func insertSuggestion(_ suggestion: CompletionSuggestion) {
        // Find the current word to replace
        let beforeCursor = String(document.content.prefix(cursorPosition))
        let components = beforeCursor.components(separatedBy: CharacterSet.alphanumerics.inverted)
        
        if let lastWord = components.last, !lastWord.isEmpty {
            let range = document.content.range(
                of: lastWord,
                options: .backwards,
                range: document.content.startIndex..<document.content.index(document.content.startIndex, offsetBy: cursorPosition)
            )
            
            if let range = range {
                document.content.replaceSubrange(range, with: suggestion.text)
                document.isModified = true
            }
        }
        
        showSuggestions = false
        suggestions = []
    }
}

struct SuggestionRow: View {
    let suggestion: CompletionSuggestion
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                Image(systemName: suggestion.icon)
                    .foregroundStyle(.blue)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(suggestion.text)
                        .font(.system(.body, design: .monospaced))
                    Text(suggestion.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .background(
            Color.blue.opacity(0.0)
        )
        .onHover { isHovered in
            // Could add hover effect here
        }
    }
}

#Preview {
    @Previewable @State var triggerPrint = false
    
    CodeEditorView(
        document: CodeDocument(
            filename: "Example.swift",
            content: """
            import SwiftUI
            
            struct ContentView: View {
                var body: some View {
                    Text("Hello, World!")
                }
            }
            """,
            language: .swift
        ),
        triggerPrint: $triggerPrint
    )
}
