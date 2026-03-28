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
    case java = "Java"
    case apex = "Apex (Salesforce)"
    case cpp = "C++"
    case html = "HTML"
    case css = "CSS"
    case plaintext = "Plain Text"
    
    var id: String { rawValue }
    
    var fileExtension: String {
        switch self {
        case .swift: return ".swift"
        case .python: return ".py"
        case .javascript: return ".js"
        case .java: return ".java"
        case .apex: return ".cls"
        case .cpp: return ".cpp"
        case .html: return ".html"
        case .css: return ".css"
        case .plaintext: return ".txt"
        }
    }
    
    var supportedExtensions: [String] {
        switch self {
        case .swift: return [".swift"]
        case .python: return [".py"]
        case .javascript: return [".js"]
        case .java: return [".java"]
        case .apex: return [".cls", ".trigger"]
        case .cpp: return [".cpp", ".h", ".hpp", ".c", ".cc"]
        case .html: return [".html", ".htm"]
        case .css: return [".css"]
        case .plaintext: return [".txt"]
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
