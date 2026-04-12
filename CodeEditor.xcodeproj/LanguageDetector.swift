//
//  LanguageDetector.swift
//  CodeEditor
//
//  Created by J Bretcher on 4/10/26.
//

import Foundation

/// Advanced language detection using scoring algorithm
struct LanguageDetector {
    
    /// Detect language from content using scoring system
    /// Returns the language with the highest confidence score
    static func detectLanguage(fromContent content: String) -> CodeLanguage? {
        // Skip if content is too short or empty
        guard content.count > 3 else { return nil }
        
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let lines = trimmed.components(separatedBy: .newlines)
        let firstLine = lines.first ?? ""
        let lowercased = trimmed.lowercased()
        
        // Score each language
        var scores: [CodeLanguage: Int] = [:]
        
        scores[.html] = scoreHTML(trimmed: trimmed, firstLine: firstLine, lowercased: lowercased)
        scores[.xml] = scoreXML(trimmed: trimmed)
        scores[.json] = scoreJSON(trimmed: trimmed)
        scores[.csharp] = scoreCSharp(trimmed: trimmed, lines: lines)
        scores[.java] = scoreJava(trimmed: trimmed, firstLine: firstLine)
        scores[.swift] = scoreSwift(trimmed: trimmed, firstLine: firstLine)
        scores[.python] = scorePython(trimmed: trimmed, firstLine: firstLine, lines: lines)
        scores[.javascript] = scoreJavaScript(trimmed: trimmed, lowercased: lowercased)
        scores[.typescript] = scoreTypeScript(trimmed: trimmed, lowercased: lowercased)
        scores[.apex] = scoreApex(trimmed: trimmed)
        scores[.cpp] = scoreCPP(trimmed: trimmed)
        scores[.c] = scoreC(trimmed: trimmed)
        scores[.go] = scoreGo(trimmed: trimmed, firstLine: firstLine)
        scores[.rust] = scoreRust(trimmed: trimmed)
        scores[.ruby] = scoreRuby(trimmed: trimmed, firstLine: firstLine)
        scores[.php] = scorePHP(trimmed: trimmed)
        scores[.sql] = scoreSQL(firstLine: firstLine, trimmed: trimmed)
        scores[.css] = scoreCSS(trimmed: trimmed)
        scores[.yaml] = scoreYAML(trimmed: trimmed, lines: lines, firstLine: firstLine)
        scores[.markdown] = scoreMarkdown(trimmed: trimmed, lines: lines, firstLine: firstLine)
        scores[.csv] = scoreCSV(lines: lines, firstLine: firstLine)
        
        // Filter out languages with score 0 and sort by score
        let validScores = scores.filter { $0.value > 0 }.sorted { $0.value > $1.value }
        
        // Require minimum score of 10 for confidence
        guard let best = validScores.first, best.value >= 10 else {
            return nil
        }
        
        // Log top 3 scores for debugging
        let topScores = validScores.prefix(3).map { "\($0.key.rawValue): \($0.value)" }.joined(separator: ", ")
        print("🎯 Language detection scores: \(topScores)")
        
        return best.key
    }
    
    // MARK: - HTML Detection
    
    private static func scoreHTML(trimmed: String, firstLine: String, lowercased: String) -> Int {
        var score = 0
        
        // DOCTYPE is definitive
        if lowercased.hasPrefix("<!doctype html") { score += 100 }
        
        // HTML tag at start
        if trimmed.hasPrefix("<html") || lowercased.hasPrefix("<html") { score += 90 }
        
        // Common HTML structure
        if lowercased.contains("<head>") { score += 25 }
        if lowercased.contains("<body>") { score += 25 }
        if lowercased.contains("</html>") { score += 20 }
        
        // Common HTML tags
        if lowercased.contains("<div") { score += 15 }
        if lowercased.contains("<p>") { score += 10 }
        if lowercased.contains("<span") { score += 10 }
        if lowercased.contains("<a ") || lowercased.contains("<a>") { score += 10 }
        if lowercased.contains("<script") { score += 15 }
        if lowercased.contains("<style") { score += 15 }
        
        return score
    }
    
    // MARK: - XML Detection
    
    private static func scoreXML(trimmed: String) -> Int {
        var score = 0
        
        // XML declaration
        if trimmed.hasPrefix("<?xml") { score += 100 }
        
        // Plist specific
        if trimmed.contains("<plist") { score += 40 }
        
        // XML-like structure
        if trimmed.contains("</") && trimmed.contains("/>") { score += 20 }
        
        // XML attributes
        if trimmed.contains("xmlns") { score += 25 }
        
        return score
    }
    
    // MARK: - JSON Detection
    
    private static func scoreJSON(trimmed: String) -> Int {
        var score = 0
        
        // Try to parse as JSON
        if (trimmed.hasPrefix("{") && trimmed.hasSuffix("}")) ||
           (trimmed.hasPrefix("[") && trimmed.hasSuffix("]")) {
            if let _ = try? JSONSerialization.jsonObject(with: Data(trimmed.utf8)) {
                score += 100 // Valid JSON
            } else {
                score += 40 // Looks like JSON but might be incomplete
            }
        }
        
        // JSON patterns
        if trimmed.contains("\":") { score += 20 }
        if trimmed.contains("{\"") { score += 15 }
        
        return score
    }
    
    // MARK: - C# Detection
    
    private static func scoreCSharp(trimmed: String, lines: [Substring]) -> Int {
        var score = 0
        
        // Definitive C# markers
        if trimmed.contains("using System") { score += 60 }
        if trimmed.contains("using System.") { score += 40 }
        
        // C# property syntax (very specific)
        if trimmed.contains("{ get; set; }") { score += 70 }
        if trimmed.contains("{ get; }") { score += 50 }
        
        // Namespace + class combination
        if trimmed.contains("namespace ") && trimmed.contains("class ") { score += 45 }
        
        // C# specific keywords
        if trimmed.contains("public class ") { score += 25 }
        if trimmed.contains("private class ") { score += 25 }
        if trimmed.contains("async Task") { score += 35 }
        if trimmed.contains("await ") { score += 15 }
        
        // C# operators
        if trimmed.contains("?.") { score += 20 } // Null conditional
        if trimmed.contains("??") { score += 15 } // Null coalescing
        
        // LINQ
        if trimmed.contains(" from ") && trimmed.contains(" select ") { score += 30 }
        if trimmed.contains(".Where(") || trimmed.contains(".Select(") { score += 25 }
        
        // C# attributes
        if trimmed.contains("[") && trimmed.contains("]") && !trimmed.hasPrefix("[") { score += 10 }
        
        return score
    }
    
    // MARK: - Java Detection
    
    private static func scoreJava(trimmed: String, firstLine: String) -> Int {
        var score = 0
        
        // Package declaration
        if firstLine.hasPrefix("package ") { score += 60 }
        
        // Java imports
        if firstLine.hasPrefix("import java.") { score += 60 }
        if trimmed.contains("import java.") { score += 40 }
        if trimmed.contains("import javax.") { score += 40 }
        
        // Main method
        if trimmed.contains("public static void main") { score += 70 }
        
        // Java-specific methods
        if trimmed.contains("System.out.println") { score += 40 }
        if trimmed.contains("System.out.print") { score += 35 }
        
        // Java keywords
        if trimmed.contains("@Override") { score += 30 }
        if trimmed.contains(" extends ") { score += 20 }
        if trimmed.contains(" implements ") { score += 20 }
        if trimmed.contains("public class ") { score += 25 }
        
        // Java annotations
        if trimmed.contains("@SuppressWarnings") || trimmed.contains("@Deprecated") { score += 25 }
        
        return score
    }
    
    // MARK: - Swift Detection
    
    private static func scoreSwift(trimmed: String, firstLine: String) -> Int {
        var score = 0
        
        // Swift imports
        if trimmed.contains("import Swift") { score += 60 }
        if trimmed.contains("import Foundation") { score += 60 }
        if trimmed.contains("import UIKit") { score += 60 }
        if trimmed.contains("import SwiftUI") { score += 60 }
        if trimmed.contains("import AppKit") { score += 60 }
        if trimmed.contains("import Cocoa") { score += 60 }
        
        // Swift keywords
        if trimmed.contains("func ") { score += 20 }
        if trimmed.contains("struct ") { score += 20 }
        if trimmed.contains("enum ") { score += 20 }
        if trimmed.contains("protocol ") { score += 25 }
        if trimmed.contains("extension ") { score += 25 }
        
        // Swift type annotations
        if trimmed.contains("var ") && trimmed.contains(": String") { score += 15 }
        if trimmed.contains("let ") && trimmed.contains(": ") { score += 15 }
        
        // Swift operators
        if trimmed.contains(" -> ") { score += 25 }
        if trimmed.contains("guard ") { score += 30 }
        
        // SwiftUI property wrappers
        if trimmed.contains("@State") { score += 35 }
        if trimmed.contains("@Published") { score += 35 }
        if trimmed.contains("@ObservedObject") { score += 35 }
        if trimmed.contains("@Environment") { score += 35 }
        
        // Swift optionals
        if trimmed.contains("?") && trimmed.contains(": ") { score += 10 }
        if trimmed.contains("if let ") || trimmed.contains("guard let ") { score += 25 }
        
        return score
    }
    
    // MARK: - Python Detection
    
    private static func scorePython(trimmed: String, firstLine: String, lines: [Substring]) -> Int {
        var score = 0
        
        // Python imports
        if firstLine.hasPrefix("import ") && !trimmed.contains("java.") && !trimmed.contains("System") {
            score += 40
        }
        if firstLine.hasPrefix("from ") && trimmed.contains(" import ") { score += 50 }
        
        // Python function definition
        if trimmed.contains("def ") && trimmed.contains("):") { score += 45 }
        if trimmed.contains("def ") && trimmed.contains(":\n") { score += 40 }
        
        // Python class definition (colon at end of line, no braces)
        if trimmed.contains("class ") && trimmed.contains(":\n") && !trimmed.contains("{") {
            score += 40
        }
        
        // Python-specific keywords
        if trimmed.contains("self.") { score += 30 }
        if trimmed.contains("__init__") { score += 50 }
        if trimmed.contains("__main__") { score += 45 }
        if trimmed.contains("elif ") { score += 35 }
        
        // Python built-ins
        if trimmed.contains("print(") { score += 20 }
        if trimmed.contains("len(") { score += 15 }
        if trimmed.contains("range(") { score += 15 }
        
        // Python decorators
        if trimmed.contains("@") && lines.contains(where: { $0.hasPrefix("@") }) { score += 25 }
        
        // Penalize if has characteristics not in Python
        if trimmed.contains("{") && trimmed.contains("}") { score -= 40 }
        if trimmed.contains(";") && !trimmed.contains("print") { score -= 30 }
        if trimmed.contains("using ") || trimmed.contains("package ") { score -= 50 }
        
        return max(score, 0)
    }
    
    // MARK: - JavaScript Detection
    
    private static func scoreJavaScript(trimmed: String, lowercased: String) -> Int {
        var score = 0
        
        // Variable declarations
        if trimmed.contains("const ") { score += 30 }
        if trimmed.contains("let ") { score += 25 }
        if trimmed.contains("var ") { score += 20 }
        
        // Functions
        if trimmed.contains("function ") { score += 30 }
        if trimmed.contains("=>") { score += 25 }
        
        // Browser APIs
        if lowercased.contains("console.log") { score += 40 }
        if lowercased.contains("document.") { score += 35 }
        if lowercased.contains("window.") { score += 30 }
        
        // Node.js
        if trimmed.contains("require(") { score += 30 }
        if trimmed.contains("module.exports") { score += 35 }
        if trimmed.contains("exports.") { score += 25 }
        
        // Common JS methods
        if trimmed.contains(".forEach") || trimmed.contains(".map(") { score += 15 }
        if trimmed.contains(".filter(") || trimmed.contains(".reduce(") { score += 15 }
        
        // Penalize if TypeScript features present
        if trimmed.contains(": string") || trimmed.contains(": number") { score -= 30 }
        if trimmed.contains("interface ") || trimmed.contains("type ") { score -= 40 }
        
        return max(score, 0)
    }
    
    // MARK: - TypeScript Detection
    
    private static func scoreTypeScript(trimmed: String, lowercased: String) -> Int {
        // Start with JavaScript score
        var score = scoreJavaScript(trimmed: trimmed, lowercased: lowercased)
        
        // Remove the TypeScript penalty from JS
        if trimmed.contains(": string") || trimmed.contains(": number") {
            score += 30 // Add back what was removed
        }
        if trimmed.contains("interface ") || trimmed.contains("type ") {
            score += 40 // Add back what was removed
        }
        
        // TypeScript type annotations
        if trimmed.contains(": string") { score += 40 }
        if trimmed.contains(": number") { score += 40 }
        if trimmed.contains(": boolean") { score += 40 }
        if trimmed.contains(": void") { score += 30 }
        if trimmed.contains(": any") { score += 25 }
        
        // TypeScript-specific keywords
        if trimmed.contains("interface ") { score += 50 }
        if trimmed.contains("type ") && trimmed.contains(" = ") { score += 45 }
        if trimmed.contains("enum ") { score += 40 }
        
        // Generics
        if trimmed.contains("<T>") || trimmed.contains("<T,") { score += 35 }
        
        // Access modifiers
        if trimmed.contains("public ") || trimmed.contains("private ") || trimmed.contains("protected ") {
            score += 30
        }
        
        // Decorators
        if trimmed.contains("@Component") || trimmed.contains("@Injectable") { score += 40 }
        
        return score
    }
    
    // MARK: - Apex (Salesforce) Detection
    
    private static func scoreApex(trimmed: String) -> Int {
        var score = 0
        
        // Apex-specific annotations
        if trimmed.contains("@isTest") { score += 60 }
        if trimmed.contains("@AuraEnabled") { score += 60 }
        if trimmed.contains("@future") { score += 50 }
        
        // Trigger syntax
        if trimmed.contains("trigger ") && trimmed.contains(" on ") { score += 70 }
        
        // SOQL
        if trimmed.contains("SELECT") && trimmed.contains("FROM") && trimmed.contains("[") { score += 50 }
        
        // Apex-specific classes
        if trimmed.contains("Database.") { score += 40 }
        if trimmed.contains("System.debug") { score += 45 }
        if trimmed.contains("Test.startTest") { score += 50 }
        
        // Sharing keywords
        if trimmed.contains("with sharing") || trimmed.contains("without sharing") { score += 50 }
        
        return score
    }
    
    // MARK: - C++ Detection
    
    private static func scoreCPP(trimmed: String) -> Int {
        var score = 0
        
        // C++ headers
        if trimmed.contains("#include <iostream>") { score += 70 }
        if trimmed.contains("#include <vector>") { score += 60 }
        if trimmed.contains("#include <string>") { score += 60 }
        
        // C++ namespace
        if trimmed.contains("std::") { score += 50 }
        if trimmed.contains("using namespace std") { score += 55 }
        if trimmed.contains("namespace ") && !trimmed.contains("using System") { score += 35 }
        
        // C++ I/O
        if trimmed.contains("cout") { score += 40 }
        if trimmed.contains("cin") { score += 40 }
        if trimmed.contains("endl") { score += 30 }
        
        // C++ specific
        if trimmed.contains("::") { score += 25 }
        if trimmed.contains("template<") { score += 45 }
        if trimmed.contains("public:") || trimmed.contains("private:") { score += 30 }
        
        return score
    }
    
    // MARK: - C Detection
    
    private static func scoreC(trimmed: String) -> Int {
        var score = 0
        
        // C headers
        if trimmed.contains("#include <stdio.h>") { score += 70 }
        if trimmed.contains("#include <stdlib.h>") { score += 60 }
        if trimmed.contains("#include <string.h>") { score += 50 }
        
        // C functions
        if trimmed.contains("printf(") { score += 45 }
        if trimmed.contains("scanf(") { score += 40 }
        if trimmed.contains("malloc(") { score += 40 }
        if trimmed.contains("free(") { score += 35 }
        
        // C specific
        if trimmed.contains("sizeof(") { score += 25 }
        if trimmed.contains("struct ") && !trimmed.contains("import") { score += 30 }
        
        // Penalize C++ features
        if trimmed.contains("std::") || trimmed.contains("cout") { score -= 50 }
        
        return max(score, 0)
    }
    
    // MARK: - Go Detection
    
    private static func scoreGo(trimmed: String, firstLine: String) -> Int {
        var score = 0
        
        // Package declaration
        if firstLine.hasPrefix("package ") && !trimmed.contains("java") { score += 60 }
        
        // Main function
        if trimmed.contains("func main()") && !trimmed.contains("static void") { score += 60 }
        
        // Imports
        if trimmed.contains("import (") { score += 40 }
        if trimmed.contains("import \"") { score += 30 }
        
        // Go-specific functions
        if trimmed.contains("fmt.Println") { score += 50 }
        if trimmed.contains("fmt.Printf") { score += 45 }
        
        // Go keywords
        if trimmed.contains(":=") { score += 35 }
        if trimmed.contains("go func") { score += 40 }
        if trimmed.contains("defer ") { score += 35 }
        if trimmed.contains("goroutine") { score += 40 }
        if trimmed.contains("chan ") { score += 40 }
        
        return score
    }
    
    // MARK: - Rust Detection
    
    private static func scoreRust(trimmed: String) -> Int {
        var score = 0
        
        // Main function
        if trimmed.contains("fn main()") { score += 70 }
        
        // Use statements
        if trimmed.contains("use std::") { score += 50 }
        
        // Rust-specific keywords
        if trimmed.contains("let mut ") { score += 40 }
        if trimmed.contains("pub fn ") { score += 35 }
        
        // Macros
        if trimmed.contains("println!") { score += 50 }
        if trimmed.contains("vec!") { score += 40 }
        
        // Rust keywords
        if trimmed.contains("impl ") { score += 35 }
        if trimmed.contains("trait ") { score += 35 }
        if trimmed.contains(" -> ") && trimmed.contains("fn ") { score += 30 }
        
        // Ownership
        if trimmed.contains("&mut ") || trimmed.contains("&self") { score += 25 }
        
        return score
    }
    
    // MARK: - Ruby Detection
    
    private static func scoreRuby(trimmed: String, firstLine: String) -> Int {
        var score = 0
        
        // Require statements
        if firstLine.hasPrefix("require ") { score += 50 }
        
        // Ruby methods
        if trimmed.contains("def ") && trimmed.contains("end") { score += 50 }
        
        // Ruby output
        if trimmed.contains("puts ") { score += 35 }
        if trimmed.contains("print ") { score += 25 }
        
        // Ruby class
        if trimmed.contains("class ") && trimmed.contains("end") { score += 40 }
        
        // Ruby blocks
        if trimmed.contains(".each do") { score += 40 }
        if trimmed.contains(".map ") { score += 25 }
        
        // Ruby symbols
        if trimmed.contains(":") && trimmed.contains("=>") { score += 30 }
        
        return score
    }
    
    // MARK: - PHP Detection
    
    private static func scorePHP(trimmed: String) -> Int {
        var score = 0
        
        // PHP tag
        if trimmed.hasPrefix("<?php") { score += 100 }
        if trimmed.contains("<?php") { score += 80 }
        
        // PHP output
        if trimmed.contains("echo ") { score += 30 }
        
        // PHP variables
        if trimmed.contains("$_") { score += 40 }
        if trimmed.contains("$") && trimmed.contains("function ") { score += 30 }
        
        // PHP functions
        if trimmed.contains("function ") && trimmed.contains("$") { score += 25 }
        
        return score
    }
    
    // MARK: - SQL Detection
    
    private static func scoreSQL(firstLine: String, trimmed: String) -> Int {
        var score = 0
        let upperFirst = firstLine.uppercased()
        let upperTrimmed = trimmed.uppercased()
        
        // SQL keywords at start
        if upperFirst.hasPrefix("SELECT ") { score += 70 }
        if upperFirst.hasPrefix("CREATE TABLE") || upperFirst.hasPrefix("CREATE DATABASE") { score += 70 }
        if upperFirst.hasPrefix("INSERT INTO") { score += 70 }
        if upperFirst.hasPrefix("UPDATE ") { score += 60 }
        if upperFirst.hasPrefix("DELETE FROM") { score += 60 }
        if upperFirst.hasPrefix("ALTER TABLE") { score += 60 }
        
        // SQL clauses
        if upperTrimmed.contains(" FROM ") { score += 25 }
        if upperTrimmed.contains(" WHERE ") { score += 25 }
        if upperTrimmed.contains(" JOIN ") { score += 30 }
        if upperTrimmed.contains(" GROUP BY ") { score += 30 }
        if upperTrimmed.contains(" ORDER BY ") { score += 25 }
        
        return score
    }
    
    // MARK: - CSS Detection
    
    private static func scoreCSS(trimmed: String) -> Int {
        var score = 0
        
        if trimmed.contains("{") && trimmed.contains("}") && trimmed.contains(":") && trimmed.contains(";") {
            // CSS properties
            if trimmed.contains("color:") { score += 30 }
            if trimmed.contains("background") { score += 25 }
            if trimmed.contains("font-") { score += 25 }
            if trimmed.contains("margin") || trimmed.contains("padding") { score += 20 }
            if trimmed.contains("display:") { score += 20 }
            if trimmed.contains("position:") { score += 20 }
            if trimmed.contains("width:") || trimmed.contains("height:") { score += 15 }
            
            // CSS selectors
            if trimmed.contains("#") && trimmed.contains("{") { score += 15 }
            if trimmed.contains(".") && trimmed.contains("{") { score += 15 }
            
            // CSS at-rules
            if trimmed.contains("@media") { score += 30 }
            if trimmed.contains("@import") { score += 25 }
        }
        
        return score
    }
    
    // MARK: - YAML Detection
    
    private static func scoreYAML(trimmed: String, lines: [Substring], firstLine: String) -> Int {
        var score = 0
        
        // YAML document separator
        if trimmed.hasPrefix("---") {
            score += 50
            // Check for YAML key-value pairs
            if lines.dropFirst().contains(where: { $0.contains(": ") && !$0.hasPrefix("#") }) {
                score += 40
            }
        }
        
        // YAML structure (indentation + key: value)
        if trimmed.contains(": ") && !trimmed.contains("{") && !trimmed.contains(";") {
            score += 20
        }
        
        // YAML arrays
        if lines.contains(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("- ") }) {
            score += 25
        }
        
        return score
    }
    
    // MARK: - Markdown Detection
    
    private static func scoreMarkdown(trimmed: String, lines: [Substring], firstLine: String) -> Int {
        var score = 0
        
        // Headers
        if firstLine.hasPrefix("# ") { score += 50 }
        if firstLine.hasPrefix("## ") { score += 45 }
        if firstLine.hasPrefix("### ") { score += 40 }
        
        // Lists
        if lines.contains(where: { $0.hasPrefix("- ") || $0.hasPrefix("* ") || $0.hasPrefix("+ ") }) {
            score += 35
        }
        
        // Code blocks
        if trimmed.contains("```") { score += 40 }
        if trimmed.contains("~~~") { score += 35 }
        
        // Links
        if trimmed.contains("[") && trimmed.contains("](") { score += 30 }
        
        // Emphasis
        if trimmed.contains("**") || trimmed.contains("__") { score += 15 }
        if trimmed.contains("*") || trimmed.contains("_") { score += 10 }
        
        // Images
        if trimmed.contains("![") { score += 25 }
        
        return score
    }
    
    // MARK: - CSV Detection
    
    private static func scoreCSV(lines: [Substring], firstLine: String) -> Int {
        var score = 0
        
        guard lines.count >= 2 else { return 0 }
        
        let firstLineCommas = firstLine.filter { $0 == "," }.count
        
        guard firstLineCommas > 0 else { return 0 }
        
        // Check consistency across multiple lines
        let consistentCommas = lines.prefix(min(10, lines.count)).allSatisfy { line in
            let commaCount = line.filter { $0 == "," }.count
            return commaCount == firstLineCommas || line.isEmpty
        }
        
        if consistentCommas && firstLineCommas >= 1 {
            score += 60
            score += firstLineCommas * 5 // More columns = higher confidence
        }
        
        return score
    }
}
