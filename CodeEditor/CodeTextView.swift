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
    let fontSize: CGFloat
    let onTextChange: () -> Void
    var highlightRange: HighlightRange? = nil
    var onCursorPositionChange: ((Int, Int, Int) -> Void)? = nil // (line, column, selectionLength)
    
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
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.allowsUndo = true
        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        
        // Store the initial text in coordinator to track changes
        context.coordinator.currentText = text
        textView.string = text
        
        // Add line numbers if enabled
        if showLineNumbers {
            let lineNumberView = LineNumberRulerView(textView: textView, fontSize: fontSize)
            scrollView.verticalRulerView = lineNumberView
            scrollView.hasVerticalRuler = true
            scrollView.rulersVisible = true
        }
        
        // Apply syntax highlighting after text is set
        if !text.isEmpty {
            applySyntaxHighlighting(to: textView, language: language, fontSize: fontSize)
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // Update font size if changed
        if let currentFont = textView.font, currentFont.pointSize != fontSize {
            textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
            if !text.isEmpty {
                applySyntaxHighlighting(to: textView, language: language, fontSize: fontSize)
            }
            
            // Update line number view font size
            if let lineNumberView = scrollView.verticalRulerView as? LineNumberRulerView {
                lineNumberView.fontSize = fontSize
            }
        }
        
        // Update line numbers visibility
        if showLineNumbers != scrollView.rulersVisible {
            if showLineNumbers {
                let lineNumberView = LineNumberRulerView(textView: textView, fontSize: fontSize)
                scrollView.verticalRulerView = lineNumberView
                scrollView.hasVerticalRuler = true
                scrollView.rulersVisible = true
            } else {
                scrollView.hasVerticalRuler = false
                scrollView.rulersVisible = false
                scrollView.verticalRulerView = nil
            }
        }
        
        // Only update if the text has actually changed from outside the text view
        // This prevents cursor jumping when typing
        if textView.string != text && context.coordinator.currentText != text {
            let selectedRange = textView.selectedRange()
            textView.string = text
            context.coordinator.currentText = text
            
            if !text.isEmpty {
                applySyntaxHighlighting(to: textView, language: language, fontSize: fontSize)
            }
            
            // Restore selection if possible
            if selectedRange.location <= text.count {
                textView.setSelectedRange(selectedRange)
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
    
    private func applySyntaxHighlighting(to textView: NSTextView, language: CodeLanguage, fontSize: CGFloat) {
        guard let textStorage = textView.textStorage else { return }
        
        let fullRange = NSRange(location: 0, length: textStorage.length)
        guard fullRange.length > 0 else { return }
        
        textStorage.beginEditing()
        
        // Set default font and color
        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular), range: fullRange)
        textStorage.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
        
        // Apply syntax highlighting
        let attributedString = SyntaxHighlighter.highlight(code: textView.string, language: language)
        
        // Transfer color attributes - but preserve existing background colors
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
            textStorage.addAttribute(.backgroundColor, value: NSColor.systemYellow.withAlphaComponent(0.5), range: nsRange)
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
        var currentText: String = ""
        var isApplyingSyntaxHighlighting = false
        
        init(_ parent: CodeTextView) {
            self.parent = parent
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // Don't trigger re-highlighting while we're already highlighting
            guard !isApplyingSyntaxHighlighting else { return }
            
            let newText = textView.string
            
            // Update both the binding and our tracked text
            parent.text = newText
            currentText = newText
            parent.isModified = true
            parent.onTextChange()
            
            // Update cursor position
            updateCursorPosition(textView)
            
            // Reapply syntax highlighting as you type
            if !newText.isEmpty {
                isApplyingSyntaxHighlighting = true
                
                // Store the current background highlights before re-applying syntax
                var backgroundHighlights: [(NSRange, NSColor)] = []
                if let textStorage = textView.textStorage {
                    let fullRange = NSRange(location: 0, length: textStorage.length)
                    textStorage.enumerateAttribute(.backgroundColor, in: fullRange) { value, range, _ in
                        if let color = value as? NSColor {
                            backgroundHighlights.append((range, color))
                        }
                    }
                }
                
                parent.applySyntaxHighlighting(to: textView, language: parent.language, fontSize: parent.fontSize)
                
                // Re-apply background highlights after syntax highlighting
                if let textStorage = textView.textStorage {
                    for (range, color) in backgroundHighlights {
                        // Make sure range is still valid
                        if NSMaxRange(range) <= textStorage.length {
                            textStorage.addAttribute(.backgroundColor, value: color, range: range)
                        }
                    }
                }
                
                isApplyingSyntaxHighlighting = false
            }
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            updateCursorPosition(textView)
        }
        
        private func updateCursorPosition(_ textView: NSTextView) {
            let selectedRange = textView.selectedRange()
            let text = textView.string
            
            // Calculate line and column
            let cursorPosition = selectedRange.location
            let selectionLength = selectedRange.length
            
            // Count lines up to cursor position
            let textUpToCursor = String(text.prefix(cursorPosition))
            let lineNumber = textUpToCursor.components(separatedBy: "\n").count
            
            // Find the start of the current line
            let lines = textUpToCursor.components(separatedBy: "\n")
            let currentLinePrefix = lines.last ?? ""
            let columnNumber = currentLinePrefix.count + 1
            
            // Call the callback
            parent.onCursorPositionChange?(lineNumber, columnNumber, selectionLength)
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

// MARK: - Line Number Ruler View
class LineNumberRulerView: NSRulerView {
    var fontSize: CGFloat {
        didSet {
            needsDisplay = true
        }
    }
    
    init(textView: NSTextView, fontSize: CGFloat) {
        self.fontSize = fontSize
        super.init(scrollView: textView.enclosingScrollView, orientation: .verticalRuler)
        self.clientView = textView
        self.ruleThickness = 40
        
        // Register for scroll notifications to update line numbers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidScroll(_:)),
            name: NSView.boundsDidChangeNotification,
            object: textView.enclosingScrollView?.contentView
        )
        
        // Register for text change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange(_:)),
            name: NSText.didChangeNotification,
            object: textView
        )
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func textDidScroll(_ notification: Notification) {
        needsDisplay = true
    }
    
    @objc private func textDidChange(_ notification: Notification) {
        needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard let textView = self.clientView as? NSTextView else { return }
        
        // Draw background
        NSColor.controlBackgroundColor.withAlphaComponent(0.5).setFill()
        bounds.fill()
        
        // Only draw separator line where there is actual text content
        // Get the visible text area to know where to draw the line
        let visibleRect = textView.visibleRect
        
        // Draw separator line on the right edge, only within the text view's content area
        NSColor.separatorColor.setStroke()
        let separatorPath = NSBezierPath()
        separatorPath.move(to: NSPoint(x: bounds.maxX - 0.5, y: max(dirtyRect.minY, 0)))
        separatorPath.line(to: NSPoint(x: bounds.maxX - 0.5, y: min(dirtyRect.maxY, visibleRect.maxY - visibleRect.minY)))
        separatorPath.lineWidth = 1.0
        separatorPath.stroke()
        
        // Draw line numbers
        drawHashMarksAndLabels(in: dirtyRect)
    }
    
    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = self.clientView as? NSTextView else { return }
        
        let text = textView.string
        guard !text.isEmpty else { return }
        
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let textColor = NSColor.secondaryLabelColor
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor
        ]
        
        guard let layoutManager = textView.layoutManager,
              let container = textView.textContainer else { return }
        
        // Force layout to complete before drawing
        layoutManager.ensureLayout(for: container)
        
        // Get the visible rect in the text view's coordinate system
        let visibleRect = textView.visibleRect
        
        // Get the glyph range for the visible area
        let glyphRange = layoutManager.glyphRange(forBoundingRect: visibleRect, in: container)
        let charRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        // Calculate line height for positioning blank lines
        let lineHeight = font.pointSize + 4
        
        // Use NSString's line enumeration for accurate line detection
        let nsText = text as NSString
        var lineNumber = 0
        var lastYPosition: CGFloat = 0
        
        nsText.enumerateSubstrings(in: NSRange(location: 0, length: nsText.length), options: .byLines) { substring, substringRange, enclosingRange, stop in
            lineNumber += 1
            
            // For blank lines, the substringRange might have length 0
            // Check if the line position is within or near the visible character range
            let lineStart = substringRange.location
            let lineEnd = substringRange.location + max(substringRange.length, 1)
            let lineIsInVisibleRange = lineStart <= NSMaxRange(charRange) && lineEnd >= charRange.location
            
            guard lineIsInVisibleRange else { return }
            
            // Try to get the line fragment rect
            var yPosition: CGFloat = 0
            var lineRect: NSRect = .zero
            
            // Get the glyph index for the start of this line
            if substringRange.location < text.count {
                let lineStartGlyphIndex = layoutManager.glyphIndexForCharacter(at: substringRange.location)
                
                // Get the line fragment rect for this glyph (works even for empty lines)
                var effectiveRange = NSRange(location: 0, length: 0)
                lineRect = layoutManager.lineFragmentRect(forGlyphAt: lineStartGlyphIndex, effectiveRange: &effectiveRange)
                
                if lineRect.height > 0 {
                    yPosition = lineRect.origin.y - visibleRect.origin.y
                    lastYPosition = yPosition
                } else {
                    // For blank lines without proper layout, estimate position
                    yPosition = lastYPosition + lineHeight
                    lastYPosition = yPosition
                }
            } else {
                // Line at end of document - estimate position
                yPosition = lastYPosition + lineHeight
                lastYPosition = yPosition
            }
            
            // Only draw if the line is visible
            guard yPosition >= -lineHeight && yPosition <= visibleRect.height + lineHeight else { return }
            
            // Draw the line number
            let numberString = "\(lineNumber)" as NSString
            let stringSize = numberString.size(withAttributes: attributes)
            let drawPoint = NSPoint(
                x: self.ruleThickness - stringSize.width - 8,
                y: yPosition
            )
            
            numberString.draw(at: drawPoint, withAttributes: attributes)
        }
    }
}
