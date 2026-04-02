//
//  ReplaceView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/28/26.
//

import SwiftUI

struct ReplaceView: View {
    @Binding var isPresented: Bool
    @Binding var documentContent: String
    @Binding var isModified: Bool
    var onResultSelected: ((SearchResult) -> Void)? = nil
    
    @State private var searchText = ""
    @State private var replaceText = ""
    @State private var caseSensitive = false
    @State private var useRegex = false
    @State private var wholeWord = false
    @State private var useColumnSearch = false
    @State private var startColumn = "1"
    @State private var endColumn = ""
    
    @State private var searchResults: [SearchResult] = []
    @State private var currentResultIndex: Int? = nil {
        didSet {
            if let index = currentResultIndex, index < searchResults.count {
                onResultSelected?(searchResults[index])
            }
        }
    }
    @State private var showingResults = false
    @State private var showColumnOptions = false
    @FocusState private var isSearchFieldFocused: Bool
    
    // Undo support
    @State private var undoStack: [String] = []
    @State private var canUndo = false
    
    // Replace completion message
    @State private var showReplaceMessage = false
    @State private var replaceMessage = ""
    
    // Special characters menu
    @State private var showSpecialCharsMenu = false
    @State private var specialCharTarget: SpecialCharTarget = .search
    
    enum SpecialCharTarget {
        case search
        case replace
    }
    
    // Special character definitions
    struct SpecialChar: Identifiable {
        let id = UUID()
        let name: String
        let display: String
        let actual: String
        let description: String
    }
    
    let specialChars: [SpecialChar] = [
        SpecialChar(name: "Tab", display: "\\t", actual: "\t", description: "Tab character"),
        SpecialChar(name: "Newline", display: "\\n", actual: "\n", description: "Line feed (LF)"),
        SpecialChar(name: "Carriage Return", display: "\\r", actual: "\r", description: "Carriage return (CR)"),
        SpecialChar(name: "CR+LF", display: "\\r\\n", actual: "\r\n", description: "Windows line ending"),
        SpecialChar(name: "Space", display: "·", actual: " ", description: "Space character"),
        SpecialChar(name: "Non-breaking Space", display: "NBSP", actual: "\u{00A0}", description: "Non-breaking space"),
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Replace")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Search and Replace fields
            VStack(spacing: 12) {
                // Find field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Find", text: $searchText)
                        .textFieldStyle(.plain)
                        .focused($isSearchFieldFocused)
                        .onSubmit {
                            findNext()
                        }
                        .onChange(of: searchText) { _, _ in
                            // Incremental search - search as you type
                            performQuietSearch()
                            if !searchResults.isEmpty {
                                currentResultIndex = 0
                            }
                        }
                    
                    Button(action: { 
                        specialCharTarget = .search
                        showSpecialCharsMenu.toggle()
                    }) {
                        Image(systemName: "character.textbox")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Insert special character")
                    .popover(isPresented: $showSpecialCharsMenu) {
                        specialCharactersMenu
                    }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(6)
                
                // Replace field
                HStack {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundStyle(.secondary)
                    
                    TextField("Replace with", text: $replaceText)
                        .textFieldStyle(.plain)
                    
                    Button(action: { 
                        specialCharTarget = .replace
                        showSpecialCharsMenu.toggle()
                    }) {
                        Image(systemName: "character.textbox")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Insert special character")
                    
                    if !replaceText.isEmpty {
                        Button(action: { replaceText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
                .background(Color(nsColor: .textBackgroundColor))
                .cornerRadius(6)
                
                // Search options
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 16) {
                        Toggle("Case Sensitive", isOn: $caseSensitive)
                            .onChange(of: caseSensitive) { _, _ in
                                if !searchText.isEmpty {
                                    performQuietSearch()
                                    if !searchResults.isEmpty && currentResultIndex == nil {
                                        currentResultIndex = 0
                                    }
                                }
                            }
                        Toggle("Regex", isOn: $useRegex)
                            .onChange(of: useRegex) { _, _ in
                                if !searchText.isEmpty {
                                    performQuietSearch()
                                    if !searchResults.isEmpty && currentResultIndex == nil {
                                        currentResultIndex = 0
                                    }
                                }
                            }
                        Toggle("Whole Word", isOn: $wholeWord)
                            .onChange(of: wholeWord) { _, _ in
                                if !searchText.isEmpty {
                                    performQuietSearch()
                                    if !searchResults.isEmpty && currentResultIndex == nil {
                                        currentResultIndex = 0
                                    }
                                }
                            }
                    }
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))
                    
                    Toggle("Search in Specific Columns", isOn: $useColumnSearch)
                        .toggleStyle(.checkbox)
                        .font(.system(size: 11))
                        .onChange(of: useColumnSearch) { _, _ in
                            if !searchText.isEmpty {
                                performQuietSearch()
                                if !searchResults.isEmpty && currentResultIndex == nil {
                                    currentResultIndex = 0
                                }
                            }
                        }
                    
                    if useColumnSearch {
                        HStack {
                            Text("Columns:")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            
                            TextField("Start", text: $startColumn)
                                .textFieldStyle(.plain)
                                .frame(width: 50)
                                .padding(4)
                                .background(Color(nsColor: .textBackgroundColor))
                                .cornerRadius(4)
                                .onChange(of: startColumn) { _, _ in
                                    if !searchText.isEmpty && useColumnSearch {
                                        performQuietSearch()
                                    }
                                }
                            
                            Text("to")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            
                            TextField("End", text: $endColumn)
                                .textFieldStyle(.plain)
                                .frame(width: 50)
                                .padding(4)
                                .background(Color(nsColor: .textBackgroundColor))
                                .cornerRadius(4)
                                .onChange(of: endColumn) { _, _ in
                                    if !searchText.isEmpty && useColumnSearch {
                                        performQuietSearch()
                                    }
                                }
                                .cornerRadius(4)
                            
                            Text("(leave end empty for rest of line)")
                                .font(.system(size: 10))
                                .foregroundStyle(.tertiary)
                            
                            Spacer()
                        }
                        .padding(.leading, 20)
                    }
                }
                
                // Action buttons
                HStack(spacing: 8) {
                    Button("Find All") {
                        findAll()
                    }
                    .disabled(searchText.isEmpty)
                    
                    Button("Find Next") {
                        findNext()
                    }
                    .disabled(searchText.isEmpty)
                    .keyboardShortcut("g", modifiers: .command)
                    
                    Button("Find Previous") {
                        findPrevious()
                    }
                    .disabled(searchText.isEmpty)
                    .keyboardShortcut("g", modifiers: [.command, .shift])
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button("Replace") {
                        replaceCurrentMatch()
                    }
                    .disabled(currentResultIndex == nil)
                    
                    Button("Replace All") {
                        replaceAll()
                    }
                    .disabled(searchText.isEmpty)
                    
                    Button(action: undo) {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .disabled(!canUndo)
                    .help("Undo last replacement")
                    
                    Spacer()
                    
                    if showReplaceMessage {
                        Text(replaceMessage)
                            .font(.system(size: 11))
                            .foregroundStyle(.green)
                            .transition(.opacity)
                    }
                    
                    if showingResults {
                        Text("\(searchResults.count) result\(searchResults.count == 1 ? "" : "s")")
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                        
                        if let index = currentResultIndex {
                            Text("[\(index + 1) of \(searchResults.count)]")
                                .font(.system(size: 11))
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .padding()
            
            // Results list
            if showingResults && !searchResults.isEmpty {
                Divider()
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(searchResults.enumerated()), id: \.offset) { index, result in
                            SearchResultRow(
                                result: result,
                                isSelected: currentResultIndex == index
                            ) {
                                currentResultIndex = index
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .frame(minWidth: 600)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            isSearchFieldFocused = true
        }
    }
    
    // MARK: - Find Operations
    
    private func findAll() {
        searchResults = []
        currentResultIndex = nil
        
        guard !searchText.isEmpty else {
            showingResults = false
            return
        }
        
        // Check if search text contains line breaks - needs special handling
        if searchText.contains("\n") || searchText.contains("\r") {
            findAllWithLineBreaks()
            return
        }
        
        let lines = documentContent.split(separator: "\n", omittingEmptySubsequences: false)
        
        for (lineIndex, line) in lines.enumerated() {
            let lineString = String(line)
            let columnOffset = useColumnSearch ? ((Int(startColumn) ?? 1) - 1) : 0
            let searchRange = getSearchRange(for: lineString)
            
            let matches = findMatches(in: searchRange, fullLine: lineString)
            
            for match in matches {
                let actualColumnStart = match.location + columnOffset + 1
                let actualColumnEnd = match.location + match.length + columnOffset + 1
                
                searchResults.append(SearchResult(
                    lineNumber: lineIndex + 1,
                    columnStart: actualColumnStart,
                    columnEnd: actualColumnEnd,
                    lineContent: lineString,
                    matchedText: String(searchRange[searchRange.index(searchRange.startIndex, offsetBy: match.location)..<searchRange.index(searchRange.startIndex, offsetBy: match.location + match.length)])
                ))
            }
        }
        
        showingResults = true
        if !searchResults.isEmpty {
            currentResultIndex = 0
        }
    }
    
    private func findNext() {
        if searchResults.isEmpty {
            performQuietSearch()
        }
        
        if searchResults.isEmpty {
            return
        }
        
        if let currentIndex = currentResultIndex {
            let nextIndex = (currentIndex + 1) % searchResults.count
            currentResultIndex = nextIndex
        } else {
            currentResultIndex = 0
        }
    }
    
    private func findPrevious() {
        if searchResults.isEmpty {
            performQuietSearch()
        }
        
        if searchResults.isEmpty {
            return
        }
        
        if let currentIndex = currentResultIndex {
            currentResultIndex = currentIndex > 0 ? currentIndex - 1 : searchResults.count - 1
        } else {
            currentResultIndex = searchResults.count - 1
        }
    }
    
    private func findAllWithLineBreaks() {
        // Special handling for searches containing line breaks
        // Search directly in the document content without splitting
        let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
        var searchRange = documentContent.startIndex..<documentContent.endIndex
        
        while let range = documentContent.range(of: searchText, options: options, range: searchRange) {
            // Calculate which line this match starts on
            let precedingText = String(documentContent[..<range.lowerBound])
            let lineNumber = precedingText.components(separatedBy: "\n").count
            
            // Calculate column position on the starting line
            let lines = precedingText.components(separatedBy: "\n")
            let columnStart = (lines.last?.count ?? 0) + 1
            
            // For display purposes, show first line of match
            let matchText = String(documentContent[range])
            let firstLine = matchText.components(separatedBy: "\n").first ?? matchText
            let displayText = firstLine + (matchText.contains("\n") ? " ↵" : "")
            
            let columnEnd = columnStart + searchText.count
            
            searchResults.append(SearchResult(
                lineNumber: lineNumber,
                columnStart: columnStart,
                columnEnd: columnEnd,
                lineContent: displayText,
                matchedText: matchText
            ))
            
            searchRange = range.upperBound..<documentContent.endIndex
        }
        
        showingResults = true
        if !searchResults.isEmpty {
            currentResultIndex = 0
        }
    }
    
    private func performQuietSearch() {
        searchResults = []
        currentResultIndex = nil
        
        guard !searchText.isEmpty else { return }
        
        // Check if search text contains line breaks - needs special handling
        if searchText.contains("\n") || searchText.contains("\r") {
            findAllWithLineBreaks()
            return
        }
        
        let lines = documentContent.split(separator: "\n", omittingEmptySubsequences: false)
        
        for (lineIndex, line) in lines.enumerated() {
            let lineString = String(line)
            let columnOffset = useColumnSearch ? ((Int(startColumn) ?? 1) - 1) : 0
            let searchRange = getSearchRange(for: lineString)
            
            let matches = findMatches(in: searchRange, fullLine: lineString)
            
            for match in matches {
                let actualColumnStart = match.location + columnOffset + 1
                let actualColumnEnd = match.location + match.length + columnOffset + 1
                
                searchResults.append(SearchResult(
                    lineNumber: lineIndex + 1,
                    columnStart: actualColumnStart,
                    columnEnd: actualColumnEnd,
                    lineContent: lineString,
                    matchedText: String(searchRange[searchRange.index(searchRange.startIndex, offsetBy: match.location)..<searchRange.index(searchRange.startIndex, offsetBy: match.location + match.length)])
                ))
            }
        }
    }
    
    // MARK: - Replace Operations
    
    private func replaceCurrentMatch() {
        guard let currentIndex = currentResultIndex,
              currentIndex < searchResults.count else { return }
        
        // Save state for undo
        saveStateForUndo()
        
        let result = searchResults[currentIndex]
        replaceMatch(at: result)
        
        // Show message
        showMessage("Replaced 1 occurrence")
        
        // Refresh search results after replacement
        findAll()
    }
    
    private func replaceAll() {
        guard !searchText.isEmpty else { return }
        
        if searchResults.isEmpty {
            findAll()
        }
        
        guard !searchResults.isEmpty else {
            showMessage("No matches found")
            return
        }
        
        let matchCount = searchResults.count
        
        // Save state for undo
        saveStateForUndo()
        
        // If searching for line breaks, use direct string replacement
        if searchText.contains("\n") || searchText.contains("\r") {
            let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
            documentContent = documentContent.replacingOccurrences(of: searchText, with: replaceText, options: options)
            isModified = true
            
            // Show message
            showMessage("Replaced \(matchCount) occurrence\(matchCount == 1 ? "" : "s")")
            
            // Refresh search results
            findAll()
            return
        }
        
        // Process all replacements line by line to handle column shifts correctly
        var lines = documentContent.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        
        // Group results by line number
        var resultsByLine: [Int: [SearchResult]] = [:]
        for result in searchResults {
            if resultsByLine[result.lineNumber] == nil {
                resultsByLine[result.lineNumber] = []
            }
            resultsByLine[result.lineNumber]?.append(result)
        }
        
        // Process each line that has matches
        for (lineNumber, lineResults) in resultsByLine {
            let lineIndex = lineNumber - 1
            guard lineIndex < lines.count else { continue }
            
            var line = lines[lineIndex]
            
            // Sort results within this line by column position (right to left)
            let sortedLineResults = lineResults.sorted { $0.columnStart > $1.columnStart }
            
            // Replace matches from right to left to maintain valid positions
            for result in sortedLineResults {
                let startIndex = line.index(line.startIndex, offsetBy: result.columnStart - 1, limitedBy: line.endIndex) ?? line.endIndex
                let endIndex = line.index(line.startIndex, offsetBy: result.columnEnd - 1, limitedBy: line.endIndex) ?? line.endIndex
                
                guard startIndex <= endIndex else { continue }
                
                line.replaceSubrange(startIndex..<endIndex, with: replaceText)
            }
            
            lines[lineIndex] = line
        }
        
        documentContent = lines.joined(separator: "\n")
        isModified = true
        
        // Show message
        showMessage("Replaced \(matchCount) occurrence\(matchCount == 1 ? "" : "s")")
        
        // Refresh search results
        findAll()
    }
    
    private func replaceMatch(at result: SearchResult) {
        var lines = documentContent.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        
        guard result.lineNumber - 1 < lines.count else { return }
        
        let lineIndex = result.lineNumber - 1
        var line = lines[lineIndex]
        
        let startIndex = line.index(line.startIndex, offsetBy: result.columnStart - 1, limitedBy: line.endIndex) ?? line.endIndex
        let endIndex = line.index(line.startIndex, offsetBy: result.columnEnd - 1, limitedBy: line.endIndex) ?? line.endIndex
        
        guard startIndex <= endIndex else { return }
        
        line.replaceSubrange(startIndex..<endIndex, with: replaceText)
        lines[lineIndex] = line
        
        documentContent = lines.joined(separator: "\n")
        isModified = true
    }
    
    // MARK: - Helper Methods
    
    private var specialCharactersMenu: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Insert Special Character")
                .font(.headline)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(specialChars) { char in
                        Button(action: {
                            insertSpecialChar(char)
                            showSpecialCharsMenu = false
                        }) {
                            HStack {
                                Text(char.display)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundStyle(.primary)
                                    .frame(width: 60, alignment: .leading)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(char.name)
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    Text(char.description)
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
                            Color.clear
                                .contentShape(Rectangle())
                        )
                        .onHover { isHovered in
                            if isHovered {
                                NSCursor.pointingHand.push()
                            } else {
                                NSCursor.pop()
                            }
                        }
                        
                        if char.id != specialChars.last?.id {
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }
            }
            .frame(height: 240)
        }
        .frame(width: 320)
    }
    
    private func insertSpecialChar(_ char: SpecialChar) {
        switch specialCharTarget {
        case .search:
            searchText += char.actual
        case .replace:
            replaceText += char.actual
        }
    }
    
    private func getSearchRange(for line: String) -> String {
        guard useColumnSearch else { return line }
        
        let start = (Int(startColumn) ?? 1) - 1
        let end = endColumn.isEmpty ? line.count : (Int(endColumn) ?? line.count)
        
        let startIndex = line.index(line.startIndex, offsetBy: max(0, start), limitedBy: line.endIndex) ?? line.endIndex
        let endIndex = line.index(line.startIndex, offsetBy: min(line.count, end), limitedBy: line.endIndex) ?? line.endIndex
        
        guard startIndex <= endIndex else { return "" }
        
        return String(line[startIndex..<endIndex])
    }
    
    private func findMatches(in text: String, fullLine: String) -> [NSRange] {
        guard !text.isEmpty else { return [] }
        
        var matches: [NSRange] = []
        
        if useRegex {
            do {
                let pattern = searchText
                let regex = try NSRegularExpression(
                    pattern: pattern,
                    options: caseSensitive ? [] : .caseInsensitive
                )
                let nsText = text as NSString
                let results = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
                matches = results.map { $0.range }
            } catch {
                matches = literalSearch(in: text)
            }
        } else {
            matches = literalSearch(in: text)
        }
        
        return matches
    }
    
    private func literalSearch(in text: String) -> [NSRange] {
        var matches: [NSRange] = []
        let options: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
        
        var searchRange = text.startIndex..<text.endIndex
        
        while let range = text.range(of: searchText, options: options, range: searchRange) {
            if wholeWord {
                let beforeChar = range.lowerBound > text.startIndex ? text[text.index(before: range.lowerBound)] : " "
                let afterChar = range.upperBound < text.endIndex ? text[range.upperBound] : " "
                
                if beforeChar.isLetter || beforeChar.isNumber || afterChar.isLetter || afterChar.isNumber {
                    searchRange = range.upperBound..<text.endIndex
                    continue
                }
            }
            
            let location = text.distance(from: text.startIndex, to: range.lowerBound)
            let length = text.distance(from: range.lowerBound, to: range.upperBound)
            matches.append(NSRange(location: location, length: length))
            
            searchRange = range.upperBound..<text.endIndex
        }
        
        return matches
    }
    
    // MARK: - Undo Support
    
    private func saveStateForUndo() {
        undoStack.append(documentContent)
        // Keep only last 10 states to avoid memory issues
        if undoStack.count > 10 {
            undoStack.removeFirst()
        }
        canUndo = true
    }
    
    private func undo() {
        guard let previousState = undoStack.popLast() else { return }
        documentContent = previousState
        isModified = true
        canUndo = !undoStack.isEmpty
        
        // Refresh search results
        findAll()
        
        showMessage("Undo complete")
    }
    
    // MARK: - Message Display
    
    private func showMessage(_ message: String) {
        replaceMessage = message
        withAnimation {
            showReplaceMessage = true
        }
        
        // Hide message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showReplaceMessage = false
            }
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    @Previewable @State var content = """
    import SwiftUI
    
    struct ContentView: View {
        var body: some View {
            Text("Hello, World!")
        }
    }
    """
    @Previewable @State var isModified = false
    
    ReplaceView(
        isPresented: $isPresented,
        documentContent: $content,
        isModified: $isModified,
        onResultSelected: { result in
            print("Selected result at line \(result.lineNumber)")
        }
    )
}
