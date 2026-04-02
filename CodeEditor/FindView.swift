//
//  FindView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/28/26.
//

import SwiftUI

struct FindView: View {
    @Binding var isPresented: Bool
    @Binding var documentContent: String
    var onResultSelected: ((SearchResult) -> Void)? = nil
    
    @State private var searchText = ""
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
    @State private var showPremiumGate = false
    @FocusState private var isSearchFieldFocused: Bool
    @State private var showSpecialCharsMenu = false
    
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
            // Compact single-line search bar
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .frame(width: 16)
                
                TextField("Find", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFieldFocused)
                    .onSubmit { findNext() }
                    .onChange(of: searchText) { _, _ in
                        // Incremental search - search as you type
                        performQuietSearch()
                        if !searchResults.isEmpty {
                            currentResultIndex = 0
                        }
                    }
                
                Button(action: { 
                    showSpecialCharsMenu.toggle()
                }) {
                    Image(systemName: "character.textbox")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderless)
                .help("Insert special character")
                .popover(isPresented: $showSpecialCharsMenu) {
                    specialCharactersMenu
                }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                    }
                    .buttonStyle(.plain)
                }
                
                Divider().frame(height: 16)
                
                // Navigation
                Button(action: findPrevious) {
                    Image(systemName: "chevron.up")
                }
                .disabled(searchText.isEmpty)
                .buttonStyle(.borderless)
                .help("Previous (⇧⌘G)")
                .keyboardShortcut("g", modifiers: [.command, .shift])
                
                Button(action: findNext) {
                    Image(systemName: "chevron.down")
                }
                .disabled(searchText.isEmpty)
                .buttonStyle(.borderless)
                .help("Next (⌘G)")
                .keyboardShortcut("g", modifiers: .command)
                
                Button("All") { findAll() }
                    .disabled(searchText.isEmpty)
                    .buttonStyle(.borderless)
                
                Divider().frame(height: 16)
                
                // Options
                Toggle(isOn: $caseSensitive) {
                    Text("Aa")
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Match Case")
                .controlSize(.small)
                .onChange(of: caseSensitive) { _, _ in
                    if !searchText.isEmpty {
                        performQuietSearch()
                        if !searchResults.isEmpty && currentResultIndex == nil {
                            currentResultIndex = 0
                        }
                    }
                }
                
                Toggle(isOn: $useRegex) {
                    Text(".*")
                        .font(.system(size: 11, design: .monospaced))
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Regex")
                .controlSize(.small)
                .onChange(of: useRegex) { _, _ in
                    if !searchText.isEmpty {
                        performQuietSearch()
                        if !searchResults.isEmpty && currentResultIndex == nil {
                            currentResultIndex = 0
                        }
                    }
                }
                
                Toggle(isOn: $wholeWord) {
                    Image(systemName: "w.square")
                        .font(.system(size: 11))
                }
                .toggleStyle(.button)
                .buttonStyle(.borderless)
                .help("Whole Word")
                .controlSize(.small)
                .onChange(of: wholeWord) { _, _ in
                    if !searchText.isEmpty {
                        performQuietSearch()
                        if !searchResults.isEmpty && currentResultIndex == nil {
                            currentResultIndex = 0
                        }
                    }
                }
                
                // Column search toggle
                Button(action: { 
                    if FeatureAccess.canUseColumnSearch {
                        showColumnOptions.toggle()
                    } else {
                        showPremiumGate = true
                    }
                }) {
                    HStack(spacing: 2) {
                        Image(systemName: "tablecells")
                            .font(.system(size: 11))
                        if !FeatureAccess.canUseColumnSearch {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.borderless)
                .help(FeatureAccess.canUseColumnSearch ? "Column Search" : "Column Search (Premium)")
                .background(useColumnSearch ? Color.accentColor.opacity(0.2) : Color.clear)
                .cornerRadius(4)
                
                if showingResults, let index = currentResultIndex {
                    Divider().frame(height: 16)
                    Text("\(index + 1) of \(searchResults.count)")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                
                Spacer()
                
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(nsColor: .controlBackgroundColor))
            
            // Column search options
            if showColumnOptions {
                HStack(spacing: 8) {
                    Toggle("Column Search:", isOn: $useColumnSearch)
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
                    
                    Text("Start:")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    TextField("", text: $startColumn)
                        .textFieldStyle(.plain)
                        .frame(width: 40)
                        .padding(2)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(3)
                        .font(.system(size: 11, design: .monospaced))
                        .disabled(!useColumnSearch)
                        .onChange(of: startColumn) { _, _ in
                            if !searchText.isEmpty && useColumnSearch {
                                performQuietSearch()
                            }
                        }
                    
                    Text("End:")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                    
                    TextField("", text: $endColumn)
                        .textFieldStyle(.plain)
                        .frame(width: 40)
                        .padding(2)
                        .background(Color(nsColor: .textBackgroundColor))
                        .cornerRadius(3)
                        .font(.system(size: 11, design: .monospaced))
                        .disabled(!useColumnSearch)
                        .onChange(of: endColumn) { _, _ in
                            if !searchText.isEmpty && useColumnSearch {
                                performQuietSearch()
                            }
                        }
                    
                    Text("(empty = end of line)")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            }
            
            // Compact results
            if showingResults && !searchResults.isEmpty {
                Divider()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(searchResults.enumerated()), id: \.offset) { index, result in
                            SearchResultRow(result: result, isSelected: currentResultIndex == index) {
                                currentResultIndex = index
                            }
                        }
                    }
                }
                .frame(maxHeight: 120)
            }
        }
        .sheet(isPresented: $showPremiumGate) {
            PremiumFeatureView(feature: FeatureAccess.featureDescription(for: .columnSearch))
        }
        .onAppear {
            isSearchFieldFocused = true
        }
    }
    
    // MARK: - Special Characters Menu
    
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
                            searchText += char.actual
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
            
            let matches = findMatches(in: searchRange)
            
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
            
            let matches = findMatches(in: searchRange)
            
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
    
    // MARK: - Helper Methods
    
    private func getSearchRange(for line: String) -> String {
        guard useColumnSearch else { return line }
        
        let start = max(0, (Int(startColumn) ?? 1) - 1)
        let end = endColumn.isEmpty ? line.count : (Int(endColumn) ?? line.count)
        
        let startIndex = line.index(line.startIndex, offsetBy: start, limitedBy: line.endIndex) ?? line.endIndex
        let endIndex = line.index(line.startIndex, offsetBy: min(line.count, end), limitedBy: line.endIndex) ?? line.endIndex
        
        guard startIndex <= endIndex else { return "" }
        
        return String(line[startIndex..<endIndex])
    }
    
    private func findMatches(in text: String) -> [NSRange] {
        guard !text.isEmpty else { return [] }
        
        var matches: [NSRange] = []
        
        if useRegex {
            do {
                let regex = try NSRegularExpression(
                    pattern: searchText,
                    options: caseSensitive ? [] : .caseInsensitive
                )
                let nsText = text as NSString
                matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length)).map { $0.range }
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
    
    FindView(
        isPresented: $isPresented,
        documentContent: $content,
        onResultSelected: { result in
            print("Selected result at line \(result.lineNumber)")
        }
    )
}
