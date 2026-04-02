//
//  SnippetsView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI

struct SnippetsView: View {
    @StateObject private var manager = SnippetsManager.shared
    @Environment(\.dismiss) private var dismiss
    let onInsert: (CodeSnippet) -> Void
    let currentLanguage: CodeLanguage
    
    @State private var selectedLanguage: CodeLanguage
    @State private var showNewSnippet = false
    
    init(currentLanguage: CodeLanguage, onInsert: @escaping (CodeSnippet) -> Void) {
        self.currentLanguage = currentLanguage
        self.onInsert = onInsert
        _selectedLanguage = State(initialValue: currentLanguage)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Code Snippets")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Picker("Language", selection: $selectedLanguage) {
                    ForEach(CodeLanguage.allCases) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 180)
                
                Button(action: { showNewSnippet = true }) {
                    Label("New", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            
            Divider()
            
            // Snippets list
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(manager.snippets(for: selectedLanguage)) { snippet in
                        SnippetRow(snippet: snippet) {
                            onInsert(snippet)
                            dismiss()
                        }
                    }
                }
                .padding()
            }
        }
        .frame(width: 700, height: 500)
        .sheet(isPresented: $showNewSnippet) {
            NewSnippetView(language: selectedLanguage)
        }
    }
}

struct SnippetRow: View {
    let snippet: CodeSnippet
    let onInsert: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(snippet.title)
                        .font(.headline)
                    
                    Text(snippet.trigger)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.2))
                        .cornerRadius(4)
                }
                
                Text(snippet.code.prefix(100))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            Button("Insert") {
                onInsert()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct NewSnippetView: View {
    @StateObject private var manager = SnippetsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let language: CodeLanguage
    @State private var title = ""
    @State private var trigger = ""
    @State private var code = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("New Snippet")
                .font(.title2)
                .fontWeight(.bold)
            
            Form {
                TextField("Title", text: $title)
                TextField("Trigger (short code)", text: $trigger)
                
                Text("Code:")
                    .font(.caption)
                
                TextEditor(text: $code)
                    .font(.system(.body, design: .monospaced))
                    .frame(height: 200)
                    .border(Color.secondary.opacity(0.3))
                
                Text("Use <#placeholder#> for insertion points")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                
                Button("Save") {
                    let snippet = CodeSnippet(
                        title: title,
                        code: code,
                        language: language,
                        trigger: trigger
                    )
                    manager.addSnippet(snippet)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(title.isEmpty || trigger.isEmpty || code.isEmpty)
            }
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}

#Preview {
    SnippetsView(currentLanguage: .swift) { _ in }
}
