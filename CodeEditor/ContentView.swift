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
    @State private var showWelcome = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    @State private var showSplitView = false
    @State private var splitViewDocument: CodeDocument? = nil
    @State private var showMultiFileSearch = false
    @State private var isDropTargeted = false
    @State private var showFeedback = false
    @State private var showPremiumGate = false
    @State private var premiumFeatureMessage = ""
    
    var body: some View {
        NavigationSplitView {
            sidebarContent
                .background(Color(nsColor: .controlBackgroundColor))
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
            HelpView()
        }
        .sheet(isPresented: $showSettingsWindow) {
            SettingsView()
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showSettingsWindow = false
                        }
                    }
                }
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeSheet(isPresented: $showWelcome)
        }
        .sheet(isPresented: $showFeedback) {
            FeedbackView()
        }
        .sheet(isPresented: $showPremiumGate) {
            PremiumFeatureView(feature: premiumFeatureMessage)
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
            showMultiFileSearch: $showMultiFileSearch,
            showSplitView: $showSplitView,
            showFeedback: $showFeedback,
            onOpenFile: openFile,
            onClearRecentFiles: clearRecentFiles,
            onOpenSpecificFile: openSpecificFile,
            onToggleSplitView: toggleSplitView
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
        .clipped() // Prevent content from extending beyond bounds
        .overlay(
            isDropTargeted ?
                RoundedRectangle(cornerRadius: 0)
                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .padding(2)
                : nil
        )
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
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
                    .tag(document)
                    .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
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
        .contentShape(Rectangle())
        .contextMenu {
            Button("Save") {
                saveDocument(document)
            }
            .disabled(document.fileURL == nil || !document.isModified)
            
            Button("Save As...") {
                saveDocumentAs(document)
            }
            
            Divider()
            
            Button("Show in Finder") {
                showInFinder(document)
            }
            .disabled(document.fileURL == nil)
            
            Divider()
            
            Button("Close") {
                closeDocument(document)
            }
        }
    }
    
    private var detailContent: some View {
        Group {
            if let document = selectedDocument {
                VStack(spacing: 0) {
                    // Tab bar
                    if documents.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                ForEach(documents) { doc in
                                    TabLabel(
                                        document: doc,
                                        isSelected: selectedDocument?.id == doc.id,
                                        onSelect: { selectedDocument = doc },
                                        onClose: { closeDocument(doc) }
                                    )
                                }
                                
                                Spacer()
                                
                                // Split view button (requires SplitViewContainer.swift)
                                if FeatureAccess.canUseSplitView && showSplitView {
                                    Button(action: toggleSplitView) {
                                        Image(systemName: "rectangle.split.2x1.slash")
                                            .font(.system(size: 12))
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 8)
                                    .help("Close Split View")
                                }
                            }
                        }
                        .frame(height: 32)
                        .background(Color(nsColor: .controlBackgroundColor))
                        
                        Divider()
                    }
                    
                    // Editor
                    CodeEditorView(document: document, triggerPrint: $triggerPrint)
                }
                .overlay(
                    isDropTargeted ?
                        RoundedRectangle(cornerRadius: 0)
                            .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                            .padding(4)
                        : nil
                )
                .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                    handleDrop(providers: providers)
                }
            } else {
                welcomeScreen
            }
        }
    }
    
    private struct TabLabel: View {
        let document: CodeDocument
        let isSelected: Bool
        let onSelect: () -> Void
        let onClose: () -> Void
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: "doc.text")
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                
                Text(document.filename)
                    .font(.system(size: 11))
                    .lineLimit(1)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                
                if document.isModified {
                    Circle()
                        .fill(.orange)
                        .frame(width: 6, height: 6)
                }
                
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color(nsColor: .controlBackgroundColor).opacity(0.5) : Color.clear)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect()
            }
        }
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: 20) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 72))
                .foregroundStyle(.blue)
            
            Text("Clarity Code Edit")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(documents.isEmpty ? "Create or open a file to start editing" : "Select a file to start editing")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            if documents.isEmpty {
                Text("Drop files here to open")
                    .font(.callout)
                    .foregroundStyle(.tertiary)
                    .padding(.top, -8)
            }
            
            welcomeButtons
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            isDropTargeted ? 
                Color.accentColor.opacity(0.1) : 
                Color.clear
        )
        .overlay(
            isDropTargeted ?
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 2, dash: [10, 5]))
                    .padding(20)
                : nil
        )
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
        }
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
        panel.allowedContentTypes = [.text, .plainText, .data]
        panel.allowsOtherFileTypes = true
        panel.message = "Select one or more files to open"
        
        panel.begin { response in
            if response == .OK {
                for url in panel.urls {
                    openSpecificFile(url)
                }
            }
        }
    }
    
    private func openSpecificFile(_ url: URL) {
        do {
            let document = try CodeDocument.load(from: url)
            
            // Check if the detected language requires premium
            if !FeatureAccess.canUseLanguage(document.language) {
                // Allow opening the file, but downgrade to plain text
                document.language = .plaintext
                print("⚠️ Opened \(url.lastPathComponent) as plain text (premium language requires upgrade)")
                
                // Show premium notification (non-blocking)
                premiumFeatureMessage = "This file appears to be \(CodeLanguage.detectLanguage(from: url.lastPathComponent).rawValue). Upgrade to Premium for full syntax highlighting and language support."
                showPremiumGate = true
            }
            
            // Check if file is already open
            if !documents.contains(where: { $0.fileURL == url }) {
                documents.append(document)
                selectedDocument = document
            } else {
                // Select the already open document
                selectedDocument = documents.first(where: { $0.fileURL == url })
            }
        } catch {
            errorMessage = "\(url.lastPathComponent): \(error.localizedDescription)"
            showErrorAlert = true
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
    
    private func saveDocumentAs(_ document: CodeDocument) {
        let savePanel = NSSavePanel()
        savePanel.nameFieldStringValue = document.filename
        savePanel.canCreateDirectories = true
        savePanel.isExtensionHidden = false
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                document.fileURL = url
                document.filename = url.lastPathComponent
                saveDocument(document)
            }
        }
    }
    
    private func showInFinder(_ document: CodeDocument) {
        guard let fileURL = document.fileURL else { return }
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }
    
    private func closeDocument(_ document: CodeDocument) {
        if document.isModified {
            // Show alert for unsaved changes
            let alert = NSAlert()
            alert.messageText = "Do you want to save the changes to \"\(document.filename)\"?"
            alert.informativeText = "Your changes will be lost if you don't save them."
            alert.addButton(withTitle: "Save")
            alert.addButton(withTitle: "Cancel")
            alert.addButton(withTitle: "Don't Save")
            alert.alertStyle = .warning
            
            let response = alert.runModal()
            
            switch response {
            case .alertFirstButtonReturn: // Save
                if document.fileURL != nil {
                    saveDocument(document)
                    deleteDocument(document)
                } else {
                    saveDocumentAs(document)
                    deleteDocument(document)
                }
            case .alertThirdButtonReturn: // Don't Save
                deleteDocument(document)
            default: // Cancel
                return
            }
        } else {
            deleteDocument(document)
        }
    }
    
    private func createNewFile() {
        let document = CodeDocument(
            filename: newFileName.isEmpty ? "Untitled\(newFileLanguage.fileExtension)" : newFileName,
            content: "",
            language: newFileLanguage
        )
        
        // If language is plaintext, enable auto-detection for new files
        if newFileLanguage == .plaintext && newFileName.isEmpty {
            document.shouldAutoDetectLanguage = true
        }
        
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
    
    private func clearRecentFiles() {
        DocumentPersistence.clearRecentFiles()
        // Close all unsaved documents
        let unsavedDocs = documents.filter { $0.fileURL == nil }
        if !unsavedDocs.isEmpty {
            documents = unsavedDocs
            selectedDocument = unsavedDocs.first
        } else {
            documents = []
            selectedDocument = nil
        }
    }
    
    private func toggleSplitView() {
        if showSplitView {
            showSplitView = false
            splitViewDocument = nil
        } else {
            // Set split view to the next document after selected
            if let currentIndex = documents.firstIndex(where: { $0.id == selectedDocument?.id }),
               currentIndex + 1 < documents.count {
                splitViewDocument = documents[currentIndex + 1]
                showSplitView = true
            } else if documents.count > 1 {
                splitViewDocument = documents.first(where: { $0.id != selectedDocument?.id })
                showSplitView = true
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    // MARK: - Drag and Drop
    
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            // Load the file URL synchronously
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { (urlData, error) in
                DispatchQueue.main.async {
                    if let urlData = urlData as? Data,
                       let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        
                        // Ensure it's a file URL
                        guard url.isFileURL else { return }
                        
                        // Open any file - will default to plain text if extension not recognized
                        self.openSpecificFile(url)
                    }
                }
            }
        }
        
        return true
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
    @StateObject private var store = StoreManager.shared
    @State private var useAutoDetect = true
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create New File")
                .font(.title)
                .fontWeight(.bold)
            
            Form {
                TextField("Filename (optional)", text: $filename)
                    .textFieldStyle(.roundedBorder)
                
                Toggle("Auto-detect language from content", isOn: $useAutoDetect)
                    .help("Language will be automatically detected as you type")
                
                if !useAutoDetect {
                    Picker("Language", selection: $language) {
                        ForEach(CodeLanguage.sortedLanguages(hasPremium: store.hasPremiumFeatures)) { lang in
                            HStack {
                                Text(lang.rawValue)
                                if !FeatureAccess.canUseLanguage(lang) {
                                    Image(systemName: "lock.fill")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                } else {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .foregroundStyle(.blue)
                        Text("Language will be detected automatically")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Button("Create") {
                    // Set language to plaintext if auto-detect is enabled
                    if useAutoDetect {
                        language = .plaintext
                    }
                    onCreate()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: useAutoDetect ? 230 : 280)
    }
}

// MARK: - Notification Handlers ViewModifier

struct NotificationHandlers: ViewModifier {
    @Binding var showNewFileSheet: Bool
    let selectedDocument: CodeDocument?
    @Binding var triggerPrint: Bool
    @Binding var showHelpWindow: Bool
    @Binding var showSettingsWindow: Bool
    @Binding var showMultiFileSearch: Bool
    @Binding var showSplitView: Bool
    @Binding var showFeedback: Bool
    let onOpenFile: () -> Void
    let onClearRecentFiles: () -> Void
    let onOpenSpecificFile: (URL) -> Void
    let onToggleSplitView: () -> Void
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .createNewFile)) { _ in
                showNewFileSheet = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .openFile)) { _ in
                onOpenFile()
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
            .onReceive(NotificationCenter.default.publisher(for: .clearRecentFiles)) { _ in
                onClearRecentFiles()
            }
            .onReceive(NotificationCenter.default.publisher(for: .openSpecificFile)) { notification in
                if let userInfo = notification.userInfo,
                   let url = userInfo["url"] as? URL {
                    onOpenSpecificFile(url)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .showMultiFileSearch)) { _ in
                showMultiFileSearch = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .toggleSplitView)) { _ in
                onToggleSplitView()
            }
            .onReceive(NotificationCenter.default.publisher(for: .showFeedback)) { _ in
                showFeedback = true
            }
    }
}

struct WelcomeSheet: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "chevron.left.forwardslash.chevron.right")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text("Welcome to Clarity Code Edit")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                QuickTip(icon: "gearshape", text: "Access Settings via Clarity Code Edit menu → Settings... (⌘,)")
                QuickTip(icon: "folder", text: "Recent files auto-load on launch")
                QuickTip(icon: "xmark.circle", text: "Clear recent files via File → Clear Recent Files")
                QuickTip(icon: "tablecells", text: "Click tabs at top to switch between files")
                QuickTip(icon: "plus.magnifyingglass", text: "Zoom: ⌘+ / ⌘- / ⌘0")
                QuickTip(icon: "line.3.horizontal", text: "Go to Line: ⌘L")
                QuickTip(icon: "magnifyingglass", text: "Find: ⌘F | Replace: ⌥⌘H")
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            Button("Get Started") {
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
        .frame(width: 500)
    }
}

struct QuickTip: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.callout)
        }
    }
}

#Preview {
    ContentView()
}
