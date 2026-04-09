//
//  CodeCompletionEngine.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import Foundation

struct CompletionSuggestion: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let type: CompletionType
    let description: String
    
    enum CompletionType {
        case keyword
        case function
        case variable
        case classType
        case snippet
    }
    
    var icon: String {
        switch type {
        case .keyword: return "k.square.fill"
        case .function: return "function"
        case .variable: return "v.square.fill"
        case .classType: return "c.square.fill"
        case .snippet: return "doc.text.fill"
        }
    }
}

class CodeCompletionEngine {
    
    static func getSuggestions(for text: String, language: CodeLanguage, cursorPosition: Int) -> [CompletionSuggestion] {
        // Get the current word being typed
        let currentWord = getCurrentWord(in: text, at: cursorPosition)
        
        guard !currentWord.isEmpty else { return [] }
        
        // Get language-specific suggestions
        let suggestions = getLanguageSuggestions(for: language)
        
        // Filter based on current word
        return suggestions.filter { suggestion in
            suggestion.text.lowercased().hasPrefix(currentWord.lowercased())
        }
    }
    
    private static func getCurrentWord(in text: String, at position: Int) -> String {
        let safePosition = min(position, text.count)
        let beforeCursor = String(text.prefix(safePosition))
        
        // Find the last word boundary
        let components = beforeCursor.components(separatedBy: CharacterSet.alphanumerics.inverted)
        return components.last ?? ""
    }
    
    private static func getLanguageSuggestions(for language: CodeLanguage) -> [CompletionSuggestion] {
        switch language {
        case .swift:
            return getSwiftSuggestions()
        case .python:
            return getPythonSuggestions()
        case .javascript, .typescript:
            return getJavaScriptSuggestions()
        case .java:
            return getJavaSuggestions()
        case .apex:
            return getApexSuggestions()
        case .cpp, .c, .csharp:
            return getCPPSuggestions()
        case .go, .rust:
            return getCPPSuggestions() // Similar C-style syntax
        case .ruby:
            return getPythonSuggestions() // Similar syntax
        case .php:
            return getPHPSuggestions()
        case .sql:
            return getSQLSuggestions()
        case .html, .xml:
            return getHTMLSuggestions()
        case .css:
            return getCSSSuggestions()
        case .markdown, .json, .yaml, .csv, .plaintext, .unknown:
            return [] // No code completion for markup/data formats
        }
    }
    
    // MARK: - Swift Suggestions
    private static func getSwiftSuggestions() -> [CompletionSuggestion] {
        return [
            // Keywords
            CompletionSuggestion(text: "func", type: .keyword, description: "Function declaration"),
            CompletionSuggestion(text: "var", type: .keyword, description: "Variable declaration"),
            CompletionSuggestion(text: "let", type: .keyword, description: "Constant declaration"),
            CompletionSuggestion(text: "class", type: .keyword, description: "Class declaration"),
            CompletionSuggestion(text: "struct", type: .keyword, description: "Structure declaration"),
            CompletionSuggestion(text: "enum", type: .keyword, description: "Enumeration declaration"),
            CompletionSuggestion(text: "protocol", type: .keyword, description: "Protocol declaration"),
            CompletionSuggestion(text: "extension", type: .keyword, description: "Extension declaration"),
            CompletionSuggestion(text: "import", type: .keyword, description: "Import framework"),
            CompletionSuggestion(text: "if", type: .keyword, description: "Conditional statement"),
            CompletionSuggestion(text: "else", type: .keyword, description: "Else clause"),
            CompletionSuggestion(text: "for", type: .keyword, description: "For loop"),
            CompletionSuggestion(text: "while", type: .keyword, description: "While loop"),
            CompletionSuggestion(text: "guard", type: .keyword, description: "Guard statement"),
            CompletionSuggestion(text: "return", type: .keyword, description: "Return statement"),
            CompletionSuggestion(text: "async", type: .keyword, description: "Async modifier"),
            CompletionSuggestion(text: "await", type: .keyword, description: "Await expression"),
            CompletionSuggestion(text: "actor", type: .keyword, description: "Actor declaration"),
            CompletionSuggestion(text: "init", type: .keyword, description: "Initializer"),
            
            // Common snippets
            CompletionSuggestion(text: "func name() {\n    \n}", type: .snippet, description: "Function template"),
            CompletionSuggestion(text: "if condition {\n    \n}", type: .snippet, description: "If statement"),
            CompletionSuggestion(text: "for item in collection {\n    \n}", type: .snippet, description: "For-in loop"),
            CompletionSuggestion(text: "guard let else { return }", type: .snippet, description: "Guard let statement"),
        ]
    }
    
    // MARK: - Python Suggestions
    private static func getPythonSuggestions() -> [CompletionSuggestion] {
        return [
            CompletionSuggestion(text: "def", type: .keyword, description: "Function definition"),
            CompletionSuggestion(text: "class", type: .keyword, description: "Class definition"),
            CompletionSuggestion(text: "if", type: .keyword, description: "If statement"),
            CompletionSuggestion(text: "elif", type: .keyword, description: "Else if clause"),
            CompletionSuggestion(text: "else", type: .keyword, description: "Else clause"),
            CompletionSuggestion(text: "for", type: .keyword, description: "For loop"),
            CompletionSuggestion(text: "while", type: .keyword, description: "While loop"),
            CompletionSuggestion(text: "import", type: .keyword, description: "Import module"),
            CompletionSuggestion(text: "from", type: .keyword, description: "From import"),
            CompletionSuggestion(text: "return", type: .keyword, description: "Return statement"),
            CompletionSuggestion(text: "try", type: .keyword, description: "Try block"),
            CompletionSuggestion(text: "except", type: .keyword, description: "Exception handler"),
            CompletionSuggestion(text: "lambda", type: .keyword, description: "Lambda function"),
            CompletionSuggestion(text: "print()", type: .function, description: "Print function"),
            CompletionSuggestion(text: "len()", type: .function, description: "Length function"),
            CompletionSuggestion(text: "range()", type: .function, description: "Range function"),
        ]
    }
    
    // MARK: - JavaScript Suggestions
    private static func getJavaScriptSuggestions() -> [CompletionSuggestion] {
        return [
            CompletionSuggestion(text: "function", type: .keyword, description: "Function declaration"),
            CompletionSuggestion(text: "const", type: .keyword, description: "Constant declaration"),
            CompletionSuggestion(text: "let", type: .keyword, description: "Variable declaration"),
            CompletionSuggestion(text: "var", type: .keyword, description: "Variable (legacy)"),
            CompletionSuggestion(text: "if", type: .keyword, description: "If statement"),
            CompletionSuggestion(text: "else", type: .keyword, description: "Else clause"),
            CompletionSuggestion(text: "for", type: .keyword, description: "For loop"),
            CompletionSuggestion(text: "while", type: .keyword, description: "While loop"),
            CompletionSuggestion(text: "return", type: .keyword, description: "Return statement"),
            CompletionSuggestion(text: "async", type: .keyword, description: "Async function"),
            CompletionSuggestion(text: "await", type: .keyword, description: "Await expression"),
            CompletionSuggestion(text: "class", type: .keyword, description: "Class declaration"),
            CompletionSuggestion(text: "import", type: .keyword, description: "Import statement"),
            CompletionSuggestion(text: "export", type: .keyword, description: "Export statement"),
            CompletionSuggestion(text: "console.log()", type: .function, description: "Console logging"),
            CompletionSuggestion(text: "document.getElementById()", type: .function, description: "Get element by ID"),
        ]
    }
    
    // MARK: - Java Suggestions
    private static func getJavaSuggestions() -> [CompletionSuggestion] {
        return [
            CompletionSuggestion(text: "public", type: .keyword, description: "Public modifier"),
            CompletionSuggestion(text: "private", type: .keyword, description: "Private modifier"),
            CompletionSuggestion(text: "protected", type: .keyword, description: "Protected modifier"),
            CompletionSuggestion(text: "class", type: .keyword, description: "Class declaration"),
            CompletionSuggestion(text: "interface", type: .keyword, description: "Interface declaration"),
            CompletionSuggestion(text: "static", type: .keyword, description: "Static modifier"),
            CompletionSuggestion(text: "void", type: .keyword, description: "Void return type"),
            CompletionSuggestion(text: "int", type: .keyword, description: "Integer type"),
            CompletionSuggestion(text: "String", type: .classType, description: "String class"),
            CompletionSuggestion(text: "if", type: .keyword, description: "If statement"),
            CompletionSuggestion(text: "else", type: .keyword, description: "Else clause"),
            CompletionSuggestion(text: "for", type: .keyword, description: "For loop"),
            CompletionSuggestion(text: "while", type: .keyword, description: "While loop"),
            CompletionSuggestion(text: "return", type: .keyword, description: "Return statement"),
            CompletionSuggestion(text: "System.out.println()", type: .function, description: "Print line"),
        ]
    }
    
    // MARK: - Apex (Salesforce) Suggestions
    private static func getApexSuggestions() -> [CompletionSuggestion] {
        return [
            // Access modifiers
            CompletionSuggestion(text: "public", type: .keyword, description: "Public access modifier"),
            CompletionSuggestion(text: "private", type: .keyword, description: "Private access modifier"),
            CompletionSuggestion(text: "protected", type: .keyword, description: "Protected access modifier"),
            CompletionSuggestion(text: "global", type: .keyword, description: "Global access modifier"),
            CompletionSuggestion(text: "with sharing", type: .keyword, description: "With sharing class"),
            CompletionSuggestion(text: "without sharing", type: .keyword, description: "Without sharing class"),
            
            // Class keywords
            CompletionSuggestion(text: "class", type: .keyword, description: "Class declaration"),
            CompletionSuggestion(text: "interface", type: .keyword, description: "Interface declaration"),
            CompletionSuggestion(text: "extends", type: .keyword, description: "Class inheritance"),
            CompletionSuggestion(text: "implements", type: .keyword, description: "Interface implementation"),
            CompletionSuggestion(text: "virtual", type: .keyword, description: "Virtual method"),
            CompletionSuggestion(text: "abstract", type: .keyword, description: "Abstract class/method"),
            CompletionSuggestion(text: "override", type: .keyword, description: "Override method"),
            
            // Data types
            CompletionSuggestion(text: "Integer", type: .classType, description: "Integer type"),
            CompletionSuggestion(text: "String", type: .classType, description: "String type"),
            CompletionSuggestion(text: "Boolean", type: .classType, description: "Boolean type"),
            CompletionSuggestion(text: "Decimal", type: .classType, description: "Decimal type"),
            CompletionSuggestion(text: "Date", type: .classType, description: "Date type"),
            CompletionSuggestion(text: "DateTime", type: .classType, description: "DateTime type"),
            CompletionSuggestion(text: "List", type: .classType, description: "List collection"),
            CompletionSuggestion(text: "Set", type: .classType, description: "Set collection"),
            CompletionSuggestion(text: "Map", type: .classType, description: "Map collection"),
            
            // Control flow
            CompletionSuggestion(text: "if", type: .keyword, description: "If statement"),
            CompletionSuggestion(text: "else", type: .keyword, description: "Else clause"),
            CompletionSuggestion(text: "for", type: .keyword, description: "For loop"),
            CompletionSuggestion(text: "while", type: .keyword, description: "While loop"),
            CompletionSuggestion(text: "return", type: .keyword, description: "Return statement"),
            
            // DML operations
            CompletionSuggestion(text: "insert", type: .keyword, description: "Insert DML operation"),
            CompletionSuggestion(text: "update", type: .keyword, description: "Update DML operation"),
            CompletionSuggestion(text: "delete", type: .keyword, description: "Delete DML operation"),
            CompletionSuggestion(text: "upsert", type: .keyword, description: "Upsert DML operation"),
            
            // SOQL
            CompletionSuggestion(text: "SELECT", type: .keyword, description: "SOQL SELECT"),
            CompletionSuggestion(text: "FROM", type: .keyword, description: "SOQL FROM"),
            CompletionSuggestion(text: "WHERE", type: .keyword, description: "SOQL WHERE"),
            
            // Common methods
            CompletionSuggestion(text: "System.debug()", type: .function, description: "Debug logging"),
            CompletionSuggestion(text: "Database.insert()", type: .function, description: "Database insert"),
            CompletionSuggestion(text: "Database.update()", type: .function, description: "Database update"),
            
            // Annotations
            CompletionSuggestion(text: "@isTest", type: .keyword, description: "Test class annotation"),
            CompletionSuggestion(text: "@future", type: .keyword, description: "Future method annotation"),
            CompletionSuggestion(text: "@AuraEnabled", type: .keyword, description: "Aura/LWC enabled"),
            CompletionSuggestion(text: "@InvocableMethod", type: .keyword, description: "Flow invocable method"),
            
            // Trigger keywords
            CompletionSuggestion(text: "trigger", type: .keyword, description: "Trigger declaration"),
            CompletionSuggestion(text: "before insert", type: .snippet, description: "Before insert trigger"),
            CompletionSuggestion(text: "after insert", type: .snippet, description: "After insert trigger"),
            CompletionSuggestion(text: "before update", type: .snippet, description: "Before update trigger"),
            CompletionSuggestion(text: "after update", type: .snippet, description: "After update trigger"),
        ]
    }
    
    // MARK: - C++ Suggestions
    private static func getCPPSuggestions() -> [CompletionSuggestion] {
        return [
            CompletionSuggestion(text: "int", type: .keyword, description: "Integer type"),
            CompletionSuggestion(text: "double", type: .keyword, description: "Double type"),
            CompletionSuggestion(text: "float", type: .keyword, description: "Float type"),
            CompletionSuggestion(text: "char", type: .keyword, description: "Character type"),
            CompletionSuggestion(text: "bool", type: .keyword, description: "Boolean type"),
            CompletionSuggestion(text: "void", type: .keyword, description: "Void return type"),
            CompletionSuggestion(text: "class", type: .keyword, description: "Class declaration"),
            CompletionSuggestion(text: "struct", type: .keyword, description: "Struct declaration"),
            CompletionSuggestion(text: "if", type: .keyword, description: "If statement"),
            CompletionSuggestion(text: "else", type: .keyword, description: "Else clause"),
            CompletionSuggestion(text: "for", type: .keyword, description: "For loop"),
            CompletionSuggestion(text: "while", type: .keyword, description: "While loop"),
            CompletionSuggestion(text: "return", type: .keyword, description: "Return statement"),
            CompletionSuggestion(text: "std::cout", type: .function, description: "Console output"),
            CompletionSuggestion(text: "std::vector", type: .classType, description: "Vector container"),
        ]
    }
    
    // MARK: - HTML Suggestions
    private static func getHTMLSuggestions() -> [CompletionSuggestion] {
        return [
            CompletionSuggestion(text: "<div>", type: .keyword, description: "Division element"),
            CompletionSuggestion(text: "<span>", type: .keyword, description: "Span element"),
            CompletionSuggestion(text: "<p>", type: .keyword, description: "Paragraph element"),
            CompletionSuggestion(text: "<a>", type: .keyword, description: "Anchor element"),
            CompletionSuggestion(text: "<img>", type: .keyword, description: "Image element"),
            CompletionSuggestion(text: "<h1>", type: .keyword, description: "Heading 1"),
            CompletionSuggestion(text: "<ul>", type: .keyword, description: "Unordered list"),
            CompletionSuggestion(text: "<li>", type: .keyword, description: "List item"),
            CompletionSuggestion(text: "<table>", type: .keyword, description: "Table element"),
            CompletionSuggestion(text: "<form>", type: .keyword, description: "Form element"),
        ]
    }
    
    // MARK: - CSS Suggestions
    private static func getCSSSuggestions() -> [CompletionSuggestion] {
        return [
            CompletionSuggestion(text: "display", type: .keyword, description: "Display property"),
            CompletionSuggestion(text: "position", type: .keyword, description: "Position property"),
            CompletionSuggestion(text: "color", type: .keyword, description: "Text color"),
            CompletionSuggestion(text: "background", type: .keyword, description: "Background property"),
            CompletionSuggestion(text: "margin", type: .keyword, description: "Margin property"),
            CompletionSuggestion(text: "padding", type: .keyword, description: "Padding property"),
            CompletionSuggestion(text: "width", type: .keyword, description: "Width property"),
            CompletionSuggestion(text: "height", type: .keyword, description: "Height property"),
            CompletionSuggestion(text: "font-size", type: .keyword, description: "Font size"),
            CompletionSuggestion(text: "border", type: .keyword, description: "Border property"),
            CompletionSuggestion(text: "flex", type: .keyword, description: "Flexbox property"),
            CompletionSuggestion(text: "grid", type: .keyword, description: "Grid property"),
        ]
    }
    
    // MARK: - PHP Suggestions
    private static func getPHPSuggestions() -> [CompletionSuggestion] {
        return [
            CompletionSuggestion(text: "function", type: .keyword, description: "Function declaration"),
            CompletionSuggestion(text: "class", type: .keyword, description: "Class declaration"),
            CompletionSuggestion(text: "public", type: .keyword, description: "Public access modifier"),
            CompletionSuggestion(text: "private", type: .keyword, description: "Private access modifier"),
            CompletionSuggestion(text: "protected", type: .keyword, description: "Protected access modifier"),
            CompletionSuggestion(text: "if", type: .keyword, description: "Conditional statement"),
            CompletionSuggestion(text: "else", type: .keyword, description: "Else clause"),
            CompletionSuggestion(text: "foreach", type: .keyword, description: "Foreach loop"),
            CompletionSuggestion(text: "echo", type: .keyword, description: "Output statement"),
            CompletionSuggestion(text: "return", type: .keyword, description: "Return statement"),
            CompletionSuggestion(text: "new", type: .keyword, description: "Object instantiation"),
            CompletionSuggestion(text: "extends", type: .keyword, description: "Class inheritance"),
            CompletionSuggestion(text: "namespace", type: .keyword, description: "Namespace declaration"),
            CompletionSuggestion(text: "use", type: .keyword, description: "Import statement"),
        ]
    }
    
    // MARK: - SQL Suggestions
    private static func getSQLSuggestions() -> [CompletionSuggestion] {
        return [
            CompletionSuggestion(text: "SELECT", type: .keyword, description: "Select data"),
            CompletionSuggestion(text: "FROM", type: .keyword, description: "Table source"),
            CompletionSuggestion(text: "WHERE", type: .keyword, description: "Filter condition"),
            CompletionSuggestion(text: "INSERT INTO", type: .keyword, description: "Insert data"),
            CompletionSuggestion(text: "UPDATE", type: .keyword, description: "Update data"),
            CompletionSuggestion(text: "DELETE FROM", type: .keyword, description: "Delete data"),
            CompletionSuggestion(text: "CREATE TABLE", type: .keyword, description: "Create table"),
            CompletionSuggestion(text: "ALTER TABLE", type: .keyword, description: "Alter table"),
            CompletionSuggestion(text: "DROP TABLE", type: .keyword, description: "Drop table"),
            CompletionSuggestion(text: "JOIN", type: .keyword, description: "Join tables"),
            CompletionSuggestion(text: "LEFT JOIN", type: .keyword, description: "Left outer join"),
            CompletionSuggestion(text: "INNER JOIN", type: .keyword, description: "Inner join"),
            CompletionSuggestion(text: "ORDER BY", type: .keyword, description: "Sort results"),
            CompletionSuggestion(text: "GROUP BY", type: .keyword, description: "Group results"),
            CompletionSuggestion(text: "LIMIT", type: .keyword, description: "Limit results"),
        ]
    }
}

