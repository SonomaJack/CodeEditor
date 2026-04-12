//
//  CodeEditorView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct CodeEditorView: View {
    @Bindable var document: CodeDocument
    @Binding var triggerPrint: Bool
    @State private var fontSize: CGFloat = UserDefaults.standard.object(forKey: "fontSize") as? CGFloat ?? 13
    @State private var showStatusBar = true
    @State private var suggestions: [CompletionSuggestion] = []
    @State private var showSuggestions = false
    @State private var cursorPosition = 0
    @State private var cursorLine = 1
    @State private var cursorColumn = 1
    @State private var selectionLength = 0
    @State private var showPrintPanel = false
    @State private var showFind = false
    @State private var showReplace = false
    @State private var showGoToLine = false
    @State private var goToLineText = ""
    @State private var highlightRange: HighlightRange? = nil
    @State private var showPremiumGate = false
    @State private var premiumFeatureMessage = ""
    @State private var showSaveError = false
    @State private var saveErrorMessage = ""
    @State private var showSnippets = false
    @StateObject private var store = StoreManager.shared
    
    private var goToLineNumber: Int? {
        guard let line = Int(goToLineText) else { return nil }
        let totalLines = document.content.split(separator: "\n", omittingEmptySubsequences: false).count
        return (line >= 1 && line <= totalLines) ? line : nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Editor toolbar
            HStack {
                Text(document.filename)
                    .font(.headline)
                
                Spacer()
                
                // Font size indicator
                Text("\(Int(fontSize))pt")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
                
                // Line numbers toggle
                Button(action: { document.showLineNumbers.toggle() }) {
                    Label("Line Numbers", systemImage: document.showLineNumbers ? "list.number" : "list.bullet")
                }
                .help(document.showLineNumbers ? "Hide line numbers" : "Show line numbers")
                
                HStack(spacing: 4) {
                    Picker("Language", selection: $document.language) {
                        ForEach(CodeLanguage.sortedLanguages(hasPremium: store.hasPremiumFeatures)) { language in
                            HStack {
                                Text(language.rawValue)
                                if !FeatureAccess.canUseLanguage(language) {
                                    Image(systemName: "lock.fill")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .tag(language)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 180)
                    .onChange(of: document.language) { oldValue, newValue in
                        // Only check premium for manual changes (not auto-detection)
                        if !document.shouldAutoDetectLanguage {
                            if !FeatureAccess.canUseLanguage(newValue) {
                                document.language = oldValue
                                premiumFeatureMessage = FeatureAccess.featureDescription(for: .language(newValue))
                                showPremiumGate = true
                            }
                        }
                    }
                    
                    // Auto-detect indicator
                    if document.shouldAutoDetectLanguage {
                        Button(action: {
                            document.shouldAutoDetectLanguage = false
                        }) {
                            HStack(spacing: 2) {
                                Image(systemName: "wand.and.stars")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .buttonStyle(.plain)
                        .help("Auto-detection enabled. Click to disable.")
                    } else {
                        Button(action: {
                            document.shouldAutoDetectLanguage = true
                            document.updateLanguageFromContent()
                        }) {
                            HStack(spacing: 2) {
                                Image(systemName: "wand.and.stars.inverse")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .help("Auto-detection disabled. Click to enable.")
                    }
                }
                
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
                    if FeatureAccess.canUseFindAndReplace {
                        showReplace.toggle()
                        if showReplace {
                            showFind = false
                        }
                    } else {
                        premiumFeatureMessage = FeatureAccess.featureDescription(for: .findAndReplace)
                        showPremiumGate = true
                    }
                }) {
                    Label("Replace", systemImage: "arrow.triangle.2.circlepath")
                }
                .help("Find and replace")
                .keyboardShortcut("h", modifiers: [.command, .option])
                
                Button(action: {
                    if FeatureAccess.canUsePrinting {
                        printDocument()
                    } else {
                        premiumFeatureMessage = FeatureAccess.featureDescription(for: .printing)
                        showPremiumGate = true
                    }
                }) {
                    Label("Print", systemImage: "printer")
                }
                .help("Print document")
                
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
                            columnEnd: result.columnEnd,
                            id: UUID() // Force update with new ID
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
                            columnEnd: result.columnEnd,
                            id: UUID() // Force update with new ID
                        )
                    }
                )
                
                Divider()
            }
            
            // Code editor with line numbers
            HStack(spacing: 0) {
                CodeTextView(
                    text: $document.content,
                    isModified: $document.isModified,
                    language: document.language,
                    showLineNumbers: document.showLineNumbers,
                    fontSize: fontSize,
                    onTextChange: updateSuggestions,
                    highlightRange: highlightRange,
                    onCursorPositionChange: { line, column, selectionLen in
                        cursorLine = line
                        cursorColumn = column
                        selectionLength = selectionLen
                    }
                )
                .id(document.id) // Ensure each document gets its own text view instance
            }
            
            // Completion suggestions
            if showSuggestions && !suggestions.isEmpty && FeatureAccess.canUseCodeCompletion {
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
            
            // Status Bar
            if showStatusBar {
                Divider()
                HStack(spacing: 16) {
                    // Language
                    HStack(spacing: 4) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 10))
                        Text(document.language.rawValue)
                            .font(.system(size: 11))
                        if document.shouldAutoDetectLanguage {
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 9))
                                .foregroundStyle(.blue)
                                .help("Auto-detecting language")
                        }
                    }
                    
                    Divider()
                        .frame(height: 12)
                    
                    // Line and Column
                    Text("Ln \(cursorLine), Col \(cursorColumn)")
                        .font(.system(size: 11))
                        .monospacedDigit()
                    
                    if selectionLength > 0 {
                        Text("(\(selectionLength) selected)")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    
                    Divider()
                        .frame(height: 12)
                    
                    // Character count
                    Text("\(document.content.count) chars")
                        .font(.system(size: 11))
                        .monospacedDigit()
                    
                    Divider()
                        .frame(height: 12)
                    
                    // Line count
                    Text("\(document.content.split(separator: "\n", omittingEmptySubsequences: false).count) lines")
                        .font(.system(size: 11))
                        .monospacedDigit()
                    
                    Spacer()
                    
                    // Encoding
                    Text("UTF-8")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    // Modified indicator
                    if document.isModified {
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.orange)
                                .frame(width: 6, height: 6)
                            Text("Modified")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
        .sheet(isPresented: $showPremiumGate) {
            PremiumFeatureView(feature: premiumFeatureMessage)
        }
        .sheet(isPresented: $showGoToLine) {
            VStack(spacing: 16) {
                Text("Go to Line")
                    .font(.headline)
                
                HStack {
                    Text("Line:")
                        .font(.body)
                    
                    TextField("", text: $goToLineText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                        .onSubmit {
                            performGoToLine()
                        }
                    
                    Text("(1-\(document.content.split(separator: "\n", omittingEmptySubsequences: false).count))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Button("Cancel") {
                        showGoToLine = false
                        goToLineText = ""
                    }
                    .keyboardShortcut(.cancelAction)
                    
                    Button("Go") {
                        performGoToLine()
                    }
                    .keyboardShortcut(.defaultAction)
                    .disabled(goToLineNumber == nil)
                }
            }
            .padding()
            .frame(width: 300)
        }
        .alert("Save Error", isPresented: $showSaveError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
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
        .onReceive(NotificationCenter.default.publisher(for: .saveFile)) { _ in
            saveDocument()
        }
        .onReceive(NotificationCenter.default.publisher(for: .saveFileAs)) { _ in
            showSaveAsDialog()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goToLine)) { _ in
            showGoToLine = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .zoomIn)) { _ in
            zoomIn()
        }
        .onReceive(NotificationCenter.default.publisher(for: .zoomOut)) { _ in
            zoomOut()
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetZoom)) { _ in
            resetZoom()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSnippets)) { _ in
            showSnippets = true
        }
    }
    
    private func saveDocument() {
        // If no file URL exists, show Save As dialog
        if document.fileURL == nil {
            showSaveAsDialog()
            return
        }
        
        // Otherwise, save to existing location
        do {
            try document.save()
        } catch {
            saveErrorMessage = error.localizedDescription
            showSaveError = true
        }
    }
    
    private func showSaveAsDialog() {
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = document.filename
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        savePanel.allowedContentTypes = [UTType(filenameExtension: String(document.language.fileExtension.dropFirst())) ?? .text]
        savePanel.message = "Choose a location to save your file"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                document.fileURL = url
                document.filename = url.lastPathComponent
                
                do {
                    try document.save()
                } catch {
                    saveErrorMessage = error.localizedDescription
                    showSaveError = true
                }
            }
        }
    }
    
    private func printDocument() {
        PrintCoordinator.printDocument(document, from: NSApp.keyWindow)
    }
    
    private func updateSuggestions() {
        guard FeatureAccess.canUseCodeCompletion else {
            suggestions = []
            showSuggestions = false
            return
        }
        
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
    
    private func goToLine(_ line: Int) {
        let lines = document.content.split(separator: "\n", omittingEmptySubsequences: false)
        guard line > 0 && line <= lines.count else { return }
        
        var characterOffset = 0
        for i in 0..<(line - 1) {
            characterOffset += lines[i].count + 1
        }
        
        highlightRange = HighlightRange(
            lineNumber: line,
            columnStart: 1,
            columnEnd: lines[line - 1].count + 1
        )
    }
    
    private func performGoToLine() {
        guard let line = goToLineNumber else { return }
        goToLine(line)
        showGoToLine = false
        goToLineText = ""
    }
    
    private func zoomIn() {
        fontSize = min(fontSize + 1, 24)
        UserDefaults.standard.set(fontSize, forKey: "fontSize")
    }
    
    private func zoomOut() {
        fontSize = max(fontSize - 1, 8)
        UserDefaults.standard.set(fontSize, forKey: "fontSize")
    }
    
    private func resetZoom() {
        fontSize = 13
        UserDefaults.standard.set(fontSize, forKey: "fontSize")
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
