//
//  FeatureAccess.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import Foundation

/// Determines which features are available based on purchase status
struct FeatureAccess {
    
    // MARK: - Development Testing
    /// Set to true to test premium features without purchase (DISABLE IN PRODUCTION)
    static let overridePremiumForTesting = true
    
    /// Check if premium features are unlocked
    static var hasPremium: Bool {
        #if DEBUG
        if overridePremiumForTesting {
            return true
        }
        #endif
        return StoreManager.shared.hasPremiumFeatures
    }
    
    /// Languages available in free version
    static let freeLanguages: Set<CodeLanguage> = [.swift, .plaintext]
    
    /// Check if a language is available
    static func canUseLanguage(_ language: CodeLanguage) -> Bool {
        if hasPremium {
            return true
        }
        return freeLanguages.contains(language)
    }
    
    /// Check if find and replace is available
    static var canUseFindAndReplace: Bool {
        hasPremium
    }
    
    /// Check if printing is available
    static var canUsePrinting: Bool {
        hasPremium
    }
    
    /// Check if code completion is available
    static var canUseCodeCompletion: Bool {
        hasPremium
    }
    
    /// Check if column-restricted search is available
    static var canUseColumnSearch: Bool {
        hasPremium
    }
    
    /// Check if premium themes are available
    static var canUsePremiumThemes: Bool {
        hasPremium
    }
    
    /// Check if split view is available
    static var canUseSplitView: Bool {
        hasPremium
    }
    
    /// Check if snippets are available
    static var canUseSnippets: Bool {
        hasPremium
    }
    
    /// Check if Git integration is available
    static var canUseGitIntegration: Bool {
        hasPremium
    }
    
    /// Check if multi-file search is available
    static var canUseMultiFileSearch: Bool {
        hasPremium
    }
    
    /// Check if code folding is available
    static var canUseCodeFolding: Bool {
        hasPremium
    }
    
    /// Check if project/folder support is available
    static var canUseFolderSupport: Bool {
        hasPremium
    }
    
    /// Get feature description for premium gate
    static func featureDescription(for feature: Feature) -> String {
        switch feature {
        case .language(let lang):
            return "Syntax highlighting for \(lang.rawValue) requires Premium"
        case .findAndReplace:
            return "Find and Replace requires Premium"
        case .printing:
            return "Printing requires Premium"
        case .codeCompletion:
            return "Code Completion requires Premium"
        case .columnSearch:
            return "Column-restricted search requires Premium"
        case .premiumThemes:
            return "Premium color themes require Premium"
        case .splitView:
            return "Split view editing requires Premium"
        case .snippets:
            return "Code snippets require Premium"
        case .gitIntegration:
            return "Git integration requires Premium"
        case .multiFileSearch:
            return "Multi-file search requires Premium"
        case .codeFolding:
            return "Code folding requires Premium"
        case .folderSupport:
            return "Project/folder support requires Premium"
        }
    }
    
    enum Feature {
        case language(CodeLanguage)
        case findAndReplace
        case printing
        case codeCompletion
        case columnSearch
        case premiumThemes
        case splitView
        case snippets
        case gitIntegration
        case multiFileSearch
        case codeFolding
        case folderSupport
    }
}
