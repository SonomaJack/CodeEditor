//
//  GoToLineView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI

struct GoToLineView: View {
    @Binding var isPresented: Bool
    let totalLines: Int
    let onGoToLine: (Int) -> Void
    
    @State private var lineNumber = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Go to Line")
                .font(.headline)
            
            HStack {
                Text("Line:")
                    .font(.body)
                
                TextField("", text: $lineNumber)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                    .focused($isFocused)
                    .onSubmit {
                        goToLine()
                    }
                
                Text("(1-\(totalLines))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Go") {
                    goToLine()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(!isValidLineNumber)
            }
        }
        .padding()
        .frame(width: 300)
        .onAppear {
            isFocused = true
        }
    }
    
    private var isValidLineNumber: Bool {
        guard let line = Int(lineNumber) else { return false }
        return line >= 1 && line <= totalLines
    }
    
    private func goToLine() {
        guard let line = Int(lineNumber), line >= 1, line <= totalLines else { return }
        onGoToLine(line)
        isPresented = false
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    GoToLineView(
        isPresented: $isPresented,
        totalLines: 100,
        onGoToLine: { line in
            print("Go to line \(line)")
        }
    )
}
