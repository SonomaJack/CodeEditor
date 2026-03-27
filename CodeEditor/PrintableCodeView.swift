//
//  PrintableCodeView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import AppKit
import SwiftUI

class PrintableCodeView: NSView {
    private let attributedString: NSAttributedString
    
    init(attributedString: NSAttributedString, frame: NSRect) {
        self.attributedString = attributedString
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        // Draw white background
        NSColor.white.setFill()
        dirtyRect.fill()
        
        // Draw the attributed string
        attributedString.draw(in: bounds.insetBy(dx: 0, dy: 0))
    }
    
    override var isFlipped: Bool {
        return true
    }
    
    // Required for pagination
    override func knowsPageRange(_ range: NSRangePointer) -> Bool {
        return true
    }
    
    override func rectForPage(_ page: Int) -> NSRect {
        // Get print info
        guard let printInfo = NSPrintOperation.current?.printInfo else {
            return bounds
        }
        
        let paperSize = printInfo.paperSize
        let leftMargin = printInfo.leftMargin
        let rightMargin = printInfo.rightMargin
        let topMargin = printInfo.topMargin
        let bottomMargin = printInfo.bottomMargin
        
        let printableWidth = paperSize.width - leftMargin - rightMargin
        let printableHeight = paperSize.height - topMargin - bottomMargin
        
        return NSRect(
            x: leftMargin,
            y: topMargin + (CGFloat(page - 1) * printableHeight),
            width: printableWidth,
            height: printableHeight
        )
    }
}
