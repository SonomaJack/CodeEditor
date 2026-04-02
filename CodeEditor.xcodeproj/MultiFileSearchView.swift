//
//  MultiFileSearchView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI

struct MultiFileSearchResult: Identifiable {
    let id = UUID()
    let document: CodeDocument
    let lineNumber: Int
    let columnStart: Int
    let columnEnd: Int
    let lineContent: String
    let matchedText: String
}

struct MultiFileSearchView: View {
    @Binding var isPresented: Bool
    let documents: [CodeDocument]
    let onResultSelected: (CodeDocument, SearchResult) -> Void
    
    @State private var searchText = ""
    @State private var caseSensitive = false
    @State private var useRegex = false
    @State private var results: [MultiFileSearchResult] = []
    @State private var isSearching = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("Search in all files", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { performSearch() }
                
                Toggle("Aa", isOn: $caseSensitive)
                    .help("Case Sensitive")
                    .toggleStyle(.button)
                
                Toggle(".*", isOn: $useRegex)
                    .help("Regular Expression")
                    .toggleStyle(.button)
                
                Button("Search") {
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchText.isEmpty)
                
                Button("Close") {
                    isPresented = false
                }
            }
            .padding()
            
            Divider()
            
            // Results
            if isSearching {
                ProgressView("Searching...")
                    .frame(maxHeight: .infinity)
            } else if results.isEmpty && !searchText.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No results found")
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
            } else if !results.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(groupedResults.keys.sorted(by: { $0.filename < $1.filename }), id: \.self) { document in
                            FileResultsSection(
                                document: document,
                                results: groupedResults[document] ?? [],
                                onResultSelected: { result in
                                    onResultSelected(document, SearchResult(
                                        lineNumber: result.lineNumber,
                                        columnStart: result.columnStart,
                                        columnEnd: result.columnEnd,
                                        lineContent: result.lineContent,
                                        matchedText: result.matchedText
                                    ))
                                    isPresented = false
                                }
                            )
                        }
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("Search across all open files")
                        .foregroundStyle(.secondary)
                }
                .frame(maxHeight: .infinity)
            }
        }
        .frame(width: 600, height: 400)
    }
    
    private var groupedResults: [CodeDocument: [MultiFileSearchResult]] {
        Dictionary(grouping: results, by: { $0.document })
    }
    
    private func performSearch() {
        isSearching = true
        results = []
        
        DispatchQueue.global(qos: .userInitiated).async {
            var foundResults: [MultiFileSearchResult] = []
            
            for document in documents {
                let lines = document.content.split(separator: "\n", omittingEmptySubsequences: false)
                
                for (lineIndex, line) in lines.enumerated() {
                    let lineString = String(line)
                    let matches = findMatches(in: lineString)
                    
                    for match in matches {
                        foundResults.append(MultiFileSearchResult(
                            document: document,
                            lineNumber: lineIndex + 1,
                            columnStart: match.location + 1,
                            columnEnd: match.location + match.length + 1,
                            lineContent: lineString,
                            matchedText: String(lineString[lineString.index(lineString.startIndex, offsetBy: match.location)..<lineString.index(lineString.startIndex, offsetBy: match.location + match.length)])
                        ))
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.results = foundResults
                self.isSearching = false
            }
        }
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
            let location = text.distance(from: text.startIndex, to: range.lowerBound)
            let length = text.distance(from: range.lowerBound, to: range.upperBound)
            matches.append(NSRange(location: location, length: length))
            
            searchRange = range.upperBound..<text.endIndex
        }
        
        return matches
    }
}

struct FileResultsSection: View {
    let document: CodeDocument
    let results: [MultiFileSearchResult]
    let onResultSelected: (MultiFileSearchResult) -> Void
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // File header
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                    
                    Image(systemName: "doc.text")
                        .foregroundStyle(.blue)
                    
                    Text(document.filename)
                        .font(.headline)
                    
                    Text("(\(results.count) results)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(nsColor: .controlBackgroundColor))
            }
            .buttonStyle(.plain)
            
            // Results
            if isExpanded {
                ForEach(results) { result in
                    Button(action: { onResultSelected(result) }) {
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(result.lineNumber)")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .frame(width: 40, alignment: .trailing)
                            
                            Text(result.lineContent)
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(1)
                                .truncationMode(.tail)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .background(Color.clear)
                    .onHover { isHovering in
                        // Could add hover effect
                    }
                }
            }
        }
    }
}

#Preview {
    MultiFileSearchView(
        isPresented: .constant(true),
        documents: [
            CodeDocument(filename: "Test.swift", content: "import SwiftUI\n\nstruct Test: View {\n    var body: some View {\n        Text(\"Hello\")\n    }\n}", language: .swift)
        ],
        onResultSelected: { _, _ in }
    )
}
