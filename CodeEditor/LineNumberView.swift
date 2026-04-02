//
//  LineNumberView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI
import AppKit

struct LineNumberView: NSViewRepresentable {
    let text: String
    let fontSize: CGFloat
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = NSTextView()
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = true
        scrollView.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.5)
        
        textView.isEditable = false
        textView.isSelectable = false
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 0, height: 0)
        textView.textContainer?.lineFragmentPadding = 0
        textView.alignment = .right
        textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        textView.textColor = NSColor.secondaryLabelColor
        
        updateLineNumbers(textView: textView)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // Update font size if changed
        if textView.font?.pointSize != fontSize {
            textView.font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        }
        
        updateLineNumbers(textView: textView)
    }
    
    private func updateLineNumbers(textView: NSTextView) {
        let lineCount = max(1, text.split(separator: "\n", omittingEmptySubsequences: false).count)
        let numbers = (1...lineCount).map { "\($0)" }.joined(separator: "\n")
        textView.string = numbers
    }
}

#Preview {
    LineNumberView(text: """
    import SwiftUI
    
    struct ContentView: View {
        var body: some View {
            Text("Hello, World!")
        }
    }
    """, fontSize: 13)
    .frame(width: 40, height: 300)
}
