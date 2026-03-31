//
//  FeatureAccess.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import Foundation

/// Determines which features are available based on purchase status
struct FeatureAccess {
    
    /// Check if premium features are unlocked
    static var hasPremium: Bool {
        StoreManager.shared.hasPremiumFeatures
    }
    
    /// Languages available in free version
    static let freeLanguages: Set<CodeLanguage> = [.swift]
    
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
        }
    }
    
    enum Feature {
        case language(CodeLanguage)
        case findAndReplace
        case printing
        case codeCompletion
    }
}
