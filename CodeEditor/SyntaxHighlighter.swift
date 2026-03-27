//
//  SyntaxHighlighter.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI

struct SyntaxHighlighter {
    
    // Define syntax patterns for different languages
    static func highlight(code: String, language: CodeLanguage) -> AttributedString {
        var attributed = AttributedString(code)
        
        switch language {
        case .swift:
            highlightSwift(&attributed, code: code)
        case .python:
            highlightPython(&attributed, code: code)
        case .javascript:
            highlightJavaScript(&attributed, code: code)
        case .java:
            highlightJava(&attributed, code: code)
        case .apex:
            highlightApex(&attributed, code: code)
        case .cpp:
            highlightCPP(&attributed, code: code)
        case .html:
            highlightHTML(&attributed, code: code)
        case .css:
            highlightCSS(&attributed, code: code)
        case .plaintext:
            break
        }
        
        return attributed
    }
    
    // MARK: - Swift Highlighting
    private static func highlightSwift(_ attributed: inout AttributedString, code: String) {
        let keywords = [
            "func", "var", "let", "class", "struct", "enum", "protocol", "extension",
            "import", "if", "else", "for", "while", "switch", "case", "default",
            "return", "guard", "defer", "break", "continue", "in", "is", "as",
            "try", "catch", "throw", "throws", "async", "await", "actor", "self",
            "init", "deinit", "static", "final", "override", "private", "public",
            "internal", "fileprivate", "open", "@State", "@Binding", "@Observable"
        ]
        
        highlightKeywords(&attributed, code: code, keywords: keywords, color: .purple)
        highlightStrings(&attributed, code: code, color: .red)
        highlightComments(&attributed, code: code, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/", color: .green)
        highlightNumbers(&attributed, code: code, color: .blue)
    }
    
    // MARK: - Python Highlighting
    private static func highlightPython(_ attributed: inout AttributedString, code: String) {
        let keywords = [
            "def", "class", "if", "elif", "else", "for", "while", "in", "import",
            "from", "return", "try", "except", "finally", "with", "as", "lambda",
            "pass", "break", "continue", "and", "or", "not", "is", "None", "True", "False"
        ]
        
        highlightKeywords(&attributed, code: code, keywords: keywords, color: .purple)
        highlightStrings(&attributed, code: code, color: .red)
        highlightComments(&attributed, code: code, singleLine: "#", multiLineStart: "\"\"\"", multiLineEnd: "\"\"\"", color: .green)
        highlightNumbers(&attributed, code: code, color: .blue)
    }
    
    // MARK: - JavaScript Highlighting
    private static func highlightJavaScript(_ attributed: inout AttributedString, code: String) {
        let keywords = [
            "function", "const", "let", "var", "if", "else", "for", "while", "switch",
            "case", "default", "return", "break", "continue", "class", "extends",
            "import", "export", "from", "async", "await", "try", "catch", "finally",
            "new", "this", "typeof", "instanceof", "null", "undefined", "true", "false"
        ]
        
        highlightKeywords(&attributed, code: code, keywords: keywords, color: .purple)
        highlightStrings(&attributed, code: code, color: .red)
        highlightComments(&attributed, code: code, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/", color: .green)
        highlightNumbers(&attributed, code: code, color: .blue)
    }
    
    // MARK: - Java Highlighting
    private static func highlightJava(_ attributed: inout AttributedString, code: String) {
        let keywords = [
            "public", "private", "protected", "class", "interface", "extends", "implements",
            "static", "final", "abstract", "void", "int", "double", "float", "boolean",
            "String", "if", "else", "for", "while", "switch", "case", "default",
            "return", "break", "continue", "new", "this", "super", "import", "package",
            "try", "catch", "finally", "throw", "throws", "null", "true", "false"
        ]
        
        highlightKeywords(&attributed, code: code, keywords: keywords, color: .purple)
        highlightStrings(&attributed, code: code, color: .red)
        highlightComments(&attributed, code: code, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/", color: .green)
        highlightNumbers(&attributed, code: code, color: .blue)
    }
    
    // MARK: - Apex (Salesforce) Highlighting
    private static func highlightApex(_ attributed: inout AttributedString, code: String) {
        let keywords = [
            // Access modifiers
            "public", "private", "protected", "global", "with sharing", "without sharing",
            "inherited sharing",
            // Class/Interface keywords
            "class", "interface", "extends", "implements", "virtual", "abstract",
            // Method/Variable keywords
            "static", "final", "override", "testMethod", "webService",
            // Data types
            "void", "Integer", "Long", "Double", "Decimal", "String", "Boolean",
            "Date", "DateTime", "Time", "Blob", "ID", "Object",
            // Collections
            "List", "Set", "Map",
            // Control flow
            "if", "else", "for", "while", "do", "switch", "when", "case", "default",
            "return", "break", "continue",
            // Exception handling
            "try", "catch", "finally", "throw",
            // DML keywords
            "insert", "update", "delete", "undelete", "upsert", "merge",
            // SOQL/SOSL keywords
            "SELECT", "FROM", "WHERE", "ORDER BY", "GROUP BY", "LIMIT",
            "FIND", "IN", "RETURNING",
            // Other keywords
            "new", "this", "super", "null", "true", "false",
            "trigger", "before", "after", "on"
        ]
        
        highlightKeywords(&attributed, code: code, keywords: keywords, color: .purple)
        
        // Highlight annotations (e.g., @isTest, @future)
        highlightPattern(&attributed, code: code, pattern: "@[a-zA-Z]+", color: .orange)
        
        highlightStrings(&attributed, code: code, color: .red)
        highlightComments(&attributed, code: code, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/", color: .green)
        highlightNumbers(&attributed, code: code, color: .blue)
    }
    
    // MARK: - C++ Highlighting
    private static func highlightCPP(_ attributed: inout AttributedString, code: String) {
        let keywords = [
            "int", "double", "float", "char", "bool", "void", "class", "struct",
            "public", "private", "protected", "if", "else", "for", "while", "switch",
            "case", "default", "return", "break", "continue", "const", "static",
            "virtual", "override", "namespace", "using", "include", "define", "true", "false"
        ]
        
        highlightKeywords(&attributed, code: code, keywords: keywords, color: .purple)
        highlightStrings(&attributed, code: code, color: .red)
        highlightComments(&attributed, code: code, singleLine: "//", multiLineStart: "/*", multiLineEnd: "*/", color: .green)
        highlightNumbers(&attributed, code: code, color: .blue)
    }
    
    // MARK: - HTML Highlighting
    private static func highlightHTML(_ attributed: inout AttributedString, code: String) {
        // Highlight tags
        highlightPattern(&attributed, code: code, pattern: "<[^>]+>", color: .purple)
        highlightStrings(&attributed, code: code, color: .red)
        highlightComments(&attributed, code: code, singleLine: nil, multiLineStart: "<!--", multiLineEnd: "-->", color: .green)
    }
    
    // MARK: - CSS Highlighting
    private static func highlightCSS(_ attributed: inout AttributedString, code: String) {
        let keywords = [
            "display", "position", "color", "background", "margin", "padding",
            "width", "height", "font", "border", "flex", "grid"
        ]
        
        highlightKeywords(&attributed, code: code, keywords: keywords, color: .purple)
        highlightPattern(&attributed, code: code, pattern: "\\{|\\}", color: .orange)
        highlightPattern(&attributed, code: code, pattern: "[.#][a-zA-Z][a-zA-Z0-9-_]*", color: .blue)
        highlightComments(&attributed, code: code, singleLine: nil, multiLineStart: "/*", multiLineEnd: "*/", color: .green)
    }
    
    // MARK: - Helper Methods
    private static func highlightKeywords(_ attributed: inout AttributedString, code: String, keywords: [String], color: Color) {
        for keyword in keywords {
            let pattern = "\\b\(keyword)\\b"
            highlightPattern(&attributed, code: code, pattern: pattern, color: color)
        }
    }
    
    private static func highlightStrings(_ attributed: inout AttributedString, code: String, color: Color) {
        // Double-quoted strings
        highlightPattern(&attributed, code: code, pattern: "\"[^\"]*\"", color: color)
        // Single-quoted strings
        highlightPattern(&attributed, code: code, pattern: "'[^']*'", color: color)
    }
    
    private static func highlightComments(_ attributed: inout AttributedString, code: String, singleLine: String?, multiLineStart: String?, multiLineEnd: String?, color: Color) {
        if let singleLine = singleLine {
            let pattern = "\(NSRegularExpression.escapedPattern(for: singleLine)).*$"
            highlightPattern(&attributed, code: code, pattern: pattern, color: color, multiline: true)
        }
        
        if let start = multiLineStart, let end = multiLineEnd {
            let pattern = "\(NSRegularExpression.escapedPattern(for: start)).*?\(NSRegularExpression.escapedPattern(for: end))"
            highlightPattern(&attributed, code: code, pattern: pattern, color: color, dotMatchesLineSeparators: true)
        }
    }
    
    private static func highlightNumbers(_ attributed: inout AttributedString, code: String, color: Color) {
        highlightPattern(&attributed, code: code, pattern: "\\b[0-9]+\\.?[0-9]*\\b", color: color)
    }
    
    private static func highlightPattern(_ attributed: inout AttributedString, code: String, pattern: String, color: Color, multiline: Bool = false, dotMatchesLineSeparators: Bool = false) {
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: multiline ? [.anchorsMatchLines] : (dotMatchesLineSeparators ? [.dotMatchesLineSeparators] : [])
        ) else { return }
        
        let nsString = code as NSString
        let matches = regex.matches(in: code, options: [], range: NSRange(location: 0, length: nsString.length))
        
        for match in matches {
            if let range = Range(match.range, in: code) {
                let attrRange = AttributedString.Index(range.lowerBound, within: attributed)!..<AttributedString.Index(range.upperBound, within: attributed)!
                attributed[attrRange].foregroundColor = color
            }
        }
    }
}
