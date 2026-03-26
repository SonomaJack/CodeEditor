import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - EditorActions

struct EditorActions {
    let newFile: () -> Void
    let openFile: () -> Void
    let saveFile: () -> Void
    let saveFileAs: () -> Void
    let printFile: () -> Void
}

// MARK: - EditorActions EnvironmentKey

private struct EditorActionsEnvironmentKey: EnvironmentKey {
    static let defaultValue: EditorActions? = nil
}

extension EnvironmentValues {
    var editorActions: EditorActions? {
        get { self[EditorActionsEnvironmentKey.self] }
        set { self[EditorActionsEnvironmentKey.self] = newValue }
    }
}

// MARK: - EditorActions FocusedValueKey (for menu commands)

struct EditorActionsKey: FocusedValueKey {
    typealias Value = EditorActionsBinding
}

struct EditorActionsBinding {
    let newFile: () -> Void
    let openFile: () -> Void
    let saveFile: () -> Void
    let saveFileAs: () -> Void
    let printFile: () -> Void
}

extension FocusedValues {
    var editorActionsBinding: EditorActionsBinding? {
        get { self[EditorActionsKey.self] }
        set { self[EditorActionsKey.self] = newValue }
    }
}

// MARK: - ContentView

struct ContentView: View {

    @State private var content: String = defaultWelcomeCode
    @State private var selectedLanguage: Language = .swift
    @State private var currentFileURL: URL? = nil
    @State private var rootURL: URL? = nil
    @State private var textView: NSTextView? = nil
    @State private var isDirty: Bool = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    var windowTitle: String {
        let name = currentFileURL?.lastPathComponent ?? "Untitled"
        return isDirty ? "\(name) •" : name
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            FileSidebarView(
                selectedFileURL: $currentFileURL,
                rootURL: $rootURL,
                onFileSelected: openFile
            )
            .navigationSplitViewColumnWidth(min: 160, ideal: 220, max: 400)
        } detail: {
            VStack(spacing: 0) {
                // File info bar
                HStack(spacing: 12) {
                    if let url = currentFileURL {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.text")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                            Text(url.lastPathComponent)
                                .font(.system(size: 12))
                                .foregroundColor(.primary)
                            if isDirty {
                                Circle()
                                    .fill(Color.orange)
                                    .frame(width: 6, height: 6)
                            }
                        }
                    } else {
                        Text("No file opened")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Language picker
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(Language.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 140)
                    .labelsHidden()
                    .controlSize(.small)

                    // Line count
                    Text("\(content.components(separatedBy: "\n").count) lines")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(NSColor.windowBackgroundColor))

                Divider()

                // Editor
                CodeEditorView(
                    content: $content,
                    language: $selectedLanguage,
                    onTextViewCreated: { tv in
                        textView = tv
                    }
                )
                .background(Color(ThemeColors.background))
                .onChange(of: content) { _ in
                    isDirty = true
                }
            }
        }
        .navigationTitle(windowTitle)
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button(action: { toggleSidebar() }) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar")

                Divider()

                Button(action: saveFile) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .help("Save File")

                Button(action: runCode) {
                    Label("Run", systemImage: "play.fill")
                }
                .help("Run (placeholder)")
                .tint(.green)
            }
        }
        .focusedSceneValue(\.editorActionsBinding, EditorActionsBinding(
            newFile: newFile,
            openFile: openFilePanel,
            saveFile: saveFile,
            saveFileAs: saveFileAs,
            printFile: printFile
        ))
        .onReceive(NotificationCenter.default.publisher(for: .openFileURL)) { notification in
            if let url = notification.object as? URL {
                openFile(url: url)
            }
        }
    }

    // MARK: - File Operations

    private func newFile() {
        if isDirty {
            let alert = NSAlert()
            alert.messageText = "Save changes?"
            alert.informativeText = "Do you want to save changes to \(currentFileURL?.lastPathComponent ?? "Untitled")?"
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Don't Save")
            alert.addButton(withTitle: "Cancel")
            let response = alert.runModal()

            switch response {
            case .alertFirstButtonReturn:
                saveFile()
            case .alertSecondButtonReturn:
                break
            default:
                return
            }
        }

        content = ""
        currentFileURL = nil
        selectedLanguage = .swift
        isDirty = false
    }

    private func openFilePanel() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.title = "Open File"

        if panel.runModal() == .OK, let url = panel.url {
            openFile(url: url)
        }
    }

    private func openFile(url: URL) {
        do {
            let fileContent = try String(contentsOf: url, encoding: .utf8)
            content = fileContent
            currentFileURL = url
            selectedLanguage = Language.detect(from: url.pathExtension)
            isDirty = false
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not open file"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .warning
            alert.runModal()
        }
    }

    private func saveFile() {
        guard let url = currentFileURL else {
            saveFileAs()
            return
        }

        do {
            try content.write(to: url, atomically: true, encoding: .utf8)
            isDirty = false
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not save file"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.runModal()
        }
    }

    private func saveFileAs() {
        let panel = NSSavePanel()
        panel.title = "Save File"
        panel.nameFieldStringValue = currentFileURL?.lastPathComponent ?? "untitled.swift"
        panel.canCreateDirectories = true

        if let rootURL = rootURL {
            panel.directoryURL = rootURL
        }

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try content.write(to: url, atomically: true, encoding: .utf8)
                currentFileURL = url
                selectedLanguage = Language.detect(from: url.pathExtension)
                isDirty = false
            } catch {
                let alert = NSAlert()
                alert.messageText = "Could not save file"
                alert.informativeText = error.localizedDescription
                alert.alertStyle = .critical
                alert.runModal()
            }
        }
    }

    private func printFile() {
        guard let tv = textView else { return }
        let filename = currentFileURL?.lastPathComponent ?? "Untitled"
        PrintManager.print(textView: tv, filename: filename)
    }

    private func runCode() {
        let alert = NSAlert()
        alert.messageText = "Run"
        alert.informativeText = "Code execution is not yet implemented. This is a placeholder."
        alert.runModal()
    }

    private func toggleSidebar() {
        if columnVisibility == .all {
            columnVisibility = .detailOnly
        } else {
            columnVisibility = .all
        }
    }
}

// MARK: - Default Welcome Code

private let defaultWelcomeCode = """
// Welcome to CodeEditor!
// A native macOS code editor with syntax highlighting
// and AI-powered completions.

import Foundation

/// A simple greeting function
func greet(name: String) -> String {
    return "Hello, \\(name)! Welcome to CodeEditor."
}

// Features:
// - Syntax highlighting for 14 languages
// - AI completions powered by Claude (set ANTHROPIC_API_KEY)
// - File browser sidebar
// - Line numbers
// - Print with syntax highlighting preserved
// - Dark theme (VS Code Dark+)

struct CodeEditorApp {
    let version = "1.0.0"
    let languages = ["Swift", "Python", "JavaScript", "TypeScript",
                     "Java", "C", "C++", "Go", "Rust", "Ruby",
                     "HTML", "CSS", "JSON", "Plain Text"]

    func run() {
        print(greet(name: "Developer"))
        print("Supported languages: \\(languages.joined(separator: ", "))")
    }
}

let app = CodeEditorApp()
app.run()
"""
