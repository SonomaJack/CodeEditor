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
    case csv = "CSV"
    case plaintext = "Plain Text"
    case unknown = "Unknown"
    
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
        case .csv: return ".csv"
        case .plaintext: return ".txt"
        case .unknown: return ".txt"
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
        case .csv: return [".csv"]
        case .plaintext: return [".txt", ".text"]
        case .unknown: return [] // Catch-all for unrecognized extensions
        }
    }
    
    static func detectLanguage(from filename: String) -> CodeLanguage {
        let lowercased = filename.lowercased()
        
        // Check each language's supported extensions
        for language in CodeLanguage.allCases where language != .unknown {
            for ext in language.supportedExtensions {
                if lowercased.hasSuffix(ext) {
                    return language
                }
            }
        }
        
        // Return unknown for unrecognized file types
        return .unknown
    }
    
    /// Detect language from content analysis
    static func detectLanguage(fromContent content: String) -> CodeLanguage? {
        // Skip if content is too short or empty
        guard content.count > 3 else { return nil }
        
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = trimmed.components(separatedBy: .newlines)
        let firstLine = lines.first ?? ""
        
        // HTML detection (DOCTYPE or HTML tags)
        if trimmed.hasPrefix("<!DOCTYPE html") || 
           trimmed.hasPrefix("<!doctype html") ||
           trimmed.hasPrefix("<html") ||
           trimmed.contains(#"<html"#) {
            return .html
        }
        
        // XML/Plist detection
        if trimmed.hasPrefix("<?xml") {
            if trimmed.contains("<plist") {
                return .xml
            }
            return .xml
        }
        
        // JSON detection
        if (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) ||
           (trimmed.hasPrefix("[") && trimmed.hasSuffix("]")) {
            // Try to parse as JSON to be sure
            if let _ = try? JSONSerialization.jsonObject(with: Data(trimmed.utf8)) {
                return .json
            }
        }
        
        // PRIORITY: Detect programming languages BEFORE documentation formats
        // This prevents Swift files with # directives from being detected as Markdown
        
        // Swift detection (check BEFORE Markdown!)
        if trimmed.contains("import Swift") ||
           trimmed.contains("import Foundation") ||
           trimmed.contains("import UIKit") ||
           trimmed.contains("import SwiftUI") ||
           trimmed.contains("import AppKit") ||
           trimmed.contains("import Cocoa") ||
           (firstLine.hasPrefix("import ") && (trimmed.contains("func ") || trimmed.contains("class ") || trimmed.contains("struct ") || trimmed.contains("enum "))) ||
           trimmed.contains("var ") && trimmed.contains(": ") && (trimmed.contains("String") || trimmed.contains("Int") || trimmed.contains("Bool")) {
            return .swift
        }
        
        // Python detection (import, def, class)
        if firstLine.hasPrefix("import ") || 
           firstLine.hasPrefix("from ") ||
           trimmed.contains("def ") ||
           trimmed.contains("class ") && trimmed.contains(":") {
            return .python
        }
        
        // JavaScript/TypeScript detection
        if trimmed.contains("const ") || trimmed.contains("let ") || trimmed.contains("var ") {
            if trimmed.contains(": string") || trimmed.contains(": number") || trimmed.contains("interface ") {
                return .typescript
            }
            if trimmed.contains("function ") || trimmed.contains("=>") || trimmed.contains("console.log") {
                return .javascript
            }
        }
        
        // Java detection
        if trimmed.contains("public class ") || 
           trimmed.contains("public static void main") ||
           (firstLine.hasPrefix("package ") || firstLine.hasPrefix("import java.")) {
            return .java
        }
        
        // Now check documentation formats (after programming languages)
        
        // YAML detection (starts with ---)
        if trimmed.hasPrefix("---") && lines.count > 1 {
            // Make sure it's not just a markdown separator
            if lines.dropFirst().contains(where: { $0.contains(": ") && !$0.hasPrefix("#") }) {
                return .yaml
            }
        }
        
        // Markdown detection (headers, lists, etc.)
        // Only detect as Markdown if it looks like documentation, not code
        let hasMarkdownHeaders = firstLine.hasPrefix("# ") || firstLine.hasPrefix("## ") || firstLine.hasPrefix("### ")
        let hasMarkdownLists = lines.contains(where: { $0.hasPrefix("- ") || $0.hasPrefix("* ") || $0.hasPrefix("+ ") })
        let hasCodeBlocks = trimmed.contains("```") || trimmed.contains("~~~")
        
        if hasMarkdownHeaders || hasMarkdownLists || hasCodeBlocks {
            return .markdown
        }
        
        // Apex detection (Salesforce)
        if trimmed.contains("public class ") && trimmed.contains("@isTest") ||
           trimmed.contains("trigger ") && trimmed.contains(" on ") {
            return .apex
        }
        
        // C++ detection
        if trimmed.contains("#include <iostream>") || 
           trimmed.contains("std::") ||
           trimmed.contains("namespace ") {
            return .cpp
        }
        
        // C detection
        if trimmed.contains("#include <stdio.h>") || 
           trimmed.contains("#include <stdlib.h>") {
            return .c
        }
        
        // C# detection
        if trimmed.contains("using System") || trimmed.contains("namespace ") && trimmed.contains("class ") {
            return .csharp
        }
        
        // Go detection
        if firstLine.hasPrefix("package ") || trimmed.contains("func main()") {
            return .go
        }
        
        // Rust detection
        if trimmed.contains("fn main()") || trimmed.contains("use std::") {
            return .rust
        }
        
        // Ruby detection
        if firstLine.hasPrefix("require ") || trimmed.contains("def ") && trimmed.contains("end") {
            return .ruby
        }
        
        // PHP detection
        if trimmed.hasPrefix("<?php") {
            return .php
        }
        
        // SQL detection
        if firstLine.uppercased().hasPrefix("SELECT ") ||
           firstLine.uppercased().hasPrefix("CREATE TABLE") ||
           firstLine.uppercased().hasPrefix("INSERT INTO") ||
           firstLine.uppercased().hasPrefix("UPDATE ") {
            return .sql
        }
        
        // CSS detection
        if trimmed.contains("{") && trimmed.contains("}") && 
           (trimmed.contains(":") && trimmed.contains(";")) {
            // Simple heuristic for CSS
            let hasColorOrSize = trimmed.contains("color:") || trimmed.contains("font-") || trimmed.contains("margin") || trimmed.contains("padding")
            if hasColorOrSize {
                return .css
            }
        }
        
        // CSV detection (comma-separated values with consistent structure)
        if lines.count >= 2 {
            // Check if first few lines have similar comma counts
            let firstLineCommas = firstLine.filter { $0 == "," }.count
            if firstLineCommas > 0 {
                let consistentCommas = lines.prefix(min(5, lines.count)).allSatisfy { line in
                    let commaCount = line.filter { $0 == "," }.count
                    return commaCount == firstLineCommas || line.isEmpty
                }
                if consistentCommas && firstLineCommas >= 1 {
                    return .csv
                }
            }
        }
        
        return nil // No confident detection
    }
}

@Observable
class CodeDocument: Identifiable, Hashable {
    let id = UUID()
    var filename: String
    var content: String {
        didSet {
            // Auto-detect language if file is unnamed/untitled and language is plaintext
            if shouldAutoDetectLanguage && content != oldValue {
                updateLanguageFromContent()
            }
        }
    }
    var language: CodeLanguage
    var isModified: Bool = false
    var fileURL: URL?
    var lastSaveDate: Date?
    var showLineNumbers: Bool = true
    var shouldAutoDetectLanguage: Bool = true // Enable auto-detection for new files
    
    init(filename: String, content: String = "", language: CodeLanguage? = nil, fileURL: URL? = nil) {
        self.filename = filename
        self.content = content
        self.language = language ?? CodeLanguage.detectLanguage(from: filename)
        self.fileURL = fileURL
        self.lastSaveDate = nil
        
        // Disable auto-detection if file is loaded from disk (has URL)
        self.shouldAutoDetectLanguage = (fileURL == nil)
    }
    
    /// Update language based on content analysis
    func updateLanguageFromContent() {
        // Only auto-detect if enabled and file doesn't have a specific extension
        guard shouldAutoDetectLanguage else { return }
        
        // Don't override if filename has a recognized extension
        if !filename.hasPrefix("Untitled") && filename.contains(".") {
            let detectedFromName = CodeLanguage.detectLanguage(from: filename)
            if detectedFromName != .plaintext && detectedFromName != .unknown {
                // User gave it a specific extension, respect that
                shouldAutoDetectLanguage = false
                return
            }
        }
        
        if let detectedLanguage = CodeLanguage.detectLanguage(fromContent: content) {
            if language != detectedLanguage {
                language = detectedLanguage
                print("🔍 Auto-detected language: \(detectedLanguage.rawValue)")
            }
        }
    }
    
    // Load document from file URL
    static func load(from url: URL) throws -> CodeDocument {
        // Try to load as UTF-8 text
        var content: String
        var language: CodeLanguage
        
        do {
            content = try String(contentsOf: url, encoding: .utf8)
            language = CodeLanguage.detectLanguage(from: url.lastPathComponent)
        } catch {
            // If UTF-8 fails, try other encodings
            if let data = try? Data(contentsOf: url),
               let decodedString = String(data: data, encoding: .ascii) ??
                                   String(data: data, encoding: .isoLatin1) {
                content = decodedString
                language = .unknown
                print("⚠️ Opened file with non-UTF8 encoding: \(url.lastPathComponent)")
            } else {
                // If all text decodings fail, show a placeholder
                throw NSError(
                    domain: "ClarityCodeEdit",
                    code: 2,
                    userInfo: [NSLocalizedDescriptionKey: "Unable to read file as text. File may be binary or use an unsupported encoding."]
                )
            }
        }
        
        let filename = url.lastPathComponent
        
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
        document.shouldAutoDetectLanguage = false // Don't auto-detect for existing files
        
        return document
    }
    
    // Save document to file
    func save() throws {
        guard let url = fileURL else {
            throw NSError(domain: "ClarityCodeEdit", code: 1, userInfo: [NSLocalizedDescriptionKey: "No file URL specified"])
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
