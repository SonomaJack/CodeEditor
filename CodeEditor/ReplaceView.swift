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
                        .onSubmit {
                            findAll()
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
                        Toggle("Regex", isOn: $useRegex)
                        Toggle("Whole Word", isOn: $wholeWord)
                    }
                    .toggleStyle(.checkbox)
                    .font(.system(size: 11))
                    
                    Toggle("Search in Specific Columns", isOn: $useColumnSearch)
                        .toggleStyle(.checkbox)
                        .font(.system(size: 11))
                    
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
                            
                            Text("to")
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                            
                            TextField("End", text: $endColumn)
                                .textFieldStyle(.plain)
                                .frame(width: 50)
                                .padding(4)
                                .background(Color(nsColor: .textBackgroundColor))
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
                    
                    Spacer()
                    
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
    }
    
    // MARK: - Find Operations
    
    private func findAll() {
        searchResults = []
        currentResultIndex = nil
        
        guard !searchText.isEmpty else {
            showingResults = false
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
    
    private func performQuietSearch() {
        searchResults = []
        currentResultIndex = nil
        
        guard !searchText.isEmpty else { return }
        
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
        
        let result = searchResults[currentIndex]
        replaceMatch(at: result)
        
        // Refresh search results after replacement
        findAll()
    }
    
    private func replaceAll() {
        guard !searchText.isEmpty else { return }
        
        if searchResults.isEmpty {
            findAll()
        }
        
        guard !searchResults.isEmpty else { return }
        
        // Replace from end to start to maintain valid indices
        let sortedResults = searchResults.sorted { first, second in
            if first.lineNumber != second.lineNumber {
                return first.lineNumber > second.lineNumber
            }
            return first.columnStart > second.columnStart
        }
        
        for result in sortedResults {
            replaceMatch(at: result)
        }
        
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
