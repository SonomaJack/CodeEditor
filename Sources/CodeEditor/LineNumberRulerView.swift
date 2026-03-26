import AppKit

final class LineNumberRulerView: NSRulerView {

    private var font: NSFont {
        NSFont(name: "SF Mono", size: 11) ??
        NSFont(name: "Menlo", size: 11) ??
        NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
    }

    private let textColor = ThemeColors.lineNumber
    private let backgroundColor = NSColor(hex: "#1E1E1E")
    private let currentLineColor = NSColor(hex: "#C6C6C6")

    weak var textView: NSTextView?

    override init(scrollView: NSScrollView?, orientation: NSRulerView.Orientation) {
        super.init(scrollView: scrollView, orientation: orientation)
        setup()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        ruleThickness = 50
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: NSText.didChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textDidChange),
            name: NSTextView.didChangeSelectionNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func textDidChange(_ notification: Notification) {
        needsDisplay = true
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = self.textView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else {
            return
        }

        let string = textView.string as NSString
        let visibleRect = scrollView?.contentView.bounds ?? rect

        // Fill background
        backgroundColor.setFill()
        rect.fill()

        // Draw a subtle right border
        NSColor(hex: "#3C3C3C").setFill()
        NSRect(x: rect.maxX - 1, y: rect.minY, width: 1, height: rect.height).fill()

        // Get the selected range to determine current line
        let selectedRange = textView.selectedRange()
        let currentLineRange = string.lineRange(for: NSRange(location: selectedRange.location, length: 0))

        // Text attributes
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .right

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        let currentLineAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: currentLineColor,
            .paragraphStyle: paragraphStyle
        ]

        // Calculate line number at visible rect top
        let contentOffset = visibleRect.origin
        var glyphIndex = layoutManager.glyphIndex(for: contentOffset, in: textContainer, fractionOfDistanceThroughGlyph: nil)

        // Handle empty document
        if string.length == 0 {
            let lineRect = NSRect(x: 0, y: -contentOffset.y, width: ruleThickness - 8, height: 20)
            "1".draw(in: lineRect, withAttributes: attributes)
            return
        }

        // Clamp glyphIndex
        glyphIndex = min(glyphIndex, layoutManager.numberOfGlyphs > 0 ? layoutManager.numberOfGlyphs - 1 : 0)

        var charIndex = layoutManager.characterIndexForGlyph(at: glyphIndex)
        charIndex = min(charIndex, string.length > 0 ? string.length - 1 : 0)

        // Find the line number at this character index
        var lineNumber = 1
        string.enumerateSubstrings(in: NSRange(location: 0, length: charIndex), options: [.byLines, .substringNotRequired]) { _, _, _, _ in
            lineNumber += 1
        }

        // Draw line numbers for all visible lines
        var currentCharIndex = string.lineRange(for: NSRange(location: charIndex, length: 0)).location

        while currentCharIndex < string.length {
            let lineRange = string.lineRange(for: NSRange(location: currentCharIndex, length: 0))

            // Get glyph range for this line
            let glyphRange = layoutManager.glyphRange(forCharacterRange: lineRange, actualCharacterRange: nil)
            if glyphRange.location == NSNotFound || glyphRange.length == 0 {
                break
            }

            // Get the bounding rect for this glyph range
            let lineGlyphIndex = glyphRange.location
            var lineY: CGFloat = 0

            if lineGlyphIndex < layoutManager.numberOfGlyphs {
                let glyphRect = layoutManager.lineFragmentRect(forGlyphAt: lineGlyphIndex, effectiveRange: nil)
                lineY = glyphRect.minY + textView.textContainerInset.height - contentOffset.y
            } else {
                break
            }

            // Check if this line is visible
            if lineY > visibleRect.height + 20 {
                break
            }

            // Check if this is the current line
            let isCurrentLine = NSLocationInRange(currentCharIndex, currentLineRange) ||
                                 (currentLineRange.location == currentCharIndex)

            let attrs = isCurrentLine ? currentLineAttributes : attributes

            // Draw line number
            let lineNumberString = "\(lineNumber)"
            let drawRect = NSRect(
                x: 0,
                y: lineY,
                width: ruleThickness - 8,
                height: font.pointSize + 6
            )

            if drawRect.minY >= -20 {
                lineNumberString.draw(in: drawRect, withAttributes: attrs)
            }

            lineNumber += 1
            currentCharIndex = NSMaxRange(lineRange)

            if currentCharIndex >= string.length {
                break
            }
        }

        // Handle the case where we need to show a line number after the last newline
        if string.length > 0 {
            let lastChar = string.character(at: string.length - 1)
            if lastChar == 10 { // newline character
                let lastGlyphIndex = layoutManager.numberOfGlyphs
                if lastGlyphIndex > 0 {
                    let glyphRect = layoutManager.lineFragmentRect(forGlyphAt: lastGlyphIndex - 1, effectiveRange: nil)
                    let lineY = glyphRect.maxY + textView.textContainerInset.height - contentOffset.y

                    if lineY < visibleRect.height + 20 {
                        let lineNumberString = "\(lineNumber)"
                        let drawRect = NSRect(
                            x: 0,
                            y: lineY,
                            width: ruleThickness - 8,
                            height: font.pointSize + 6
                        )
                        lineNumberString.draw(in: drawRect, withAttributes: attributes)
                    }
                }
            }
        }
    }

    override var requiredThickness: CGFloat {
        return 50
    }
}
