//
//  ThemeColors.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI
import AppKit

struct ThemeColors {
    let background: NSColor
    let text: NSColor
    let keyword: NSColor
    let string: NSColor
    let comment: NSColor
    let number: NSColor
    let function: NSColor
    let type: NSColor
    let variable: NSColor
    let currentLineHighlight: NSColor
    
    static func colors(for theme: EditorTheme) -> ThemeColors {
        switch theme {
        case .system:
            return NSApp.effectiveAppearance.name == .darkAqua ? colors(for: .dark) : colors(for: .light)
            
        case .light:
            return ThemeColors(
                background: .white,
                text: NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0),
                keyword: NSColor(red: 0.6, green: 0.2, blue: 0.6, alpha: 1.0),
                string: NSColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0),
                comment: NSColor(red: 0.4, green: 0.5, blue: 0.4, alpha: 1.0),
                number: NSColor(red: 0.1, green: 0.3, blue: 0.8, alpha: 1.0),
                function: NSColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0),
                type: NSColor(red: 0.4, green: 0.3, blue: 0.6, alpha: 1.0),
                variable: NSColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0),
                currentLineHighlight: NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            )
            
        case .dark:
            return ThemeColors(
                background: NSColor(red: 0.15, green: 0.15, blue: 0.16, alpha: 1.0),
                text: NSColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0),
                keyword: NSColor(red: 0.9, green: 0.4, blue: 0.7, alpha: 1.0),
                string: NSColor(red: 0.95, green: 0.4, blue: 0.4, alpha: 1.0),
                comment: NSColor(red: 0.5, green: 0.6, blue: 0.5, alpha: 1.0),
                number: NSColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 1.0),
                function: NSColor(red: 0.4, green: 0.7, blue: 0.9, alpha: 1.0),
                type: NSColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0),
                variable: NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0),
                currentLineHighlight: NSColor(red: 0.2, green: 0.2, blue: 0.22, alpha: 1.0)
            )
            
        case .solarizedLight:
            return ThemeColors(
                background: NSColor(red: 0.99, green: 0.96, blue: 0.89, alpha: 1.0),
                text: NSColor(red: 0.40, green: 0.48, blue: 0.51, alpha: 1.0),
                keyword: NSColor(red: 0.51, green: 0.58, blue: 0.0, alpha: 1.0),
                string: NSColor(red: 0.16, green: 0.63, blue: 0.60, alpha: 1.0),
                comment: NSColor(red: 0.58, green: 0.63, blue: 0.63, alpha: 1.0),
                number: NSColor(red: 0.86, green: 0.20, blue: 0.18, alpha: 1.0),
                function: NSColor(red: 0.15, green: 0.55, blue: 0.82, alpha: 1.0),
                type: NSColor(red: 0.71, green: 0.54, blue: 0.0, alpha: 1.0),
                variable: NSColor(red: 0.40, green: 0.48, blue: 0.51, alpha: 1.0),
                currentLineHighlight: NSColor(red: 0.93, green: 0.91, blue: 0.84, alpha: 1.0)
            )
            
        case .solarizedDark:
            return ThemeColors(
                background: NSColor(red: 0.0, green: 0.17, blue: 0.21, alpha: 1.0),
                text: NSColor(red: 0.51, green: 0.58, blue: 0.59, alpha: 1.0),
                keyword: NSColor(red: 0.51, green: 0.58, blue: 0.0, alpha: 1.0),
                string: NSColor(red: 0.16, green: 0.63, blue: 0.60, alpha: 1.0),
                comment: NSColor(red: 0.36, green: 0.43, blue: 0.44, alpha: 1.0),
                number: NSColor(red: 0.86, green: 0.20, blue: 0.18, alpha: 1.0),
                function: NSColor(red: 0.15, green: 0.55, blue: 0.82, alpha: 1.0),
                type: NSColor(red: 0.71, green: 0.54, blue: 0.0, alpha: 1.0),
                variable: NSColor(red: 0.51, green: 0.58, blue: 0.59, alpha: 1.0),
                currentLineHighlight: NSColor(red: 0.03, green: 0.21, blue: 0.26, alpha: 1.0)
            )
            
        case .monokai:
            return ThemeColors(
                background: NSColor(red: 0.16, green: 0.16, blue: 0.14, alpha: 1.0),
                text: NSColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0),
                keyword: NSColor(red: 0.98, green: 0.15, blue: 0.45, alpha: 1.0),
                string: NSColor(red: 0.90, green: 0.86, blue: 0.45, alpha: 1.0),
                comment: NSColor(red: 0.46, green: 0.45, blue: 0.38, alpha: 1.0),
                number: NSColor(red: 0.68, green: 0.51, blue: 1.0, alpha: 1.0),
                function: NSColor(red: 0.65, green: 0.89, blue: 0.18, alpha: 1.0),
                type: NSColor(red: 0.40, green: 0.85, blue: 0.94, alpha: 1.0),
                variable: NSColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0),
                currentLineHighlight: NSColor(red: 0.23, green: 0.23, blue: 0.20, alpha: 1.0)
            )
            
        case .tomorrow:
            return ThemeColors(
                background: .white,
                text: NSColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 1.0),
                keyword: NSColor(red: 0.55, green: 0.38, blue: 0.73, alpha: 1.0),
                string: NSColor(red: 0.45, green: 0.64, blue: 0.33, alpha: 1.0),
                comment: NSColor(red: 0.58, green: 0.60, blue: 0.60, alpha: 1.0),
                number: NSColor(red: 0.85, green: 0.47, blue: 0.31, alpha: 1.0),
                function: NSColor(red: 0.25, green: 0.51, blue: 0.77, alpha: 1.0),
                type: NSColor(red: 0.94, green: 0.74, blue: 0.27, alpha: 1.0),
                variable: NSColor(red: 0.79, green: 0.29, blue: 0.25, alpha: 1.0),
                currentLineHighlight: NSColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
            )
            
        case .tomorrowNight:
            return ThemeColors(
                background: NSColor(red: 0.11, green: 0.12, blue: 0.13, alpha: 1.0),
                text: NSColor(red: 0.78, green: 0.78, blue: 0.78, alpha: 1.0),
                keyword: NSColor(red: 0.70, green: 0.53, blue: 0.85, alpha: 1.0),
                string: NSColor(red: 0.71, green: 0.82, blue: 0.51, alpha: 1.0),
                comment: NSColor(red: 0.58, green: 0.60, blue: 0.60, alpha: 1.0),
                number: NSColor(red: 0.85, green: 0.65, blue: 0.53, alpha: 1.0),
                function: NSColor(red: 0.51, green: 0.68, blue: 0.89, alpha: 1.0),
                type: NSColor(red: 0.94, green: 0.87, blue: 0.51, alpha: 1.0),
                variable: NSColor(red: 0.80, green: 0.51, blue: 0.51, alpha: 1.0),
                currentLineHighlight: NSColor(red: 0.17, green: 0.18, blue: 0.19, alpha: 1.0)
            )
        }
    }
}
