//
//  CodeEditorApp.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI

@main
struct CodeEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Disable automatic window tabbing
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleURL(url)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 800)
        .handlesExternalEvents(matching: Set(arrayLiteral: "main"))
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New File...") {
                    NotificationCenter.default.post(name: .createNewFile, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])
                
                Button("Open...") {
                    NotificationCenter.default.post(name: .openFile, object: nil)
                }
                .keyboardShortcut("o", modifiers: [.command])
                
                Divider()
                
                Menu("Open Recent") {
                    if let paths = UserDefaults.standard.stringArray(forKey: "recentFiles"), !paths.isEmpty {
                        ForEach(paths.prefix(10), id: \.self) { path in
                            Button(URL(fileURLWithPath: path).lastPathComponent) {
                                NotificationCenter.default.post(
                                    name: .openRecentFile,
                                    object: nil,
                                    userInfo: ["path": path]
                                )
                            }
                        }
                        
                        Divider()
                        
                        Button("Clear Recent Files") {
                            NotificationCenter.default.post(name: .clearRecentFiles, object: nil)
                        }
                    } else {
                        Text("No Recent Files")
                            .disabled(true)
                    }
                }
            }
            
            // Edit Menu
            
            CommandGroup(after: .pasteboard) {
                Divider()
                
                Button("Find...") {
                    NotificationCenter.default.post(name: .showFind, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command])
                
                Button("Find and Replace...") {
                    NotificationCenter.default.post(name: .showReplace, object: nil)
                }
                .keyboardShortcut("h", modifiers: [.command, .option])
                
                Button("Find in All Files...") {
                    NotificationCenter.default.post(name: .showMultiFileSearch, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
                
                Button("Find Next") {
                    NotificationCenter.default.post(name: .findNext, object: nil)
                }
                .keyboardShortcut("g", modifiers: [.command])
                
                Button("Find Previous") {
                    NotificationCenter.default.post(name: .findPrevious, object: nil)
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Go to Line...") {
                    NotificationCenter.default.post(name: .goToLine, object: nil)
                }
                .keyboardShortcut("l", modifiers: [.command])
                
                Button("Insert Snippet...") {
                    NotificationCenter.default.post(name: .showSnippets, object: nil)
                }
                .keyboardShortcut("k", modifiers: [.command, .option])
            }
            
            // View Menu
            CommandGroup(after: .sidebar) {
                Button("Zoom In") {
                    NotificationCenter.default.post(name: .zoomIn, object: nil)
                }
                .keyboardShortcut("+", modifiers: [.command])
                
                Button("Zoom Out") {
                    NotificationCenter.default.post(name: .zoomOut, object: nil)
                }
                .keyboardShortcut("-", modifiers: [.command])
                
                Button("Reset Zoom") {
                    NotificationCenter.default.post(name: .resetZoom, object: nil)
                }
                .keyboardShortcut("0", modifiers: [.command])
                
                Divider()
                
                Button("Split View") {
                    NotificationCenter.default.post(name: .toggleSplitView, object: nil)
                }
                .keyboardShortcut("d", modifiers: [.command, .option])
            }
            
            CommandGroup(replacing: .saveItem) {
                Button("Save") {
                    NotificationCenter.default.post(name: .saveFile, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command])
                
                Button("Save As...") {
                    NotificationCenter.default.post(name: .saveFileAs, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }
            
            CommandGroup(replacing: .printItem) {
                Button("Print...") {
                    NotificationCenter.default.post(name: .printFile, object: nil)
                }
                .keyboardShortcut("p", modifiers: [.command])
            }
            
            // Help Menu
            CommandGroup(replacing: .help) {
                Button("Clarity Code Edit Help") {
                    NotificationCenter.default.post(name: .showHelpWindow, object: nil)
                }
                .keyboardShortcut("/", modifiers: [.command])
                
                Divider()
                
                Button("Send Feedback...") {
                    NotificationCenter.default.post(name: .showFeedback, object: nil)
                }
            }
            
            // Settings Menu
            CommandGroup(after: .appInfo) {
                Button("Settings...") {
                    NotificationCenter.default.post(name: .showSettings, object: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
                
                Divider()
            }
        }
    }
    
    // MARK: - URL Handling
    private func handleURL(_ url: URL) {
        guard url.scheme == "codeeditor" else { return }
        
        switch url.host {
        case "help":
            // Open help window
            NotificationCenter.default.post(name: .showHelpWindow, object: nil)
        case "settings":
            // Open settings
            NotificationCenter.default.post(name: .showSettings, object: nil)
        case "feedback":
            // Open feedback
            NotificationCenter.default.post(name: .showFeedback, object: nil)
        default:
            print("⚠️ Unknown URL: \(url)")
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let createNewFile = Notification.Name("createNewFile")
    static let openFile = Notification.Name("openFile")
    static let openRecentFile = Notification.Name("openRecentFile")
    static let saveFile = Notification.Name("saveFile")
    static let printFile = Notification.Name("printFile")
    static let showFind = Notification.Name("showFind")
    static let showReplace = Notification.Name("showReplace")
    static let findNext = Notification.Name("findNext")
    static let findPrevious = Notification.Name("findPrevious")
    static let goToLine = Notification.Name("goToLine")
    static let zoomIn = Notification.Name("zoomIn")
    static let zoomOut = Notification.Name("zoomOut")
    static let resetZoom = Notification.Name("resetZoom")
    static let showHelpWindow = Notification.Name("showHelpWindow")
    static let showSettings = Notification.Name("showSettings")
    static let clearRecentFiles = Notification.Name("clearRecentFiles")
    static let openSpecificFile = Notification.Name("openSpecificFile")
    static let toggleSplitView = Notification.Name("toggleSplitView")
    static let showMultiFileSearch = Notification.Name("showMultiFileSearch")
    static let showSnippets = Notification.Name("showSnippets")
    static let saveFileAs = Notification.Name("saveFileAs")
    static let showFeedback = Notification.Name("showFeedback")
}

// MARK: - App Delegate for File Handling
class AppDelegate: NSObject, NSApplicationDelegate {
    private var hasHandledInitialOpen = false
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Open a new window if there are no visible windows
            if let window = NSApp.windows.first {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
    
    func application(_ application: NSApplication, open urls: [URL]) {
        // Handle files dropped on the Dock icon or opened via "Open With"
        print("📂 Attempting to open \(urls.count) file(s)")
        
        // Give the app a moment to finish launching if needed
        DispatchQueue.main.async { [weak self] in
            self?.openFilesInExistingWindow(urls)
        }
    }
    
    private func openFilesInExistingWindow(_ urls: [URL]) {
        // Find the most appropriate window
        var targetWindow: NSWindow?
        
        // Priority 1: Key window (frontmost)
        if let keyWindow = NSApp.keyWindow, keyWindow.isVisible {
            targetWindow = keyWindow
            print("📂 Using key window")
        }
        // Priority 2: Any visible window
        else if let visibleWindow = NSApp.windows.first(where: { $0.isVisible && !$0.title.isEmpty }) {
            targetWindow = visibleWindow
            print("📂 Using visible window")
        }
        // Priority 3: Any window at all
        else if let anyWindow = NSApp.windows.first(where: { !$0.title.isEmpty }) {
            targetWindow = anyWindow
            print("📂 Using any available window")
        }
        
        // Bring window to front if we found one
        if let window = targetWindow {
            window.makeKeyAndOrderFront(self)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            print("📂 No window found - one will be created")
        }
        
        // Small delay to ensure window is ready
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Post notifications to open each file
            for url in urls {
                print("📂 Opening file: \(url.lastPathComponent)")
                NotificationCenter.default.post(
                    name: .openSpecificFile,
                    object: nil,
                    userInfo: ["url": url]
                )
            }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Register for file open events
        NSApp.servicesProvider = self
        hasHandledInitialOpen = true
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
