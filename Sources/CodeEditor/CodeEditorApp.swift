import SwiftUI
import AppKit

// MARK: - App Entry Point

@main
struct CodeEditorApplication: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @FocusedValue(\.editorActionsBinding) var editorActions

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 500)
                .preferredColorScheme(.dark)
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        .commands {
            // Replace default File menu
            CommandGroup(replacing: .newItem) {
                Button("New") {
                    editorActions?.newFile()
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("Open...") {
                    editorActions?.openFile()
                }
                .keyboardShortcut("o", modifiers: .command)

                Divider()

                Button("Save") {
                    editorActions?.saveFile()
                }
                .keyboardShortcut("s", modifiers: .command)

                Button("Save As...") {
                    editorActions?.saveFileAs()
                }
                .keyboardShortcut("s", modifiers: [.command, .shift])
            }

            // Print command
            CommandGroup(after: .importExport) {
                Divider()
                Button("Print...") {
                    editorActions?.printFile()
                }
                .keyboardShortcut("p", modifiers: .command)
            }

            // Standard Edit menu - select all
            CommandGroup(after: .pasteboard) {
                Divider()
                Button("Select All") {
                    NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: nil)
                }
                .keyboardShortcut("a", modifiers: .command)
            }

            // View menu
            CommandMenu("View") {
                Button("Toggle Sidebar") {
                    NSApp.sendAction(NSSelectorFromString("toggleSidebar:"), to: nil, from: nil)
                }
                .keyboardShortcut("b", modifiers: .command)

                Divider()

                Button("Increase Font Size") {
                    NotificationCenter.default.post(name: .increaseFontSize, object: nil)
                }
                .keyboardShortcut("+", modifiers: .command)

                Button("Decrease Font Size") {
                    NotificationCenter.default.post(name: .decreaseFontSize, object: nil)
                }
                .keyboardShortcut("-", modifiers: .command)

                Button("Reset Font Size") {
                    NotificationCenter.default.post(name: .resetFontSize, object: nil)
                }
                .keyboardShortcut("0", modifiers: .command)
            }
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let increaseFontSize = Notification.Name("com.codeeditor.increaseFontSize")
    static let decreaseFontSize = Notification.Name("com.codeeditor.decreaseFontSize")
    static let resetFontSize = Notification.Name("com.codeeditor.resetFontSize")
    static let openFileURL = Notification.Name("com.codeeditor.openFileURL")
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.appearance = NSAppearance(named: .darkAqua)
        handleCommandLineArguments()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        guard let url = urls.first else { return }
        NotificationCenter.default.post(name: .openFileURL, object: url)
    }

    private func handleCommandLineArguments() {
        let args = CommandLine.arguments
        if args.count > 1 {
            let path = args[1]
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: url.path) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    NotificationCenter.default.post(name: .openFileURL, object: url)
                }
            }
        }
    }
}
