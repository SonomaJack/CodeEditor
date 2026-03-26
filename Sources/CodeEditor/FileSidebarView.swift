import SwiftUI
import AppKit

// MARK: - FileNode

final class FileNode: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let url: URL
    let isDirectory: Bool
    @Published var children: [FileNode]?
    @Published var isExpanded: Bool = false

    init(url: URL) {
        self.url = url
        self.name = url.lastPathComponent
        var isDir: ObjCBool = false
        FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir)
        self.isDirectory = isDir.boolValue

        if self.isDirectory {
            self.children = []
        }
    }

    func loadChildren() {
        guard isDirectory else { return }

        do {
            let contents = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isDirectoryKey, .nameKey],
                options: [.skipsHiddenFiles]
            )

            let sortedContents = contents.sorted { a, b in
                var aIsDir: ObjCBool = false
                var bIsDir: ObjCBool = false
                FileManager.default.fileExists(atPath: a.path, isDirectory: &aIsDir)
                FileManager.default.fileExists(atPath: b.path, isDirectory: &bIsDir)

                if aIsDir.boolValue != bIsDir.boolValue {
                    return aIsDir.boolValue
                }
                return a.lastPathComponent.localizedCaseInsensitiveCompare(b.lastPathComponent) == .orderedAscending
            }

            self.children = sortedContents.map { FileNode(url: $0) }
        } catch {
            self.children = []
        }
    }

    var fileIcon: String {
        if isDirectory {
            return isExpanded ? "folder.fill" : "folder"
        }
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "swift": return "swift"
        case "py": return "terminal"
        case "js", "ts", "jsx", "tsx": return "j.square"
        case "java": return "cup.and.saucer"
        case "go": return "g.square"
        case "rs": return "r.square"
        case "html", "htm": return "globe"
        case "css", "scss": return "paintbrush"
        case "json": return "curlybraces"
        case "md", "txt": return "doc.text"
        case "c", "cpp", "h", "hpp": return "c.square"
        case "rb": return "r.circle"
        default: return "doc"
        }
    }

    var iconColor: Color {
        if isDirectory {
            return .yellow
        }
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "swift": return Color(hex: "#FA7343")
        case "py": return Color(hex: "#3572A5")
        case "js": return Color(hex: "#F1E05A")
        case "ts": return Color(hex: "#2B7489")
        case "jsx", "tsx": return Color(hex: "#61DAFB")
        case "java": return Color(hex: "#B07219")
        case "go": return Color(hex: "#00ADD8")
        case "rs": return Color(hex: "#DEA584")
        case "html", "htm": return Color(hex: "#E34C26")
        case "css", "scss": return Color(hex: "#563D7C")
        case "json": return Color(hex: "#C6C6C6")
        case "c", "h": return Color(hex: "#555555")
        case "cpp", "hpp": return Color(hex: "#F34B7D")
        case "rb": return Color(hex: "#CC342D")
        default: return .secondary
        }
    }
}

extension Color {
    init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }
        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - FileSidebarView

struct FileSidebarView: View {

    @Binding var selectedFileURL: URL?
    @Binding var rootURL: URL?
    var onFileSelected: (URL) -> Void

    @State private var rootNodes: [FileNode] = []
    @State private var showNewFileDialog = false
    @State private var showNewFolderDialog = false
    @State private var newItemName = ""
    @State private var showDeleteConfirm = false
    @State private var selectedNode: FileNode?
    @State private var newItemIsFolder = false
    @State private var alertMessage = ""
    @State private var showAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("EXPLORER")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "#BBBBBB"))
                    .tracking(1)
                Spacer()
                HStack(spacing: 4) {
                    Button(action: createNewFile) {
                        Image(systemName: "doc.badge.plus")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Color(hex: "#BBBBBB"))
                    .help("New File")

                    Button(action: createNewFolder) {
                        Image(systemName: "folder.badge.plus")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Color(hex: "#BBBBBB"))
                    .help("New Folder")

                    Button(action: openFolder) {
                        Image(systemName: "folder")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(Color(hex: "#BBBBBB"))
                    .help("Open Folder")

                    Button(action: deleteSelected) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(selectedNode != nil ? Color(hex: "#BBBBBB") : Color(hex: "#555555"))
                    .disabled(selectedNode == nil)
                    .help("Delete")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(hex: "#252526"))

            Divider()
                .background(Color(hex: "#3C3C3C"))

            if rootNodes.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "folder.badge.plus")
                        .font(.system(size: 32))
                        .foregroundColor(Color(hex: "#858585"))
                    Text("No folder opened")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#858585"))
                    Button("Open Folder") {
                        openFolder()
                    }
                    .buttonStyle(.bordered)
                    .font(.system(size: 12))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(hex: "#1E1E1E"))
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(rootNodes) { node in
                            FileNodeView(
                                node: node,
                                selectedNode: $selectedNode,
                                selectedFileURL: $selectedFileURL,
                                level: 0,
                                onFileSelected: { url in
                                    onFileSelected(url)
                                }
                            )
                        }
                    }
                    .padding(.top, 4)
                }
                .background(Color(hex: "#1E1E1E"))
            }
        }
        .background(Color(hex: "#1E1E1E"))
        .sheet(isPresented: $showNewFileDialog) {
            NewItemDialog(
                isPresented: $showNewFileDialog,
                name: $newItemName,
                title: newItemIsFolder ? "New Folder" : "New File",
                placeholder: newItemIsFolder ? "folder-name" : "filename.swift"
            ) {
                createItem(isFolder: newItemIsFolder)
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage)
        }
        .onChange(of: rootURL) { newURL in
            if let url = newURL {
                loadDirectory(url: url)
            }
        }
        .onAppear {
            if let url = rootURL {
                loadDirectory(url: url)
            }
        }
    }

    private func loadDirectory(url: URL) {
        let rootNode = FileNode(url: url)
        rootNode.loadChildren()
        rootNode.isExpanded = true
        rootNodes = [rootNode]
    }

    private func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.title = "Open Folder"
        panel.prompt = "Open"

        if panel.runModal() == .OK, let url = panel.url {
            rootURL = url
            loadDirectory(url: url)
        }
    }

    private func createNewFile() {
        newItemIsFolder = false
        newItemName = ""
        showNewFileDialog = true
    }

    private func createNewFolder() {
        newItemIsFolder = true
        newItemName = ""
        showNewFileDialog = true
    }

    private func createItem(isFolder: Bool) {
        guard !newItemName.isEmpty else { return }

        let baseURL = selectedNode?.isDirectory == true ? selectedNode!.url :
                      (selectedNode?.url.deletingLastPathComponent() ?? rootURL)

        guard let baseURL = baseURL else {
            alertMessage = "No folder selected"
            showAlert = true
            return
        }

        let newURL = baseURL.appendingPathComponent(newItemName)

        do {
            if isFolder {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: true)
            } else {
                FileManager.default.createFile(atPath: newURL.path, contents: Data())
            }

            if let rootURL = rootURL {
                loadDirectory(url: rootURL)
            }

            if !isFolder {
                onFileSelected(newURL)
                selectedFileURL = newURL
            }
        } catch {
            alertMessage = "Failed to create: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func deleteSelected() {
        guard let node = selectedNode else { return }

        let alert = NSAlert()
        alert.messageText = "Delete \(node.name)?"
        alert.informativeText = "This action cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            do {
                try FileManager.default.removeItem(at: node.url)
                selectedNode = nil
                if let rootURL = rootURL {
                    loadDirectory(url: rootURL)
                }
            } catch {
                alertMessage = "Failed to delete: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

// MARK: - FileNodeView

struct FileNodeView: View {

    @ObservedObject var node: FileNode
    @Binding var selectedNode: FileNode?
    @Binding var selectedFileURL: URL?
    let level: Int
    let onFileSelected: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                // Indentation
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: CGFloat(level * 16 + 8))

                // Expand/collapse arrow for directories
                if node.isDirectory {
                    Image(systemName: node.isExpanded ? "chevron.down" : "chevron.right")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(Color(hex: "#BBBBBB"))
                        .frame(width: 12)
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 12)
                }

                Spacer().frame(width: 4)

                // File/folder icon
                Image(systemName: node.fileIcon)
                    .font(.system(size: 13))
                    .foregroundColor(node.iconColor)
                    .frame(width: 16)

                Spacer().frame(width: 6)

                // File name
                Text(node.name)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: "#CCCCCC"))
                    .lineLimit(1)
                    .truncationMode(.middle)

                Spacer()
            }
            .padding(.vertical, 2)
            .padding(.trailing, 8)
            .background(
                selectedNode?.id == node.id ?
                Color(hex: "#094771") :
                (selectedFileURL == node.url ? Color(hex: "#37373D") : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                selectedNode = node
                if node.isDirectory {
                    node.isExpanded.toggle()
                    if node.isExpanded && (node.children?.isEmpty ?? true) {
                        node.loadChildren()
                    }
                } else {
                    onFileSelected(node.url)
                    selectedFileURL = node.url
                }
            }
            .contextMenu {
                if !node.isDirectory {
                    Button("Open") {
                        onFileSelected(node.url)
                        selectedFileURL = node.url
                    }
                    Divider()
                }
                Button("Reveal in Finder") {
                    NSWorkspace.shared.activateFileViewerSelecting([node.url])
                }
            }

            // Children
            if node.isDirectory && node.isExpanded {
                ForEach(node.children ?? []) { child in
                    FileNodeView(
                        node: child,
                        selectedNode: $selectedNode,
                        selectedFileURL: $selectedFileURL,
                        level: level + 1,
                        onFileSelected: onFileSelected
                    )
                }
            }
        }
    }
}

// MARK: - NewItemDialog

struct NewItemDialog: View {
    @Binding var isPresented: Bool
    @Binding var name: String
    let title: String
    let placeholder: String
    let onCreate: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.headline)

            TextField(placeholder, text: $name)
                .textFieldStyle(.roundedBorder)
                .frame(width: 300)
                .onSubmit {
                    if !name.isEmpty {
                        isPresented = false
                        onCreate()
                    }
                }

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)

                Button("Create") {
                    isPresented = false
                    onCreate()
                }
                .keyboardShortcut(.return)
                .disabled(name.isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
