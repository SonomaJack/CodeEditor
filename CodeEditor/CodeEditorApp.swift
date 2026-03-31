//
//  CodeEditorApp.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import SwiftUI

@main
struct CodeEditorApp: App {
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
                
                Button("Find Next") {
                    NotificationCenter.default.post(name: .findNext, object: nil)
                }
                .keyboardShortcut("g", modifiers: [.command])
                
                Button("Find Previous") {
                    NotificationCenter.default.post(name: .findPrevious, object: nil)
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
            }
            
            CommandGroup(replacing: .saveItem) {
                Button("Save") {
                    NotificationCenter.default.post(name: .saveFile, object: nil)
                }
                .keyboardShortcut("s", modifiers: [.command])
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
    static let saveFile = Notification.Name("saveFile")
    static let printFile = Notification.Name("printFile")
    static let showFind = Notification.Name("showFind")
    static let showReplace = Notification.Name("showReplace")
    static let findNext = Notification.Name("findNext")
    static let findPrevious = Notification.Name("findPrevious")
    static let showHelpWindow = Notification.Name("showHelpWindow")
    static let showSettings = Notification.Name("showSettings")
}
