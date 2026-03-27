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
    let onTextChange: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        
        guard let textView = scrollView.documentView as? NSTextView else {
            return scrollView
        }
        
        // Configure text view
        textView.delegate = context.coordinator
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.textColor = .textColor
        textView.backgroundColor = .textBackgroundColor
        textView.insertionPointColor = .textColor
        textView.textContainerInset = NSSize(width: 10, height: 10)
        textView.isRichText = false
        textView.usesFindBar = true
        textView.isIncrementalSearchingEnabled = true
        
        // Enable line wrapping control
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isHorizontallyResizable = true
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        
        // Configure scroll view
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // Only update if text changed externally
        if textView.string != text {
            let selectedRange = textView.selectedRange()
            textView.string = text
            applySyntaxHighlighting(to: textView, language: language)
            
            // Restore selection if valid
            if selectedRange.location <= text.count {
                textView.setSelectedRange(selectedRange)
            }
        } else {
            // Just update syntax highlighting
            applySyntaxHighlighting(to: textView, language: language)
        }
    }
    
    private func applySyntaxHighlighting(to textView: NSTextView, language: CodeLanguage) {
        guard let textStorage = textView.textStorage else { return }
        
        let fullRange = NSRange(location: 0, length: textStorage.length)
        
        // Reset formatting
        textStorage.removeAttribute(.foregroundColor, range: fullRange)
        textStorage.addAttribute(.foregroundColor, value: NSColor.textColor, range: fullRange)
        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 13, weight: .regular), range: fullRange)
        
        // Apply syntax highlighting
        let attributedString = SyntaxHighlighter.highlight(code: textView.string, language: language)
        
        // Transfer attributes from AttributedString to NSTextStorage
        for run in attributedString.runs {
            // Get the string range from the attributed string run
            let startIndex = attributedString.characters.distance(from: attributedString.startIndex, to: run.range.lowerBound)
            let length = attributedString.characters.distance(from: run.range.lowerBound, to: run.range.upperBound)
            let nsRange = NSRange(location: startIndex, length: length)
            
            // Ensure the range is valid
            guard nsRange.location >= 0,
                  nsRange.length >= 0,
                  NSMaxRange(nsRange) <= textStorage.length else {
                continue
            }
            
            if let color = run.foregroundColor {
                textStorage.addAttribute(.foregroundColor, value: NSColor(color), range: nsRange)
            }
        }
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: CodeTextView
        
        init(_ parent: CodeTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            parent.text = textView.string
            parent.isModified = true
            parent.onTextChange()
            
            // Reapply syntax highlighting
            parent.applySyntaxHighlighting(to: textView, language: parent.language)
        }
    }
}
