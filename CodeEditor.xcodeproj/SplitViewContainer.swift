//
//  SplitViewContainer.swift
//  CodeEditor
//
//  Created by J Bretcher on 3/31/26.
//

import SwiftUI

struct SplitViewContainer: View {
    @Bindable var primaryDocument: CodeDocument
    @Binding var secondaryDocument: CodeDocument?
    @Binding var triggerPrint: Bool
    @Binding var isSplitView: Bool
    
    var body: some View {
        if isSplitView, let secondary = secondaryDocument {
            HSplitView {
                CodeEditorView(document: primaryDocument, triggerPrint: $triggerPrint)
                    .frame(minWidth: 300)
                
                CodeEditorView(document: secondary, triggerPrint: $triggerPrint)
                    .frame(minWidth: 300)
            }
        } else {
            CodeEditorView(document: primaryDocument, triggerPrint: $triggerPrint)
        }
    }
}
