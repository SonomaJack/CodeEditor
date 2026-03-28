//
//  PrintableCodeView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import AppKit
import SwiftUI

class PrintableTextView: NSTextView {
    
    override var isFlipped: Bool {
        return true
    }
    
    // Override to ensure proper pagination
    override func knowsPageRange(_ range: NSRangePointer) -> Bool {
        guard let layoutManager = layoutManager,
              let textContainer = textContainer,
              let printInfo = NSPrintOperation.current?.printInfo else {
            return false
        }
        
        // Force complete layout
        layoutManager.ensureLayout(for: textContainer)
        
        // Calculate the number of pages
        let paperHeight = printInfo.paperSize.height
        let printableHeight = paperHeight - printInfo.topMargin - printInfo.bottomMargin
        let usedRect = layoutManager.usedRect(for: textContainer)
        
        let pageCount = Int(ceil(usedRect.height / printableHeight))
        range.pointee = NSRange(location: 1, length: max(1, pageCount))
        
        return true
    }
    
    override func rectForPage(_ page: Int) -> NSRect {
        guard let printInfo = NSPrintOperation.current?.printInfo else {
            return bounds
        }
        
        let paperHeight = printInfo.paperSize.height
        let printableHeight = paperHeight - printInfo.topMargin - printInfo.bottomMargin
        
        // Calculate the rect for this page
        let yOffset = CGFloat(page - 1) * printableHeight
        
        return NSRect(
            x: bounds.minX,
            y: yOffset,
            width: bounds.width,
            height: printableHeight
        )
    }
}
