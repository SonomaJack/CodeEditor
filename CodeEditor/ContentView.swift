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
    @State private var hasLoadedRecentFiles = false
    @State private var showHelpWindow = false
    @State private var showSettingsWindow = false
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .sheet(isPresented: $showNewFileSheet) {
            NewFileSheet(
                filename: $newFileName,
                language: $newFileLanguage,
                onCreate: createNewFile
            )
        }
        .sheet(isPresented: $showHelpWindow) {
            // Temporary placeholder - Add HelpView.swift to your Xcode target to enable full help
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Code Editor Help")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Divider()
                    
                    Text("⌘F - Find")
                    Text("⌥⌘H - Find and Replace")
                    Text("⌘G - Find Next")
                    Text("⇧⌘G - Find Previous")
                    
                    Divider()
                    
                    Text("To enable full help documentation, add HelpView.swift to your Xcode target.")
                        .foregroundStyle(.secondary)
                }
                .padding(24)
            }
            .frame(width: 600, height: 400)
        }
        .sheet(isPresented: $showSettingsWindow) {
            SettingsView()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onAppear {
            loadRecentFiles()
        }
        .onChange(of: documents) { _, newDocuments in
            saveRecentFiles(newDocuments)
        }
        .modifier(NotificationHandlers(
            showNewFileSheet: $showNewFileSheet,
            selectedDocument: selectedDocument,
            triggerPrint: $triggerPrint,
            showHelpWindow: $showHelpWindow,
            showSettingsWindow: $showSettingsWindow,
            onOpenFile: openFile,
            onSaveDocument: { if let doc = selectedDocument { saveDocument(doc) } }
        ))
    }
    
    // MARK: - View Components
    
    private var sidebarContent: some View {
        // Sidebar - File list
        VStack(spacing: 0) {
            sidebarHeader
            
            Divider()
            
            fileList
        }
        .frame(minWidth: 200)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
    
    private var sidebarHeader: some View {
        HStack {
            Text("Files")
                .font(.headline)
            Spacer()
            
            // Open file button
            Button(action: openFile) {
                Image(systemName: "folder")
            }
            .buttonStyle(.borderless)
            .help("Open Files")
            
            // New file button
            Button(action: { showNewFileSheet = true }) {
                Image(systemName: "plus")
            }
            .buttonStyle(.borderless)
            .help("New File")
        }
        .padding()
    }
    
    private var fileList: some View {
        Group {
            if documents.isEmpty {
                emptyFileListView
            } else {
                documentListView
            }
        }
    }
    
    private var emptyFileListView: some View {
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
    }
    
    private var documentListView: some View {
        List(selection: $selectedDocument) {
            ForEach(documents) { document in
                documentRow(for: document)
            }
        }
    }
    
    private func documentRow(for document: CodeDocument) -> some View {
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
    
    private var detailContent: some View {
        Group {
            if let document = selectedDocument {
                CodeEditorView(document: document, triggerPrint: $triggerPrint)
            } else {
                welcomeScreen
            }
        }
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 72))
                .foregroundStyle(.blue)
            
            Text("Code Editor")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(documents.isEmpty ? "Create or open a file to start editing" : "Select a file to start editing")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            welcomeButtons
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var welcomeButtons: some View {
        HStack(spacing: 12) {
            Button("Create New File") {
                showNewFileSheet = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            if documents.isEmpty {
                Button("Open File") {
                    openFile()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }
    
    // MARK: - File Operations
    
    private func openFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = UTType.codeFiles
        panel.message = "Select one or more code files to open"
        
        panel.begin { response in
            if response == .OK {
                var lastOpenedDocument: CodeDocument?
                var errors: [String] = []
                
                for url in panel.urls {
                    do {
                        let document = try CodeDocument.load(from: url)
                        
                        // Check if file is already open
                        if !documents.contains(where: { $0.fileURL == url }) {
                            documents.append(document)
                            lastOpenedDocument = document
                        } else {
                            // Select the already open document
                            lastOpenedDocument = documents.first(where: { $0.fileURL == url })
                        }
                    } catch {
                        errors.append("\(url.lastPathComponent): \(error.localizedDescription)")
                    }
                }
                
                // Select the last successfully opened document
                if let lastDocument = lastOpenedDocument {
                    selectedDocument = lastDocument
                }
                
                // Show errors if any occurred
                if !errors.isEmpty {
                    errorMessage = "Failed to open some files:\n" + errors.joined(separator: "\n")
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
    
    private func loadRecentFiles() {
        let recentDocuments = DocumentPersistence.loadRecentFiles()
        if !recentDocuments.isEmpty {
            documents = recentDocuments
            selectedDocument = recentDocuments.first
            hasLoadedRecentFiles = true
        }
    }
    
    private func saveRecentFiles(_ documents: [CodeDocument]) {
        // Only save documents that have a file URL (i.e., saved files)
        let savedDocuments = documents.filter { $0.fileURL != nil }
        DocumentPersistence.saveRecentFiles(savedDocuments)
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

// MARK: - Notification Handlers ViewModifier

struct NotificationHandlers: ViewModifier {
    @Binding var showNewFileSheet: Bool
    let selectedDocument: CodeDocument?
    @Binding var triggerPrint: Bool
    @Binding var showHelpWindow: Bool
    @Binding var showSettingsWindow: Bool
    let onOpenFile: () -> Void
    let onSaveDocument: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .createNewFile)) { _ in
                showNewFileSheet = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .openFile)) { _ in
                onOpenFile()
            }
            .onReceive(NotificationCenter.default.publisher(for: .saveFile)) { _ in
                onSaveDocument()
            }
            .onReceive(NotificationCenter.default.publisher(for: .printFile)) { _ in
                triggerPrint.toggle()
            }
            .onReceive(NotificationCenter.default.publisher(for: .showHelpWindow)) { _ in
                showHelpWindow = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .showSettings)) { _ in
                showSettingsWindow = true
            }
    }
}

#Preview {
    ContentView()
}
