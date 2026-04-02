//
//  CodeEditorApp.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI

@main
struct CodeEditorApp: App {
    init() {
        // Disable automatic window tabbing
        NSWindow.allowsAutomaticWindowTabbing = false
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
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
                Button("Code Editor Help") {
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
