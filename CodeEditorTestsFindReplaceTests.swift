//
//  FindReplaceTests.swift
//  CodeEditorTests
//
//  Created by J Bretcher on 4/3/26.
//

import Testing
import Foundation
@testable import CodeEditor

@Suite("Find and Replace Tests")
struct FindReplaceTests {
    
    @Test("Find single occurrence")
    func findSingleOccurrence() async throws {
        let content = "Hello World"
        let searchText = "World"
        
        let range = content.range(of: searchText)
        #expect(range != nil, "Should find 'World' in content")
    }
    
    @Test("Find multiple occurrences")
    func findMultipleOccurrences() async throws {
        let content = "test test test"
        let searchText = "test"
        
        var count = 0
        var searchRange = content.startIndex..<content.endIndex
        
        while let range = content.range(of: searchText, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<content.endIndex
        }
        
        #expect(count == 3, "Should find 3 occurrences of 'test'")
    }
    
    @Test("Case sensitive search")
    func caseSensitiveSearch() async throws {
        let content = "Hello hello HELLO"
        let searchText = "hello"
        
        let caseSensitiveRange = content.range(of: searchText, options: [])
        let caseInsensitiveRange = content.range(of: searchText, options: .caseInsensitive)
        
        #expect(caseSensitiveRange != nil)
        #expect(caseInsensitiveRange != nil)
        
        // Count case-insensitive matches
        var count = 0
        var searchRange = content.startIndex..<content.endIndex
        while let range = content.range(of: searchText, options: .caseInsensitive, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<content.endIndex
        }
        
        #expect(count == 3, "Should find 3 case-insensitive matches")
    }
    
    @Test("Replace single occurrence")
    func replaceSingleOccurrence() async throws {
        var content = "Hello World"
        let searchText = "World"
        let replaceText = "Swift"
        
        if let range = content.range(of: searchText) {
            content.replaceSubrange(range, with: replaceText)
        }
        
        #expect(content == "Hello Swift", "Should replace 'World' with 'Swift'")
    }
    
    @Test("Replace all occurrences")
    func replaceAllOccurrences() async throws {
        let content = "test test test"
        let searchText = "test"
        let replaceText = "TEST"
        
        let result = content.replacingOccurrences(of: searchText, with: replaceText)
        
        #expect(result == "TEST TEST TEST", "Should replace all 'test' with 'TEST'")
    }
    
    @Test("Find with newline characters")
    func findWithNewlines() async throws {
        let content = "line1\nline2\nline3"
        let searchText = "\n"
        
        var count = 0
        var searchRange = content.startIndex..<content.endIndex
        
        while let range = content.range(of: searchText, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<content.endIndex
        }
        
        #expect(count == 2, "Should find 2 newline characters")
    }
    
    @Test("Replace newlines")
    func replaceNewlines() async throws {
        let content = "line1\nline2\nline3"
        let searchText = "\n"
        let replaceText = " "
        
        let result = content.replacingOccurrences(of: searchText, with: replaceText)
        
        #expect(result == "line1 line2 line3", "Should replace newlines with spaces")
    }
    
    @Test("Find tabs")
    func findTabs() async throws {
        let content = "one\ttwo\tthree"
        let searchText = "\t"
        
        var count = 0
        var searchRange = content.startIndex..<content.endIndex
        
        while let range = content.range(of: searchText, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<content.endIndex
        }
        
        #expect(count == 2, "Should find 2 tab characters")
    }
    
    @Test("Column-restricted search")
    func columnRestrictedSearch() async throws {
        let line = "0123456789"
        let startCol = 3
        let endCol = 7
        
        let startIndex = line.index(line.startIndex, offsetBy: startCol)
        let endIndex = line.index(line.startIndex, offsetBy: endCol)
        
        let searchRange = String(line[startIndex..<endIndex])
        
        #expect(searchRange == "3456", "Should extract correct column range")
    }
    
    @Test("Whole word search")
    func wholeWordSearch() async throws {
        let content = "test testing tester"
        let searchText = "test"
        
        // Find all occurrences
        var ranges: [Range<String.Index>] = []
        var searchRange = content.startIndex..<content.endIndex
        
        while let range = content.range(of: searchText, range: searchRange) {
            // Check if it's a whole word
            let beforeChar = range.lowerBound > content.startIndex ? content[content.index(before: range.lowerBound)] : " "
            let afterChar = range.upperBound < content.endIndex ? content[range.upperBound] : " "
            
            if !beforeChar.isLetter && !beforeChar.isNumber && !afterChar.isLetter && !afterChar.isNumber {
                ranges.append(range)
            }
            
            searchRange = range.upperBound..<content.endIndex
        }
        
        #expect(ranges.count == 1, "Should find only 1 whole word match of 'test'")
    }
    
    @Test("Empty search handling")
    func emptySearchHandling() async throws {
        let content = "Hello World"
        let searchText = ""
        
        let range = content.range(of: searchText)
        
        // Empty search should match at the beginning
        #expect(range != nil)
    }
    
    @Test("Search with special characters")
    func searchWithSpecialCharacters() async throws {
        let content = "Price: $100.00"
        let searchText = "$100"
        
        let range = content.range(of: searchText)
        
        #expect(range != nil, "Should find special characters")
    }
    
    @Test("Replace with empty string")
    func replaceWithEmptyString() async throws {
        let content = "Hello World"
        let searchText = " World"
        let replaceText = ""
        
        let result = content.replacingOccurrences(of: searchText, with: replaceText)
        
        #expect(result == "Hello", "Should remove ' World'")
    }
    
    @Test("Windows to Unix line endings")
    func windowsToUnixLineEndings() async throws {
        let content = "line1\r\nline2\r\nline3"
        let searchText = "\r\n"
        let replaceText = "\n"
        
        let result = content.replacingOccurrences(of: searchText, with: replaceText)
        
        #expect(result == "line1\nline2\nline3", "Should convert Windows to Unix line endings")
    }
}
