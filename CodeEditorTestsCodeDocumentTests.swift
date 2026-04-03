//
//  CodeDocumentTests.swift
//  CodeEditorTests
//
//  Created by J Bretcher on 4/3/26.
//

import Testing
import Foundation
@testable import CodeEditor

@Suite("Code Document Tests")
struct CodeDocumentTests {
    
    @Test("Create new document")
    func createNewDocument() async throws {
        let doc = CodeDocument(filename: "test.swift", content: "// Test", language: .swift)
        
        #expect(doc.filename == "test.swift")
        #expect(doc.content == "// Test")
        #expect(doc.language == .swift)
        #expect(doc.isModified == false)
    }
    
    @Test("Language detection from filename")
    func languageDetection() async throws {
        #expect(CodeLanguage.detectLanguage(from: "file.swift") == .swift)
        #expect(CodeLanguage.detectLanguage(from: "file.py") == .python)
        #expect(CodeLanguage.detectLanguage(from: "file.js") == .javascript)
        #expect(CodeLanguage.detectLanguage(from: "file.java") == .java)
        #expect(CodeLanguage.detectLanguage(from: "file.cpp") == .cpp)
        #expect(CodeLanguage.detectLanguage(from: "file.c") == .c)
        #expect(CodeLanguage.detectLanguage(from: "file.html") == .html)
        #expect(CodeLanguage.detectLanguage(from: "file.css") == .css)
        #expect(CodeLanguage.detectLanguage(from: "file.md") == .markdown)
        #expect(CodeLanguage.detectLanguage(from: "file.json") == .json)
        #expect(CodeLanguage.detectLanguage(from: "file.unknown") == .plaintext)
    }
    
    @Test("Multiple extension support")
    func multipleExtensions() async throws {
        #expect(CodeLanguage.detectLanguage(from: "file.jsx") == .javascript)
        #expect(CodeLanguage.detectLanguage(from: "file.ts") == .typescript)
        #expect(CodeLanguage.detectLanguage(from: "file.hpp") == .cpp)
        #expect(CodeLanguage.detectLanguage(from: "file.h") == .c)
    }
    
    @Test("Modified flag updates")
    func modifiedFlag() async throws {
        let doc = CodeDocument(filename: "test.txt", content: "original")
        
        #expect(doc.isModified == false)
        
        doc.content = "modified"
        doc.isModified = true
        
        #expect(doc.isModified == true)
    }
    
    @Test("File extension handling")
    func fileExtensions() async throws {
        #expect(CodeLanguage.swift.fileExtension == ".swift")
        #expect(CodeLanguage.python.fileExtension == ".py")
        #expect(CodeLanguage.javascript.fileExtension == ".js")
        #expect(CodeLanguage.plaintext.fileExtension == ".txt")
    }
    
    @Test("Document equality")
    func documentEquality() async throws {
        let doc1 = CodeDocument(filename: "test.swift", content: "test")
        let doc2 = CodeDocument(filename: "test.swift", content: "test")
        
        // Documents with different IDs should not be equal
        #expect(doc1.id != doc2.id)
        #expect(doc1 != doc2)
    }
    
    @Test("Empty document handling")
    func emptyDocument() async throws {
        let doc = CodeDocument(filename: "empty.txt", content: "")
        
        #expect(doc.content.isEmpty)
        #expect(doc.filename == "empty.txt")
    }
    
    @Test("Large content handling")
    func largeContent() async throws {
        let largeContent = String(repeating: "a", count: 100_000)
        let doc = CodeDocument(filename: "large.txt", content: largeContent)
        
        #expect(doc.content.count == 100_000)
    }
    
    @Test("Unicode content handling")
    func unicodeContent() async throws {
        let content = "Hello 世界 🌍 Привет"
        let doc = CodeDocument(filename: "unicode.txt", content: content)
        
        #expect(doc.content == content)
    }
    
    @Test("Line counting")
    func lineCounting() async throws {
        let content = "line1\nline2\nline3"
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        
        #expect(lines.count == 3)
    }
}
