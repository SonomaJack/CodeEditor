//
//  PrintCoordinator.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import AppKit
import SwiftUI

class PrintCoordinator {
    static func printCode(_ code: String, filename: String, from window: NSWindow?) {
        // Create print info first to get proper dimensions
        let printInfo = NSPrintInfo.shared
        printInfo.topMargin = 72
        printInfo.bottomMargin = 72
        printInfo.leftMargin = 72
        printInfo.rightMargin = 72
        printInfo.horizontalPagination = .fit
        printInfo.verticalPagination = .automatic
        
        // Calculate printable area
        let paperSize = printInfo.paperSize
        let printableWidth = paperSize.width - printInfo.leftMargin - printInfo.rightMargin
        let printableHeight = paperSize.height - printInfo.topMargin - printInfo.bottomMargin
        
        // Create a text storage with the code
        let textStorage = NSTextStorage(string: code)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        // Create a text container with proper size
        let textContainer = NSTextContainer(size: NSSize(width: printableWidth, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = false
        layoutManager.addTextContainer(textContainer)
        
        // Create a text view with proper frame
        let textView = NSTextView(frame: NSRect(x: 0, y: 0, width: printableWidth, height: printableHeight))
        textView.textContainer = textContainer
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
        textView.textColor = NSColor.black
        textView.backgroundColor = NSColor.white
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        
        // Apply font to all text
        textStorage.addAttribute(.font, value: NSFont.monospacedSystemFont(ofSize: 10, weight: .regular), range: NSRange(location: 0, length: textStorage.length))
        
        // Force layout
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        
        // Create print operation
        let printOperation = NSPrintOperation(view: textView, printInfo: printInfo)
        printOperation.jobTitle = filename
        printOperation.showsPrintPanel = true
        printOperation.showsProgressPanel = true
        
        // Run print operation on main thread
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
