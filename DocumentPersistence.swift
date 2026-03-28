//
//  DocumentPersistence.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/27/26.
//

import Foundation

struct DocumentPersistence {
    private static let recentFilesKey = "recentFiles"
    private static let maxRecentFiles = 20
    
    /// Save the list of recently opened file URLs
    static func saveRecentFiles(_ documents: [CodeDocument]) {
        let urls = documents.compactMap { $0.fileURL?.path }
        UserDefaults.standard.set(urls, forKey: recentFilesKey)
    }
    
    /// Load recently opened files
    static func loadRecentFiles() -> [CodeDocument] {
        guard let paths = UserDefaults.standard.stringArray(forKey: recentFilesKey) else {
            return []
        }
        
        var documents: [CodeDocument] = []
        
        for path in paths.prefix(maxRecentFiles) {
            let url = URL(fileURLWithPath: path)
            
            // Check if file still exists
            guard FileManager.default.fileExists(atPath: url.path) else {
                continue
            }
            
            // Try to load the document
            do {
                let document = try CodeDocument.load(from: url)
                documents.append(document)
            } catch {
                // Skip files that can't be loaded
                print("Failed to load recent file: \(path) - \(error.localizedDescription)")
            }
        }
        
        return documents
    }
    
    /// Check if user has previously opened files
    static func hasRecentFiles() -> Bool {
        guard let paths = UserDefaults.standard.stringArray(forKey: recentFilesKey) else {
            return false
        }
        
        // Check if any of the recent files still exist
        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        return false
    }
    
    /// Clear recent files
    static func clearRecentFiles() {
        UserDefaults.standard.removeObject(forKey: recentFilesKey)
    }
}
