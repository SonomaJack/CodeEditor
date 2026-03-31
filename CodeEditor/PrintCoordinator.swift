//
//  PrintCoordinator.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import AppKit
import SwiftUI

class PrintCoordinator {
    static func printDocument(_ document: CodeDocument, from window: NSWindow?) {
        let code = document.content
        let filename = document.filename
        let language = document.language
        let showLineNumbers = document.showLineNumbers
        let fileURL = document.fileURL
        let lastSaveDate = document.lastSaveDate
        
        // Create print info with NO margins - we'll handle all spacing ourselves
        let printInfo = NSPrintInfo()
        printInfo.topMargin = 0
        printInfo.bottomMargin = 0
        printInfo.leftMargin = 0
        printInfo.rightMargin = 0
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        
        // Enable scaling to fit content on page
        printInfo.scalingFactor = 1.0
        
        // Calculate printable area
        let paperSize = printInfo.paperSize
        let printableWidth = paperSize.width - printInfo.leftMargin - printInfo.rightMargin
        
        // Apply syntax highlighting
        let highlightedString = SyntaxHighlighter.highlight(code: code, language: language)
        
        // Add line numbers if enabled
        let codeWithLineNumbers: String
        if showLineNumbers {
            let lines = code.components(separatedBy: .newlines)
            let lineCount = lines.count
            let lineNumberWidth = "\(lineCount)".count
            
            codeWithLineNumbers = lines.enumerated().map { index, line in
                let lineNum = String(format: "%\(lineNumberWidth)d", index + 1)
                return "\(lineNum) │ \(line)"
            }.joined(separator: "\n")
        } else {
            codeWithLineNumbers = code
        }
        
        // Convert SwiftUI AttributedString to NSAttributedString with proper color conversion
        let mutableAttributedString = NSMutableAttributedString(string: codeWithLineNumbers)
        
        // Track current position in the original code
        var codePosition = 0
        
        // Calculate offset for line numbers
        let lineNumberOffset: Int
        if showLineNumbers {
            let lines = code.components(separatedBy: .newlines)
            let lineCount = lines.count
            let lineNumberWidth = "\(lineCount)".count
            lineNumberOffset = lineNumberWidth + 3 // width + " │ "
        } else {
            lineNumberOffset = 0
        }
        
        // Manually transfer attributes from AttributedString to NSAttributedString
        var currentLineOffset = 0
        for run in highlightedString.runs {
            // Get the text for this run using the substring
            let substring = highlightedString[run.range]
            let runText = String(substring.characters)
            let runLength = runText.utf16.count
            
            // Calculate position in the string with line numbers
            let displayPosition = codePosition + currentLineOffset
            
            // Create NSRange for this run
            let nsRange = NSRange(location: displayPosition, length: runLength)
            
            // Extract and convert the foreground color
            if let swiftUIColor = run.foregroundColor {
                // Convert SwiftUI Color to NSColor using system colors
                let nsColor: NSColor
                switch swiftUIColor {
                case .red:
                    nsColor = NSColor.systemRed
                case .blue:
                    nsColor = NSColor.systemBlue
                case .green:
                    nsColor = NSColor.systemGreen
                case .purple:
                    nsColor = NSColor.systemPurple
                case .orange:
                    nsColor = NSColor.systemOrange
                case .pink:
                    nsColor = NSColor.systemPink
                case .yellow:
                    nsColor = NSColor.systemYellow
                case .brown:
                    nsColor = NSColor.systemBrown
                case .cyan:
                    nsColor = NSColor.systemCyan
                case .mint:
                    nsColor = NSColor.systemMint
                case .indigo:
                    nsColor = NSColor.systemIndigo
                case .teal:
                    nsColor = NSColor.systemTeal
                case .gray:
                    nsColor = NSColor.systemGray
                case .black:
                    nsColor = NSColor.black
                default:
                    // Fallback: try to initialize NSColor from SwiftUI Color
                    nsColor = NSColor(swiftUIColor)
                }
                
                if nsRange.location >= 0 && nsRange.location + nsRange.length <= mutableAttributedString.length {
                    mutableAttributedString.addAttribute(.foregroundColor, value: nsColor, range: nsRange)
                }
            }
            
            // Count newlines in this run to adjust offset
            let newlineCount = runText.components(separatedBy: "\n").count - 1
            currentLineOffset += newlineCount * lineNumberOffset
            
            // Move position forward
            codePosition += runLength
        }
        
        // Style line numbers if present
        if showLineNumbers {
            let fullText = mutableAttributedString.string
            let lines = fullText.components(separatedBy: .newlines)
            var lineStart = 0
            
            for line in lines {
                if let separatorRange = line.range(of: " │ ") {
                    let lineNumberLength = line.distance(from: line.startIndex, to: separatorRange.lowerBound)
                    let nsRange = NSRange(location: lineStart, length: lineNumberLength + 3) // include " │ "
                    
                    if nsRange.location >= 0 && nsRange.location + nsRange.length <= mutableAttributedString.length {
                        mutableAttributedString.addAttribute(.foregroundColor, value: NSColor.systemGray, range: nsRange)
                    }
                }
                lineStart += line.utf16.count + 1 // +1 for newline
            }
        }
        
        // Determine optimal font size (between 7 and 11 points)
        let initialFontSize: CGFloat = 10
        let minFontSize: CGFloat = 7
        let maxFontSize: CGFloat = 11
        
        // Calculate how many lines we have
        let lineCount = codeWithLineNumbers.components(separatedBy: .newlines).count
        let paperHeight = paperSize.height
        let printableHeight = paperHeight - printInfo.topMargin - printInfo.bottomMargin
        
        // Try to calculate if we need to scale down
        let testFont = NSFont.monospacedSystemFont(ofSize: initialFontSize, weight: .regular)
        let testParagraphStyle = NSMutableParagraphStyle()
        testParagraphStyle.lineSpacing = 1
        
        // Estimate line height
        let lineHeight = testFont.pointSize + testParagraphStyle.lineSpacing + 2
        let estimatedHeight = CGFloat(lineCount) * lineHeight
        
        // Calculate if we need to scale down
        var finalFontSize = initialFontSize
        if estimatedHeight > printableHeight {
            // Calculate scale factor needed
            let scaleFactor = printableHeight / estimatedHeight
            finalFontSize = max(minFontSize, min(maxFontSize, initialFontSize * scaleFactor))
        }
        
        // Apply final font size and paragraph style WITHOUT overwriting colors
        let finalFont = NSFont.monospacedSystemFont(ofSize: finalFontSize, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        
        let fullRange = NSRange(location: 0, length: mutableAttributedString.length)
        
        // Enumerate through each character range and preserve existing attributes
        mutableAttributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
            var newAttributes = attributes
            
            // Add/update font
            newAttributes[.font] = finalFont
            newAttributes[.paragraphStyle] = paragraphStyle
            
            // Only add black color if no color is present
            if newAttributes[.foregroundColor] == nil {
                newAttributes[.foregroundColor] = NSColor.black
            }
            
            mutableAttributedString.setAttributes(newAttributes, range: range)
        }
        
        // Create custom text view for printing
        let textView = PrintableTextView(frame: .zero)
        
        // Configure text container
        if let textContainer = textView.textContainer {
            textContainer.containerSize = NSSize(width: printableWidth, height: CGFloat.greatestFiniteMagnitude)
            textContainer.widthTracksTextView = false
        }
        
        // Configure text view - must draw background for colors to show
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .white
        textView.drawsBackground = true
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        
        // Set content
        textView.textStorage?.setAttributedString(mutableAttributedString)
        
        // Force layout
        if let layoutManager = textView.layoutManager, let textContainer = textView.textContainer {
            layoutManager.ensureLayout(for: textContainer)
            let usedRect = layoutManager.usedRect(for: textContainer)
            textView.frame = NSRect(x: 0, y: 0, width: printableWidth, height: usedRect.height)
        }
        
        // Create custom print view with headers and footers
        let printView = PrintViewWithHeaderFooter(
            textView: textView,
            filename: filename,
            fileURL: fileURL,
            lastSaveDate: lastSaveDate,
            printInfo: printInfo
        )
        
        // Create and run print operation
        let printOperation = NSPrintOperation(view: printView, printInfo: printInfo)
        printOperation.jobTitle = filename
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        
        if Thread.isMainThread {
            if let window = window ?? NSApp.keyWindow {
                printOperation.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
            } else {
                printOperation.run()
            }
        } else {
            DispatchQueue.main.async {
                if let window = window ?? NSApp.keyWindow {
                    printOperation.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
                } else {
                    printOperation.run()
                }
            }
        }
    }
}

// MARK: - Print View with Header and Footer
class PrintViewWithHeaderFooter: NSView {
    let textView: PrintableTextView
    let filename: String
    let fileURL: URL?
    let lastSaveDate: Date?
    let printInfo: NSPrintInfo
    private var currentPageNumber: Int = 1
    private var totalPageCount: Int = 1
    
    init(textView: PrintableTextView, filename: String, fileURL: URL?, lastSaveDate: Date?, printInfo: NSPrintInfo) {
        self.textView = textView
        self.filename = filename
        self.fileURL = fileURL
        self.lastSaveDate = lastSaveDate
        self.printInfo = printInfo
        
        super.init(frame: textView.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    override func knowsPageRange(_ range: NSRangePointer) -> Bool {
        // Let the text view calculate the page range
        let result = textView.knowsPageRange(range)
        totalPageCount = range.pointee.length
        return result
    }
    
    override func rectForPage(_ page: Int) -> NSRect {
        currentPageNumber = page
        
        // Get the text view's rect for this page
        var pageRect = textView.rectForPage(page)
        
        // Expand to include margins for header/footer
        let paperSize = printInfo.paperSize
        pageRect = NSRect(x: 0, y: 0, width: paperSize.width, height: paperSize.height)
        
        return pageRect
    }
    
    override func draw(_ dirtyRect: NSRect) {
        guard NSGraphicsContext.current != nil else { return }
        guard let currentPrintInfo = NSPrintOperation.current?.printInfo else { return }
        
        // Fill with white
        NSColor.white.setFill()
        dirtyRect.fill()
        
        let paperSize = currentPrintInfo.paperSize
        
        // Define our own margins since printInfo margins are 0
        let leftMargin: CGFloat = 36
        let rightMargin: CGFloat = 36
        let topMargin: CGFloat = 54
        let bottomMargin: CGFloat = 54
        let contentWidth = paperSize.width - leftMargin - rightMargin
        
        // Draw header at the very top
        let font = NSFont.systemFont(ofSize: 8)
        let headerY: CGFloat = 8
        let headerText = fileURL?.path ?? filename
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.gray
        ]
        (headerText as NSString).draw(at: NSPoint(x: leftMargin, y: headerY), withAttributes: headerAttrs)
        
        // Draw header line
        let headerLineY: CGFloat = 20
        NSColor.lightGray.setStroke()
        let headerLine = NSBezierPath()
        headerLine.move(to: NSPoint(x: leftMargin, y: headerLineY))
        headerLine.line(to: NSPoint(x: leftMargin + contentWidth, y: headerLineY))
        headerLine.lineWidth = 0.5
        headerLine.stroke()
        
        // Draw text content
        let contentStartY = topMargin
        let contentEndY = paperSize.height - bottomMargin
        let contentHeight = contentEndY - contentStartY
        
        NSGraphicsContext.saveGraphicsState()
        let pageRect = textView.rectForPage(currentPageNumber)
        let transform = NSAffineTransform()
        transform.translateX(by: leftMargin, yBy: contentStartY - pageRect.minY)
        transform.concat()
        NSBezierPath(rect: NSRect(x: 0, y: pageRect.minY, width: contentWidth, height: contentHeight)).addClip()
        textView.draw(pageRect)
        NSGraphicsContext.restoreGraphicsState()
        
        // Draw footer line
        let footerLineY = paperSize.height - 40
        let footerLine = NSBezierPath()
        footerLine.move(to: NSPoint(x: leftMargin, y: footerLineY))
        footerLine.line(to: NSPoint(x: leftMargin + contentWidth, y: footerLineY))
        footerLine.lineWidth = 0.5
        footerLine.stroke()
        
        // Draw footer
        let footerY = paperSize.height - 30
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.gray
        ]
        
        let printedText = "Printed: \(dateFormatter.string(from: Date()))"
        (printedText as NSString).draw(at: NSPoint(x: leftMargin, y: footerY), withAttributes: footerAttrs)
        
        let pageText = "Page \(currentPageNumber) of \(totalPageCount)"
        let pageWidth = (pageText as NSString).size(withAttributes: footerAttrs).width
        (pageText as NSString).draw(at: NSPoint(x: leftMargin + (contentWidth - pageWidth) / 2, y: footerY), withAttributes: footerAttrs)
        
        if let saveDate = lastSaveDate {
            let savedText = "Saved: \(dateFormatter.string(from: saveDate))"
            let savedWidth = (savedText as NSString).size(withAttributes: footerAttrs).width
            (savedText as NSString).draw(at: NSPoint(x: leftMargin + contentWidth - savedWidth, y: footerY), withAttributes: footerAttrs)
        }
    }
}



