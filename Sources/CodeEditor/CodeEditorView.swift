import AppKit
import SwiftUI

// MARK: - CodeEditorView (NSViewRepresentable)

struct CodeEditorView: NSViewRepresentable {

    @Binding var content: String
    @Binding var language: Language
    var onTextViewCreated: ((NSTextView) -> Void)?

    @MainActor
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.backgroundColor = ThemeColors.background
        scrollView.drawsBackground = true

        // Create text storage with syntax highlighting
        let textStorage = SyntaxTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(containerSize: NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        layoutManager.addTextContainer(textContainer)

        let textView = NSTextView(frame: .zero, textContainer: textContainer)
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.backgroundColor = ThemeColors.background
        textView.drawsBackground = true
        textView.insertionPointColor = ThemeColors.cursor
        textView.selectedTextAttributes = [
            .backgroundColor: ThemeColors.selection,
            .foregroundColor: NSColor.white
        ]

        // Font settings
        let editorFont = NSFont(name: "SF Mono", size: 13) ??
                         NSFont(name: "Menlo", size: 13) ??
                         NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.font = editorFont
        textView.textColor = ThemeColors.foreground

        // Text container settings
        textView.textContainerInset = NSSize(width: 4, height: 8)
        textContainer.lineFragmentPadding = 4
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isGrammarCheckingEnabled = false
        textView.smartInsertDeleteEnabled = false
        textView.isRichText = false

        // Tab settings
        textView.defaultParagraphStyle = {
            let style = NSMutableParagraphStyle()
            let tabWidth = editorFont.maximumAdvancement.width * 4
            style.tabStops = []
            style.defaultTabInterval = tabWidth
            return style
        }()

        // Line number ruler
        let lineNumberView = LineNumberRulerView(scrollView: scrollView, orientation: .verticalRuler)
        lineNumberView.textView = textView
        scrollView.verticalRulerView = lineNumberView
        scrollView.rulersVisible = true
        scrollView.hasVerticalRuler = true

        scrollView.documentView = textView
        textView.minSize = NSSize(width: 0, height: scrollView.contentSize.height)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]

        // Set delegate
        textView.delegate = context.coordinator

        // Store references
        context.coordinator.textView = textView
        context.coordinator.textStorage = textStorage
        context.coordinator.scrollView = scrollView

        // Setup completion manager
        context.coordinator.completionManager.setup(with: textView)
        context.coordinator.completionManager.language = language

        // Set initial content
        if !content.isEmpty {
            textStorage.setLanguage(language)
            textView.string = content
            textStorage.rehighlight()
        }

        // Notify about text view creation
        DispatchQueue.main.async {
            self.onTextViewCreated?(textView)
        }

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = context.coordinator.textView,
              let textStorage = context.coordinator.textStorage else { return }

        // Update language
        if context.coordinator.currentLanguage != language {
            context.coordinator.currentLanguage = language
            textStorage.setLanguage(language)
            context.coordinator.completionManager.language = language
            textStorage.rehighlight()
        }

        // Update content if changed externally
        if textView.string != content && !context.coordinator.isUpdatingFromDelegate {
            textView.string = content
            textStorage.rehighlight()
        }
    }

    // MARK: - Coordinator

    @MainActor
    final class Coordinator: NSObject, NSTextViewDelegate {

        var parent: CodeEditorView
        weak var textView: NSTextView?
        weak var textStorage: SyntaxTextStorage?
        weak var scrollView: NSScrollView?
        var currentLanguage: Language = .plainText
        var isUpdatingFromDelegate = false
        let completionManager = CompletionManager()

        init(_ parent: CodeEditorView) {
            self.parent = parent
            self.currentLanguage = parent.language
        }

        // MARK: - NSTextViewDelegate

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }

            isUpdatingFromDelegate = true
            parent.content = textView.string
            isUpdatingFromDelegate = false

            // Trigger completions
            completionManager.triggerCompletion(afterDelay: true)

            // Update ruler
            scrollView?.verticalRulerView?.needsDisplay = true
        }

        func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
            return true
        }

        func textViewDidChangeSelection(_ notification: Notification) {
            scrollView?.verticalRulerView?.needsDisplay = true
        }

        func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            // Handle completion navigation
            if commandSelector == #selector(NSResponder.moveUp(_:)) {
                if completionManager.isPanelVisible {
                    return completionManager.moveSelectionUp()
                }
            }

            if commandSelector == #selector(NSResponder.moveDown(_:)) {
                if completionManager.isPanelVisible {
                    return completionManager.moveSelectionDown()
                }
            }

            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                if completionManager.isPanelVisible {
                    return completionManager.acceptCurrentCompletion()
                }
            }

            if commandSelector == #selector(NSResponder.insertTab(_:)) {
                if completionManager.isPanelVisible {
                    return completionManager.acceptCurrentCompletion()
                }
                // Insert spaces instead of tab
                textView.insertText("    ", replacementRange: textView.selectedRange())
                return true
            }

            if commandSelector == #selector(NSResponder.cancelOperation(_:)) {
                if completionManager.isPanelVisible {
                    completionManager.dismissCompletion()
                    return true
                }
            }

            return false
        }

        func textView(_ textView: NSTextView, completions words: [String], forPartialWordRange charRange: NSRange, indexOfSelectedItem index: UnsafeMutablePointer<Int>?) -> [String] {
            return []
        }
    }
}
