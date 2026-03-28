//
//  CodeTextView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI
import AppKit

struct CodeTextView: NSViewRepresentable {
    @Binding var text: String
    @Binding var isModified: Bool
    let language: CodeLanguage
    let showLineNumbers: Bool
    let onTextChange: () -> Void
    var highlightRange: HighlightRange? = nil
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        // Basic configuration
        textView.delegate = context.coordinator
        textView.string = text
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.allowsUndo = true
        
        // Apply syntax highlighting after text is set
        if !text.isEmpty {
            applySyntaxHighlighting(to: textView, language: language)
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        if textView.string != text {
            textView.string = text
            if !text.isEmpty {
                applySyntaxHighlighting(to: textView, language: language)
            }
        }
        
        // Handle highlighting and scrolling to selected search result
        // Only update if the highlight range has changed
        if let highlight = highlightRange, highlight != context.coordinator.lastHighlightRange {
            context.coordinator.lastHighlightRange = highlight
            scrollAndHighlight(textView: textView, highlight: highlight)
        } else if highlightRange == nil && context.coordinator.lastHighlightRange != nil {
            // Clear highlighting if there's no highlight range
            context.coordinator.lastHighlightRange = nil
            if let textStorage = textView.textStorage {
                let fullRange = NSRange(location: 0, length: textStorage.length)
                textStorage.removeAttribute(.backgroundColor, range: fullRange)
            }
        }
    }
    
    private func applySyntaxHighlighting(to textView: NSTextView, language: CodeLanguage) {
        guard let textStorage = textView.textStorage else { return }
        
        let fullRange = NSRange(location: 0, length: textStorage.length)
        guard fullRange.length > 0 else { return }
        
        textStorage.beginEditing()
        
        // Set default font and color
        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular), range: fullRange)
        textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
        
        // Apply syntax highlighting
        let attributedString = SyntaxHighlighter.highlight(code: textView.string, language: language)
        
        // Transfer color attributes
        var currentPosition = 0
        for run in attributedString.runs {
            let substring = attributedString[run.range]
            let runText = String(substring.characters)
            let runLength = runText.utf16.count
            
            let nsRange = NSRange(location: currentPosition, length: runLength)
            
            if let color = run.foregroundColor,
               nsRange.location >= 0,
               nsRange.length > 0,
               NSMaxRange(nsRange) <= textStorage.length {
                let nsColor = NSColor(color)
                textStorage.addAttribute(.foregroundColor, value: nsColor, range: nsRange)
            }
            
            currentPosition += runLength
        }
        
        textStorage.endEditing()
    }
    
    private func scrollAndHighlight(textView: NSTextView, highlight: HighlightRange) {
        let content = textView.string
        
        // Calculate the character position from line and column
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        guard highlight.lineNumber > 0 && highlight.lineNumber <= lines.count else { return }
        
        // Calculate character offset to the start of the target line
        var characterOffset = 0
        for i in 0..<(highlight.lineNumber - 1) {
            characterOffset += lines[i].count + 1 // +1 for newline
        }
        
        // Add column offset
        let lineStartOffset = characterOffset
        let highlightStart = characterOffset + highlight.columnStart - 1
        let highlightEnd = characterOffset + highlight.columnEnd - 1
        
        // Create NSRange for highlighting
        let highlightLength = max(0, highlightEnd - highlightStart)
        let nsRange = NSRange(location: highlightStart, length: highlightLength)
        
        // Validate range
        guard nsRange.location >= 0,
              nsRange.length >= 0,
              NSMaxRange(nsRange) <= content.count else { return }
        
        // Remove previous highlights
        if let textStorage = textView.textStorage {
            let fullRange = NSRange(location: 0, length: textStorage.length)
            textStorage.removeAttribute(.backgroundColor, range: fullRange)
            
            // Add highlight background
            textStorage.addAttribute(.backgroundColor, value: NSColor.findHighlightColor, range: nsRange)
        }
        
        // Scroll to make the range visible
        textView.scrollRangeToVisible(nsRange)
        textView.showFindIndicator(for: nsRange)
        
        // Optionally set selection
        textView.setSelectedRange(nsRange)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CodeTextView
        var lastHighlightRange: HighlightRange? = nil
        
        init(_ parent: CodeTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            parent.isModified = true
            parent.onTextChange()
            
            // Reapply syntax highlighting as you type
            if !textView.string.isEmpty {
                parent.applySyntaxHighlighting(to: textView, language: parent.language)
            }
        }
    }
}

// Helper struct for highlighting search results
struct HighlightRange: Equatable {
    let lineNumber: Int
    let columnStart: Int
    let columnEnd: Int
    let id: UUID
    
    init(lineNumber: Int, columnStart: Int, columnEnd: Int, id: UUID = UUID()) {
        self.lineNumber = lineNumber
        self.columnStart = columnStart
        self.columnEnd = columnEnd
        self.id = id
    }
}
