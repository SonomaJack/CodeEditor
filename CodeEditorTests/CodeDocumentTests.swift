//
//  CodeDocumentTests.swift
//  CodeEditor
//
//  Created by J Bretcher on 4/3/26.
//


//
//  CodeDocumentTests.swift
//  CodeEditorTests
//
//  Created by J Bretcher on 4/3/26.
//

import XCTest
@testable import CodeEditor

final class CodeDocumentTests: XCTestCase {
    
    func testCreateNewDocument() throws {
        let doc = CodeDocument(filename: "test.swift", content: "// Test", language: .swift)
        
        XCTAssertEqual(doc.filename, "test.swift")
        XCTAssertEqual(doc.content, "// Test")
        XCTAssertEqual(doc.language, .swift)
        XCTAssertFalse(doc.isModified)
    }
    
    func testLanguageDetection() throws {
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.swift"), .swift)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.py"), .python)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.js"), .javascript)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.java"), .java)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.cpp"), .cpp)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.c"), .c)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.html"), .html)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.css"), .css)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.md"), .markdown)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.json"), .json)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.unknown"), .plaintext)
    }
    
    func testMultipleExtensions() throws {
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.jsx"), .javascript)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.ts"), .typescript)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.hpp"), .cpp)
        XCTAssertEqual(CodeLanguage.detectLanguage(from: "file.h"), .c)
    }
    
    func testModifiedFlag() throws {
        let doc = CodeDocument(filename: "test.txt", content: "original")
        
        XCTAssertFalse(doc.isModified)
        
        doc.content = "modified"
        doc.isModified = true
        
        XCTAssertTrue(doc.isModified)
    }
    
    func testFileExtensions() throws {
        XCTAssertEqual(CodeLanguage.swift.fileExtension, ".swift")
        XCTAssertEqual(CodeLanguage.python.fileExtension, ".py")
        XCTAssertEqual(CodeLanguage.javascript.fileExtension, ".js")
        XCTAssertEqual(CodeLanguage.plaintext.fileExtension, ".txt")
    }
    
    func testDocumentEquality() throws {
        let doc1 = CodeDocument(filename: "test.swift", content: "test")
        let doc2 = CodeDocument(filename: "test.swift", content: "test")
        
        // Documents with different IDs should not be equal
        XCTAssertNotEqual(doc1.id, doc2.id)
        XCTAssertNotEqual(doc1, doc2)
    }
    
    func testEmptyDocument() throws {
        let doc = CodeDocument(filename: "empty.txt", content: "")
        
        XCTAssertTrue(doc.content.isEmpty)
        XCTAssertEqual(doc.filename, "empty.txt")
    }
    
    func testLargeContent() throws {
        let largeContent = String(repeating: "a", count: 100_000)
        let doc = CodeDocument(filename: "large.txt", content: largeContent)
        
        XCTAssertEqual(doc.content.count, 100_000)
    }
    
    func testUnicodeContent() throws {
        let content = "Hello 世界 🌍 Привет"
        let doc = CodeDocument(filename: "unicode.txt", content: content)
        
        XCTAssertEqual(doc.content, content)
    }
    
    func testLineCounting() throws {
        let content = "line1\nline2\nline3"
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        
        XCTAssertEqual(lines.count, 3)
    }
}
