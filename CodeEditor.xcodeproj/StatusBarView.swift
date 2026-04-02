//
//  StatusBarView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI

struct StatusBarView: View {
    let document: CodeDocument
    let cursorLine: Int
    let cursorColumn: Int
    let selectionLength: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Language
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.system(size: 10))
                Text(document.language.rawValue)
                    .font(.system(size: 11))
            }
            
            Divider()
                .frame(height: 12)
            
            // Line and Column
            Text("Ln \(cursorLine), Col \(cursorColumn)")
                .font(.system(size: 11))
                .monospacedDigit()
            
            if selectionLength > 0 {
                Text("(\(selectionLength) selected)")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .frame(height: 12)
            
            // Character count
            Text("\(characterCount) chars")
                .font(.system(size: 11))
                .monospacedDigit()
            
            Divider()
                .frame(height: 12)
            
            // Line count
            Text("\(lineCount) lines")
                .font(.system(size: 11))
                .monospacedDigit()
            
            Spacer()
            
            // Encoding
            Text("UTF-8")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            
            // Modified indicator
            if document.isModified {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 6, height: 6)
                    Text("Modified")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor))
    }
    
    private var characterCount: Int {
        document.content.count
    }
    
    private var lineCount: Int {
        document.content.split(separator: "\n", omittingEmptySubsequences: false).count
    }
}

#Preview {
    StatusBarView(
        document: CodeDocument(
            filename: "Example.swift",
            content: "import SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n        Text(\"Hello\")\n    }\n}",
            language: .swift
        ),
        cursorLine: 5,
        cursorColumn: 12,
        selectionLength: 0
    )
}
