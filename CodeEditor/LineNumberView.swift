//
//  LineNumberView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI

struct LineNumberView: View {
    let text: String
    
    private var lineCount: Int {
        max(1, text.split(separator: "\n", omittingEmptySubsequences: false).count)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(1...lineCount, id: \.self) { lineNumber in
                    Text("\(lineNumber)")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(height: 16)
                        .padding(.trailing, 8)
                }
            }
            .padding(.top, 4)
        }
        .scrollDisabled(true)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
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
    """)
    .frame(width: 40, height: 300)
}
