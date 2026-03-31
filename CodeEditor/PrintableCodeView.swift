//
//  PrintableCodeView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import AppKit
import SwiftUI

class PrintableTextView: NSTextView {
    
    // Space reserved for header and footer outside the text area
    static let headerSpace: CGFloat = 54  // Matches topMargin in draw method
    static let footerSpace: CGFloat = 54  // Matches bottomMargin in draw method
    
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
        // Account for header and footer space since margins are 0
        let printableHeight = paperHeight - PrintableTextView.headerSpace - PrintableTextView.footerSpace
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
        // Account for header and footer space since margins are 0
        let printableHeight = paperHeight - PrintableTextView.headerSpace - PrintableTextView.footerSpace
        
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
