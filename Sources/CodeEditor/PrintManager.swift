import AppKit
import Foundation

// MARK: - PrintManager

enum PrintManager {

    /// Print a text view's contents with syntax highlighting preserved.
    static func print(textView: NSTextView, filename: String) {
        let printInfo = NSPrintInfo.shared.copy() as! NSPrintInfo

        // Configure page layout
        printInfo.topMargin = 60
        printInfo.bottomMargin = 40
        printInfo.leftMargin = 40
        printInfo.rightMargin = 40
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic

        // Create a printable view that wraps the attributed content
        let printableView = PrintableCodeView(
            attributedString: textView.attributedString(),
            filename: filename,
            printInfo: printInfo
        )

        let printOperation = NSPrintOperation(view: printableView, printInfo: printInfo)
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        printOperation.jobTitle = filename

        printOperation.run()
    }
}

// MARK: - PrintableCodeView

private final class PrintableCodeView: NSView {

    private let attributedString: NSAttributedString
    private let filename: String
    private let printInfo: NSPrintInfo
    private let headerHeight: CGFloat = 40
    private let footerHeight: CGFloat = 24
    private let lineNumberWidth: CGFloat = 40

    init(attributedString: NSAttributedString, filename: String, printInfo: NSPrintInfo) {
        self.attributedString = attributedString
        self.filename = filename
        self.printInfo = printInfo

        let paperSize = printInfo.paperSize
        let contentWidth = paperSize.width - printInfo.leftMargin - printInfo.rightMargin

        // Calculate required height
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(containerSize: NSSize(
            width: contentWidth - lineNumberWidth,
            height: CGFloat.greatestFiniteMagnitude
        ))
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        // Force layout
        layoutManager.ensureLayout(for: textContainer)
        let usedRect = layoutManager.usedRect(for: textContainer)

        let totalHeight = usedRect.height + 40

        super.init(frame: NSRect(x: 0, y: 0, width: contentWidth, height: totalHeight))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    override var isFlipped: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        // White background for print
        NSColor.white.setFill()
        bounds.fill()

        let contentWidth = bounds.width

        // Draw header
        drawHeader(in: NSRect(x: 0, y: 0, width: contentWidth, height: headerHeight))

        // Draw separator line
        NSColor.lightGray.setFill()
        NSRect(x: 0, y: headerHeight - 1, width: contentWidth, height: 0.5).fill()

        // Draw code content
        let codeRect = NSRect(
            x: 0,
            y: headerHeight,
            width: contentWidth,
            height: bounds.height - headerHeight - footerHeight
        )
        drawCode(in: codeRect)

        // Draw footer separator
        let footerY = bounds.height - footerHeight
        NSColor.lightGray.setFill()
        NSRect(x: 0, y: footerY, width: contentWidth, height: 0.5).fill()

        // Draw footer
        drawFooter(in: NSRect(x: 0, y: footerY, width: contentWidth, height: footerHeight))
    }

    private func drawHeader(in rect: NSRect) {
        let filenameParagraphStyle = NSMutableParagraphStyle()
        filenameParagraphStyle.alignment = .left

        let filenameAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont(name: "SF Mono", size: 11) ?? NSFont.monospacedSystemFont(ofSize: 11, weight: .regular),
            .foregroundColor: NSColor.black,
            .paragraphStyle: filenameParagraphStyle
        ]

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: Date())

        let dateParagraphStyle = NSMutableParagraphStyle()
        dateParagraphStyle.alignment = .right

        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: NSColor.darkGray,
            .paragraphStyle: dateParagraphStyle
        ]

        let filenameRect = NSRect(x: 8, y: rect.minY + 8, width: rect.width * 0.6, height: rect.height - 16)
        let dateRect = NSRect(x: rect.width * 0.6, y: rect.minY + 8, width: rect.width * 0.4 - 8, height: rect.height - 16)

        filename.draw(in: filenameRect, withAttributes: filenameAttributes)
        dateString.draw(in: dateRect, withAttributes: dateAttributes)
    }

    private func drawCode(in rect: NSRect) {
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let codeWidth = rect.width - lineNumberWidth
        let textContainer = NSTextContainer(containerSize: NSSize(
            width: codeWidth,
            height: CGFloat.greatestFiniteMagnitude
        ))
        textContainer.lineFragmentPadding = 4
        layoutManager.addTextContainer(textContainer)

        // Force layout
        layoutManager.ensureLayout(for: textContainer)

        // Draw line numbers and code
        let monoFont = NSFont(name: "SF Mono", size: 9) ?? NSFont.monospacedSystemFont(ofSize: 9, weight: .regular)
        let lineNumberAttributes: [NSAttributedString.Key: Any] = [
            .font: monoFont,
            .foregroundColor: NSColor.lightGray,
            .paragraphStyle: {
                let style = NSMutableParagraphStyle()
                style.alignment = .right
                return style
            }()
        ]

        let text = attributedString.string as NSString
        var lineNumber = 1
        var currentCharIndex = 0

        while currentCharIndex <= text.length {
            let lineRange = currentCharIndex < text.length ?
                text.lineRange(for: NSRange(location: currentCharIndex, length: 0)) :
                NSRange(location: text.length, length: 0)

            // Get glyph range
            let glyphRange = layoutManager.glyphRange(forCharacterRange: NSRange(location: currentCharIndex, length: max(lineRange.length, 1)), actualCharacterRange: nil)

            if glyphRange.location == NSNotFound || glyphRange.location >= layoutManager.numberOfGlyphs {
                break
            }

            let lineGlyphIndex = min(glyphRange.location, layoutManager.numberOfGlyphs - 1)
            let lineFragmentRect = layoutManager.lineFragmentRect(forGlyphAt: lineGlyphIndex, effectiveRange: nil)

            let lineY = rect.minY + lineFragmentRect.minY

            // Draw line number
            let lineNumRect = NSRect(
                x: rect.minX,
                y: lineY,
                width: lineNumberWidth - 8,
                height: lineFragmentRect.height
            )
            "\(lineNumber)".draw(in: lineNumRect, withAttributes: lineNumberAttributes)

            lineNumber += 1

            if lineRange.length == 0 || NSMaxRange(lineRange) >= text.length {
                break
            }
            currentCharIndex = NSMaxRange(lineRange)
        }

        // Draw the attributed text
        let textOrigin = NSPoint(x: rect.minX + lineNumberWidth, y: rect.minY)
        layoutManager.drawBackground(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs), at: textOrigin)
        layoutManager.drawGlyphs(forGlyphRange: NSRange(location: 0, length: layoutManager.numberOfGlyphs), at: textOrigin)
    }

    private func drawFooter(in rect: NSRect) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 9),
            .foregroundColor: NSColor.darkGray,
            .paragraphStyle: paragraphStyle
        ]

        "CodeEditor".draw(
            in: NSRect(x: 0, y: rect.minY + 6, width: rect.width, height: rect.height - 6),
            withAttributes: attributes
        )
    }

    override func knowsPageRange(_ range: NSRangePointer) -> Bool {
        let paperHeight = printInfo.paperSize.height - printInfo.topMargin - printInfo.bottomMargin
        let totalPages = max(1, Int(ceil(bounds.height / paperHeight)))
        range.pointee = NSRange(location: 1, length: totalPages)
        return true
    }

    override func rectForPage(_ page: Int) -> NSRect {
        let paperHeight = printInfo.paperSize.height - printInfo.topMargin - printInfo.bottomMargin
        let y = CGFloat(page - 1) * paperHeight
        return NSRect(x: 0, y: y, width: bounds.width, height: paperHeight)
    }
}
