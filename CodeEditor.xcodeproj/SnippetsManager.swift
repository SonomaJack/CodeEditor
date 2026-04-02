//
//  SnippetsManager.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import Foundation

struct CodeSnippet: Identifiable, Codable {
    let id: UUID
    var title: String
    var code: String
    var language: CodeLanguage
    var trigger: String // Short text to trigger snippet
    
    init(id: UUID = UUID(), title: String, code: String, language: CodeLanguage, trigger: String) {
        self.id = id
        self.title = title
        self.code = code
        self.language = language
        self.trigger = trigger
    }
}

class SnippetsManager: ObservableObject {
    static let shared = SnippetsManager()
    
    @Published var snippets: [CodeSnippet] = []
    
    private let snippetsKey = "savedSnippets"
    
    init() {
        loadSnippets()
        if snippets.isEmpty {
            createDefaultSnippets()
        }
    }
    
    func addSnippet(_ snippet: CodeSnippet) {
        snippets.append(snippet)
        saveSnippets()
    }
    
    func deleteSnippet(_ snippet: CodeSnippet) {
        snippets.removeAll { $0.id == snippet.id }
        saveSnippets()
    }
    
    func updateSnippet(_ snippet: CodeSnippet) {
        if let index = snippets.firstIndex(where: { $0.id == snippet.id }) {
            snippets[index] = snippet
            saveSnippets()
        }
    }
    
    func snippets(for language: CodeLanguage) -> [CodeSnippet] {
        snippets.filter { $0.language == language }
    }
    
    private func saveSnippets() {
        if let encoded = try? JSONEncoder().encode(snippets) {
            UserDefaults.standard.set(encoded, forKey: snippetsKey)
        }
    }
    
    private func loadSnippets() {
        if let data = UserDefaults.standard.data(forKey: snippetsKey),
           let decoded = try? JSONDecoder().decode([CodeSnippet].self, from: data) {
            snippets = decoded
        }
    }
    
    private func createDefaultSnippets() {
        // Swift snippets
        snippets.append(CodeSnippet(
            title: "SwiftUI View",
            code: """
            struct <#Name#>View: View {
                var body: some View {
                    <#content#>
                }
            }
            """,
            language: .swift,
            trigger: "view"
        ))
        
        snippets.append(CodeSnippet(
            title: "Function",
            code: """
            func <#name#>(<#parameters#>) -> <#ReturnType#> {
                <#code#>
            }
            """,
            language: .swift,
            trigger: "func"
        ))
        
        // Python snippets
        snippets.append(CodeSnippet(
            title: "Python Function",
            code: """
            def <#function_name#>(<#parameters#>):
                <#code#>
                return <#value#>
            """,
            language: .python,
            trigger: "def"
        ))
        
        snippets.append(CodeSnippet(
            title: "Python Class",
            code: """
            class <#ClassName#>:
                def __init__(self, <#parameters#>):
                    <#initialization#>
            """,
            language: .python,
            trigger: "class"
        ))
        
        // JavaScript snippets
        snippets.append(CodeSnippet(
            title: "Arrow Function",
            code: """
            const <#name#> = (<#params#>) => {
                <#code#>
            };
            """,
            language: .javascript,
            trigger: "arrow"
        ))
        
        snippets.append(CodeSnippet(
            title: "React Component",
            code: """
            function <#ComponentName#>() {
                return (
                    <<#element#>>
                        <#content#>
                    </<#element#>>
                );
            }
            """,
            language: .javascript,
            trigger: "rfc"
        ))
        
        // HTML snippets
        snippets.append(CodeSnippet(
            title: "HTML5 Template",
            code: """
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title><#Title#></title>
            </head>
            <body>
                <#content#>
            </body>
            </html>
            """,
            language: .html,
            trigger: "html5"
        ))
        
        saveSnippets()
    }
}
