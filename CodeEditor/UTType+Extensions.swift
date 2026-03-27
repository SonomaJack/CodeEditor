//
//  UTType+Extensions.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/26/26.
//

import UniformTypeIdentifiers

extension UTType {
    // Swift source files
    static var swiftSource: UTType {
        UTType(filenameExtension: "swift") ?? .sourceCode
    }
    
    // Python source files
    static var pythonScript: UTType {
        UTType(filenameExtension: "py") ?? .sourceCode
    }
    
    // Java source files
    static var javaSource: UTType {
        UTType(filenameExtension: "java") ?? .sourceCode
    }
    
    // JavaScript source files
    static var javaScriptSource: UTType {
        UTType(filenameExtension: "js") ?? .javaScript
    }
    
    // Salesforce Apex class files
    static var apexClass: UTType {
        UTType(filenameExtension: "cls") ?? .plainText
    }
    
    // Salesforce Apex trigger files
    static var apexTrigger: UTType {
        UTType(filenameExtension: "trigger") ?? .plainText
    }
    
    // All supported code file types
    static var codeFiles: [UTType] {
        return [
            .swiftSource,
            .pythonScript,
            .javaScriptSource,
            .javaScript,
            .javaSource,
            .cSource,
            .cHeader,
            .cPlusPlusSource,
            .cPlusPlusHeader,
            .html,
            .css,
            .apexClass,
            .apexTrigger,
            .text,
            .plainText,
            .sourceCode
        ]
    }
}
