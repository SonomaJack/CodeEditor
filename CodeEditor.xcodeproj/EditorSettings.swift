//
//  EditorSettings.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import Foundation
import SwiftUI

/// User preferences for the editor
@Observable
class EditorSettings {
    static let shared = EditorSettings()
    
    // Appearance
    var fontSize: CGFloat = 13
    var fontName: String = "Menlo"
    var theme: EditorTheme = .system
    var showLineNumbers: Bool = true
    var lineWrapping: Bool = false
    var showStatusBar: Bool = true
    
    // Indentation
    var tabSize: Int = 4
    var useSpaces: Bool = true
    var autoIndent: Bool = true
    
    // Behavior
    var autoSave: Bool = false
    var autoSaveDelay: TimeInterval = 2.0
    var showInvisibles: Bool = false
    var highlightCurrentLine: Bool = true
    
    private init() {
        loadSettings()
    }
    
    func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "EditorSettings"),
           let decoded = try? JSONDecoder().decode(EditorSettingsData.self, from: data) {
            fontSize = decoded.fontSize
            fontName = decoded.fontName
            theme = decoded.theme
            showLineNumbers = decoded.showLineNumbers
            lineWrapping = decoded.lineWrapping
            showStatusBar = decoded.showStatusBar
            tabSize = decoded.tabSize
            useSpaces = decoded.useSpaces
            autoIndent = decoded.autoIndent
            autoSave = decoded.autoSave
            autoSaveDelay = decoded.autoSaveDelay
            showInvisibles = decoded.showInvisibles
            highlightCurrentLine = decoded.highlightCurrentLine
        }
    }
    
    func saveSettings() {
        let data = EditorSettingsData(
            fontSize: fontSize,
            fontName: fontName,
            theme: theme,
            showLineNumbers: showLineNumbers,
            lineWrapping: lineWrapping,
            showStatusBar: showStatusBar,
            tabSize: tabSize,
            useSpaces: useSpaces,
            autoIndent: autoIndent,
            autoSave: autoSave,
            autoSaveDelay: autoSaveDelay,
            showInvisibles: showInvisibles,
            highlightCurrentLine: highlightCurrentLine
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: "EditorSettings")
        }
    }
}

struct EditorSettingsData: Codable {
    var fontSize: CGFloat
    var fontName: String
    var theme: EditorTheme
    var showLineNumbers: Bool
    var lineWrapping: Bool
    var showStatusBar: Bool
    var tabSize: Int
    var useSpaces: Bool
    var autoIndent: Bool
    var autoSave: Bool
    var autoSaveDelay: TimeInterval
    var showInvisibles: Bool
    var highlightCurrentLine: Bool
}

enum EditorTheme: String, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case solarizedLight = "Solarized Light"
    case solarizedDark = "Solarized Dark"
    case monokai = "Monokai"
    case tomorrow = "Tomorrow"
    case tomorrowNight = "Tomorrow Night"
    
    var isDark: Bool {
        switch self {
        case .dark, .solarizedDark, .monokai, .tomorrowNight:
            return true
        case .light, .solarizedLight, .tomorrow:
            return false
        case .system:
            return NSApp.effectiveAppearance.name == .darkAqua
        }
    }
}
