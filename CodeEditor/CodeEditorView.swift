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
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor toolbar
            HStack {
                Text(document.filename)
                    .font(.headline)
                
                Spacer()
                
                Picker("Language", selection: $document.language) {
                    ForEach(CodeLanguage.allCases) { language in
                        Text(language.rawValue).tag(language)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180)
                
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
            
            // Code editor with native scrolling
            CodeTextView(
                text: $document.content,
                isModified: $document.isModified,
                language: document.language,
                onTextChange: updateSuggestions
            )
            
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
    }
    
    private func saveDocument() {
        do {
            try document.save()
        } catch {
            print("Error saving document: \(error.localizedDescription)")
        }
    }
    
    private func printDocument() {
        PrintCoordinator.printCode(document.content, filename: document.filename, from: NSApp.keyWindow)
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
