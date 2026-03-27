//
//  ContentView.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var documents: [CodeDocument] = []
    @State private var selectedDocument: CodeDocument?
    @State private var showNewFileSheet = false
    @State private var newFileName = ""
    @State private var newFileLanguage: CodeLanguage = .swift
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var triggerPrint = false
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - File list
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Files")
                        .font(.headline)
                    Spacer()
                    
                    // Open file button
                    Button(action: openFile) {
                        Image(systemName: "folder")
                    }
                    .buttonStyle(.borderless)
                    .help("Open File")
                    
                    // New file button
                    Button(action: { showNewFileSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)
                    .help("New File")
                }
                .padding()
                
                Divider()
                
                // File list
                if documents.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No files")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("Click + to create a new file")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(selection: $selectedDocument) {
                        ForEach(documents) { document in
                            HStack {
                                Image(systemName: "doc.text")
                                    .foregroundStyle(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(document.filename)
                                        .font(.body)
                                    Text(document.language.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if document.isModified {
                                    Circle()
                                        .fill(.orange)
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .tag(document)
                            .contextMenu {
                                Button("Save") {
                                    saveDocument(document)
                                }
                                .disabled(document.fileURL == nil)
                                
                                Button("Delete", role: .destructive) {
                                    deleteDocument(document)
                                }
                            }
                        }
                    }
                }
            }
            .frame(minWidth: 200)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar) {
                        Image(systemName: "sidebar.left")
                    }
                }
            }
        } detail: {
            // Main editor area
            if let document = selectedDocument {
                CodeEditorView(document: document, triggerPrint: $triggerPrint)
            } else {
                // Welcome screen
                VStack(spacing: 20) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 72))
                        .foregroundStyle(.blue)
                    
                    Text("Code Editor")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Create or select a file to start editing")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Button("Create New File") {
                        showNewFileSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features:")
                            .font(.headline)
                        
                        FeatureRow(icon: "paintbrush", title: "Syntax Highlighting", description: "Support for Swift, Python, JavaScript, Java, Apex, C++, HTML, and CSS")
                        FeatureRow(icon: "lightbulb", title: "Code Completion", description: "Intelligent suggestions as you type")
                        FeatureRow(icon: "doc.text", title: "Multiple Files", description: "Work with multiple code files simultaneously")
                        FeatureRow(icon: "folder", title: "Open Local Files", description: "Open and edit files from your computer")
                        FeatureRow(icon: "printer", title: "Print Support", description: "Print your code with syntax highlighting")
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .frame(maxWidth: 500)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showNewFileSheet) {
            NewFileSheet(
                filename: $newFileName,
                language: $newFileLanguage,
                onCreate: createNewFile
            )
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            // Create a sample file if no files exist
            if documents.isEmpty {
                createSampleFile()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .createNewFile)) { _ in
            showNewFileSheet = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .openFile)) { _ in
            openFile()
        }
        .onReceive(NotificationCenter.default.publisher(for: .saveFile)) { _ in
            if let document = selectedDocument {
                saveDocument(document)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .printFile)) { _ in
            triggerPrint.toggle()
        }
    }
    
    // MARK: - File Operations
    
    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = UTType.codeFiles
        panel.message = "Select a code file to open"
        
        panel.begin { response in
            if response == .OK, let url = panel.url {
                do {
                    let document = try CodeDocument.load(from: url)
                    
                    // Check if file is already open
                    if !documents.contains(where: { $0.fileURL == url }) {
                        documents.append(document)
                        selectedDocument = document
                    } else {
                        // Select the already open document
                        selectedDocument = documents.first(where: { $0.fileURL == url })
                    }
                } catch {
                    errorMessage = "Failed to open file: \(error.localizedDescription)"
                    showErrorAlert = true
                }
            }
        }
    }
    
    private func saveDocument(_ document: CodeDocument) {
        do {
            try document.save()
        } catch {
            errorMessage = "Failed to save file: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
    
    private func createNewFile() {
        let document = CodeDocument(
            filename: newFileName.isEmpty ? "Untitled\(newFileLanguage.fileExtension)" : newFileName,
            content: "",
            language: newFileLanguage
        )
        documents.append(document)
        selectedDocument = document
        
        // Reset
        newFileName = ""
        newFileLanguage = .swift
        showNewFileSheet = false
    }
    
    private func deleteDocument(_ document: CodeDocument) {
        if selectedDocument?.id == document.id {
            selectedDocument = nil
        }
        documents.removeAll { $0.id == document.id }
    }
    
    private func createSampleFile() {
        let sampleSwift = CodeDocument(
            filename: "Example.swift",
            content: """
            import SwiftUI
            
            struct ContentView: View {
                @State private var name = "World"
                
                var body: some View {
                    VStack {
                        Text("Hello, \\(name)!")
                            .font(.largeTitle)
                        
                        TextField("Name", text: $name)
                            .textFieldStyle(.roundedBorder)
                            .padding()
                    }
                    .padding()
                }
            }
            """,
            language: .swift
        )
        documents.append(sampleSwift)
        selectedDocument = sampleSwift
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct NewFileSheet: View {
    @Binding var filename: String
    @Binding var language: CodeLanguage
    let onCreate: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New File")
                .font(.title)
                .fontWeight(.bold)
            
            Form {
                TextField("Filename", text: $filename)
                    .textFieldStyle(.roundedBorder)
                
                Picker("Language", selection: $language) {
                    ForEach(CodeLanguage.allCases) { lang in
                        Text(lang.rawValue).tag(lang)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Create") {
                    onCreate()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(filename.isEmpty)
            }
        }
        .padding()
        .frame(width: 400, height: 250)
    }
}

#Preview {
    ContentView()
}
