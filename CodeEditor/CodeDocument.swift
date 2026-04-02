//
//  CodeDocument.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import Foundation

enum CodeLanguage: String, CaseIterable, Identifiable {
    case swift = "Swift"
    case python = "Python"
    case javascript = "JavaScript"
    case typescript = "TypeScript"
    case java = "Java"
    case apex = "Apex (Salesforce)"
    case cpp = "C++"
    case c = "C"
    case csharp = "C#"
    case go = "Go"
    case rust = "Rust"
    case ruby = "Ruby"
    case php = "PHP"
    case sql = "SQL"
    case html = "HTML"
    case css = "CSS"
    case markdown = "Markdown"
    case json = "JSON"
    case xml = "XML"
    case yaml = "YAML"
    case plaintext = "Plain Text"
    
    var id: String { rawValue }
    
    /// Get languages sorted with free languages first if not premium
    static func sortedLanguages(hasPremium: Bool) -> [CodeLanguage] {
        if hasPremium {
            // Alphabetical if premium
            return allCases.sorted { $0.rawValue < $1.rawValue }
        } else {
            // Free languages first, then rest alphabetically
            let freeLanguages = FeatureAccess.freeLanguages.sorted { $0.rawValue < $1.rawValue }
            let premiumLanguages = allCases.filter { !FeatureAccess.freeLanguages.contains($0) }
                .sorted { $0.rawValue < $1.rawValue }
            return freeLanguages + premiumLanguages
        }
    }
    
    var fileExtension: String {
        switch self {
        case .swift: return ".swift"
        case .python: return ".py"
        case .javascript: return ".js"
        case .typescript: return ".ts"
        case .java: return ".java"
        case .apex: return ".cls"
        case .cpp: return ".cpp"
        case .c: return ".c"
        case .csharp: return ".cs"
        case .go: return ".go"
        case .rust: return ".rs"
        case .ruby: return ".rb"
        case .php: return ".php"
        case .sql: return ".sql"
        case .html: return ".html"
        case .css: return ".css"
        case .markdown: return ".md"
        case .json: return ".json"
        case .xml: return ".xml"
        case .yaml: return ".yaml"
        case .plaintext: return ".txt"
        }
    }
    
    var supportedExtensions: [String] {
        switch self {
        case .swift: return [".swift"]
        case .python: return [".py", ".pyw"]
        case .javascript: return [".js", ".jsx", ".mjs"]
        case .typescript: return [".ts", ".tsx"]
        case .java: return [".java"]
        case .apex: return [".cls", ".trigger"]
        case .cpp: return [".cpp", ".hpp", ".cc", ".cxx", ".h++"]
        case .c: return [".c", ".h"]
        case .csharp: return [".cs"]
        case .go: return [".go"]
        case .rust: return [".rs"]
        case .ruby: return [".rb", ".rake"]
        case .php: return [".php", ".phtml"]
        case .sql: return [".sql"]
        case .html: return [".html", ".htm"]
        case .css: return [".css", ".scss", ".sass", ".less"]
        case .markdown: return [".md", ".markdown"]
        case .json: return [".json"]
        case .xml: return [".xml", ".plist"]
        case .yaml: return [".yaml", ".yml"]
        case .plaintext: return [".txt", ".text"]
        }
    }
    
    static func detectLanguage(from filename: String) -> CodeLanguage {
        let lowercased = filename.lowercased()
        
        // Check each language's supported extensions
        for language in CodeLanguage.allCases {
            for ext in language.supportedExtensions {
                if lowercased.hasSuffix(ext) {
                    return language
                }
            }
        }
        
        return .plaintext
    }
}

@Observable
class CodeDocument: Identifiable, Hashable {
    let id = UUID()
    var filename: String
    var content: String
    var language: CodeLanguage
    var isModified: Bool = false
    var fileURL: URL?
    var lastSaveDate: Date?
    var showLineNumbers: Bool = true
    
    init(filename: String, content: String = "", language: CodeLanguage? = nil, fileURL: URL? = nil) {
        self.filename = filename
        self.content = content
        self.language = language ?? CodeLanguage.detectLanguage(from: filename)
        self.fileURL = fileURL
        self.lastSaveDate = nil
    }
    
    // Load document from file URL
    static func load(from url: URL) throws -> CodeDocument {
        let content = try String(contentsOf: url, encoding: .utf8)
        let filename = url.lastPathComponent
        let language = CodeLanguage.detectLanguage(from: filename)
        
        // Get file modification date
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        let modificationDate = attributes[.modificationDate] as? Date
        
        let document = CodeDocument(
            filename: filename,
            content: content,
            language: language,
            fileURL: url
        )
        document.lastSaveDate = modificationDate
        
        return document
    }
    
    // Save document to file
    func save() throws {
        guard let url = fileURL else {
            throw NSError(domain: "CodeEditor", code: 1, userInfo: [NSLocalizedDescriptionKey: "No file URL specified"])
        }
        
        try content.write(to: url, atomically: true, encoding: .utf8)
        isModified = false
        lastSaveDate = Date()
    }
    
    // MARK: - Hashable Conformance
    static func == (lhs: CodeDocument, rhs: CodeDocument) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
