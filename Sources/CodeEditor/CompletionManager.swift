import AppKit
import Foundation

// MARK: - Completion Item

struct CompletionItem: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let detail: String
    let source: CompletionSource
}

enum CompletionSource {
    case keyword
    case claude
}

// MARK: - Claude API Response Types

private struct ClaudeRequest: Encodable {
    let model: String
    let max_tokens: Int
    let system: String
    let messages: [ClaudeMessage]
}

private struct ClaudeMessage: Encodable {
    let role: String
    let content: String
}

private struct ClaudeResponse: Decodable {
    let content: [ClaudeContent]
}

private struct ClaudeContent: Decodable {
    let type: String
    let text: String?
}

// MARK: - CompletionManager

@MainActor
final class CompletionManager: NSObject {

    // MARK: - Properties

    weak var textView: NSTextView?
    var language: Language = .plainText

    private var completionPanel: NSPanel?
    private var completionTableView: NSTableView?
    private var completionScrollView: NSScrollView?
    private var completionItems: [CompletionItem] = []
    private var selectedIndex: Int = 0
    private var debounceTimer: Timer?
    private var isVisible: Bool = false
    private var currentWord: String = ""

    var onCompletion: ((String) -> Void)?

    // MARK: - Setup

    func setup(with textView: NSTextView) {
        self.textView = textView
        createCompletionPanel()
    }

    private func createCompletionPanel() {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 200),
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        panel.isFloatingPanel = true
        panel.level = .popUpMenu
        panel.backgroundColor = NSColor(hex: "#252526")
        panel.hasShadow = true
        panel.isOpaque = true
        panel.hidesOnDeactivate = false

        let scrollView = NSScrollView(frame: NSRect(x: 0, y: 0, width: 320, height: 200))
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder

        let tableView = NSTableView()
        tableView.backgroundColor = .clear
        tableView.selectionHighlightStyle = .none
        tableView.rowHeight = 24
        tableView.intercellSpacing = NSSize(width: 0, height: 0)
        tableView.headerView = nil
        tableView.focusRingType = .none

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("completion"))
        column.minWidth = 300
        tableView.addTableColumn(column)
        tableView.delegate = self
        tableView.dataSource = self

        scrollView.documentView = tableView

        panel.contentView = scrollView

        self.completionPanel = panel
        self.completionTableView = tableView
        self.completionScrollView = scrollView
    }

    // MARK: - Trigger Completions

    func triggerCompletion(afterDelay: Bool = true) {
        debounceTimer?.invalidate()

        if afterDelay {
            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    self?.fetchCompletions()
                }
            }
        } else {
            fetchCompletions()
        }
    }

    private func fetchCompletions() {
        guard let textView = textView else { return }

        let selectedRange = textView.selectedRange()
        let text = textView.string as NSString

        // Get current word being typed
        let wordRange = text.rangeOfCharacter(
            from: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")),
            options: .backwards,
            range: NSRange(location: 0, length: selectedRange.location)
        )

        var prefix = ""
        if wordRange.location != NSNotFound {
            // Find start of word
            var startIndex = selectedRange.location
            while startIndex > 0 {
                let char = text.character(at: startIndex - 1)
                let scalar = Unicode.Scalar(char)!
                if CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).contains(scalar) {
                    startIndex -= 1
                } else {
                    break
                }
            }
            prefix = text.substring(with: NSRange(location: startIndex, length: selectedRange.location - startIndex))
        }

        currentWord = prefix

        guard prefix.count >= 1 else {
            dismissCompletion()
            return
        }

        // Get keyword completions
        let keywordCompletions = language.keywords
            .filter { $0.hasPrefix(prefix) && $0 != prefix }
            .prefix(10)
            .map { CompletionItem(text: $0, detail: "keyword", source: .keyword) }

        var allCompletions = Array(keywordCompletions)

        // Update UI with keyword completions immediately
        showCompletions(allCompletions)

        // Fetch Claude completions if API key is set
        if let apiKey = ProcessInfo.processInfo.environment["ANTHROPIC_API_KEY"], !apiKey.isEmpty {
            let contextStart = max(0, selectedRange.location - 200)
            let contextLength = selectedRange.location - contextStart
            let context = text.substring(with: NSRange(location: contextStart, length: contextLength))
            let capturedLanguage = language

            Task {
                if let claudeCompletions = await fetchClaudeCompletions(
                    context: context,
                    prefix: prefix,
                    language: capturedLanguage,
                    apiKey: apiKey
                ) {
                    let filteredClaude = claudeCompletions.filter { item in
                        !allCompletions.contains(where: { $0.text == item.text })
                    }
                    allCompletions.append(contentsOf: filteredClaude)
                    self.showCompletions(allCompletions)
                }
            }
        }
    }

    private func fetchClaudeCompletions(
        context: String,
        prefix: String,
        language: Language,
        apiKey: String
    ) async -> [CompletionItem]? {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 10

        let systemPrompt = "You are a code completion assistant. Given this \(language.displayName) code context, provide 5 short completion suggestions as a JSON array of strings. Only return the JSON array, nothing else. Each completion should be a plausible continuation of the current prefix '\(prefix)'."

        let userMessage = "Code context:\n```\(language.rawValue)\n\(context)\n```\n\nProvide 5 completions for prefix: '\(prefix)'"

        let requestBody = ClaudeRequest(
            model: "claude-opus-4-6",
            max_tokens: 200,
            system: systemPrompt,
            messages: [ClaudeMessage(role: "user", content: userMessage)]
        )

        guard let jsonData = try? JSONEncoder().encode(requestBody) else { return nil }
        request.httpBody = jsonData

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }

            let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)

            guard let textContent = claudeResponse.content.first(where: { $0.type == "text" })?.text else {
                return nil
            }

            // Parse the JSON array of strings
            let jsonString = textContent.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let jsonData = jsonString.data(using: .utf8),
                  let completions = try? JSONDecoder().decode([String].self, from: jsonData) else {
                // Try to extract JSON array from response
                if let range = jsonString.range(of: "["),
                   let endRange = jsonString.range(of: "]", options: .backwards) {
                    let jsonSubstring = String(jsonString[range.lowerBound...endRange.upperBound])
                    if let jsonData = jsonSubstring.data(using: .utf8),
                       let completions = try? JSONDecoder().decode([String].self, from: jsonData) {
                        return completions.map { CompletionItem(text: $0, detail: "AI suggestion", source: .claude) }
                    }
                }
                return nil
            }

            return completions.map { CompletionItem(text: $0, detail: "AI suggestion", source: .claude) }
        } catch {
            return nil
        }
    }

    // MARK: - Display

    private func showCompletions(_ items: [CompletionItem]) {
        guard !items.isEmpty else {
            dismissCompletion()
            return
        }

        completionItems = items
        selectedIndex = 0
        completionTableView?.reloadData()
        completionTableView?.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)

        positionPanel()

        if let panel = completionPanel, !panel.isVisible {
            panel.orderFront(nil)
            isVisible = true
        }
    }

    private func positionPanel() {
        guard let textView = textView,
              let panel = completionPanel,
              let window = textView.window else { return }

        let selectedRange = textView.selectedRange()
        guard selectedRange.location != NSNotFound else { return }

        // Get cursor rect
        let glyphRange = textView.layoutManager?.glyphRange(forCharacterRange: NSRange(location: selectedRange.location, length: 0), actualCharacterRange: nil) ?? NSRange()
        var cursorRect = textView.layoutManager?.boundingRect(forGlyphRange: glyphRange, in: textView.textContainer ?? NSTextContainer()) ?? NSRect.zero

        cursorRect.origin.x += textView.textContainerInset.width
        cursorRect.origin.y += textView.textContainerInset.height

        // Convert to window coordinates
        let windowRect = textView.convert(cursorRect, to: nil)
        let screenRect = window.convertToScreen(windowRect)

        // Position panel below cursor
        let panelHeight = min(CGFloat(completionItems.count * 24 + 4), 200)
        let panelWidth: CGFloat = 320

        var panelX = screenRect.minX
        var panelY = screenRect.minY - panelHeight - 4

        // Ensure panel stays on screen
        if let screen = NSScreen.main {
            let screenBounds = screen.visibleFrame
            if panelX + panelWidth > screenBounds.maxX {
                panelX = screenBounds.maxX - panelWidth
            }
            if panelY < screenBounds.minY {
                panelY = screenRect.maxY + 4
            }
        }

        panel.setFrame(NSRect(x: panelX, y: panelY, width: panelWidth, height: panelHeight), display: true)

        // Update scroll view size
        completionScrollView?.frame = NSRect(x: 0, y: 0, width: panelWidth, height: panelHeight)
        completionTableView?.frame = NSRect(x: 0, y: 0, width: panelWidth, height: CGFloat(completionItems.count * 24))
    }

    func dismissCompletion() {
        completionPanel?.orderOut(nil)
        isVisible = false
        completionItems = []
        selectedIndex = 0
    }

    // MARK: - Navigation

    func moveSelectionUp() -> Bool {
        guard isVisible && !completionItems.isEmpty else { return false }
        selectedIndex = max(0, selectedIndex - 1)
        completionTableView?.selectRowIndexes(IndexSet(integer: selectedIndex), byExtendingSelection: false)
        completionTableView?.scrollRowToVisible(selectedIndex)
        return true
    }

    func moveSelectionDown() -> Bool {
        guard isVisible && !completionItems.isEmpty else { return false }
        selectedIndex = min(completionItems.count - 1, selectedIndex + 1)
        completionTableView?.selectRowIndexes(IndexSet(integer: selectedIndex), byExtendingSelection: false)
        completionTableView?.scrollRowToVisible(selectedIndex)
        return true
    }

    func acceptCurrentCompletion() -> Bool {
        guard isVisible, selectedIndex < completionItems.count else { return false }
        let item = completionItems[selectedIndex]
        applyCompletion(item.text)
        return true
    }

    private func applyCompletion(_ completion: String) {
        guard let textView = textView else { return }

        let selectedRange = textView.selectedRange()
        let text = textView.string as NSString

        // Find start of current word
        var startIndex = selectedRange.location
        while startIndex > 0 {
            let char = text.character(at: startIndex - 1)
            let scalar = Unicode.Scalar(char)!
            if CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_")).contains(scalar) {
                startIndex -= 1
            } else {
                break
            }
        }

        let wordRange = NSRange(location: startIndex, length: selectedRange.location - startIndex)

        if textView.shouldChangeText(in: wordRange, replacementString: completion) {
            textView.replaceCharacters(in: wordRange, with: completion)
            textView.didChangeText()
        }

        dismissCompletion()
        onCompletion?(completion)
    }

    var isPanelVisible: Bool { isVisible }
}

// MARK: - NSTableViewDataSource

extension CompletionManager: NSTableViewDataSource {
    nonisolated func numberOfRows(in tableView: NSTableView) -> Int {
        return MainActor.assumeIsolated { completionItems.count }
    }
}

// MARK: - NSTableViewDelegate

extension CompletionManager: NSTableViewDelegate {

    nonisolated func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return MainActor.assumeIsolated {
            let item = completionItems[row]
            let isSelected = row == selectedIndex

            let cellView = CompletionCellView()
            cellView.configure(with: item, isSelected: isSelected)
            return cellView
        }
    }

    nonisolated func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 24
    }

    nonisolated func tableViewSelectionDidChange(_ notification: Notification) {
        MainActor.assumeIsolated {
            guard let tableView = notification.object as? NSTableView else { return }
            selectedIndex = tableView.selectedRow
            tableView.reloadData()
        }
    }

    nonisolated func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = NSTableRowView()
        return rowView
    }
}

// MARK: - CompletionCellView

private final class CompletionCellView: NSView {

    private let textLabel = NSTextField(labelWithString: "")
    private let detailLabel = NSTextField(labelWithString: "")
    private let iconLabel = NSTextField(labelWithString: "")

    override init(frame: NSRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }

    private func setupViews() {
        wantsLayer = true

        iconLabel.font = NSFont.systemFont(ofSize: 10)
        iconLabel.textColor = NSColor(hex: "#569CD6")
        iconLabel.alignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)

        textLabel.font = NSFont(name: "SF Mono", size: 12) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textLabel.textColor = NSColor(hex: "#D4D4D4")
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)

        detailLabel.font = NSFont.systemFont(ofSize: 10)
        detailLabel.textColor = NSColor(hex: "#858585")
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(detailLabel)

        NSLayoutConstraint.activate([
            iconLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 20),

            textLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 4),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.trailingAnchor.constraint(equalTo: detailLabel.leadingAnchor, constant: -8),

            detailLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            detailLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            detailLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
        ])
    }

    func configure(with item: CompletionItem, isSelected: Bool) {
        textLabel.stringValue = item.text
        detailLabel.stringValue = item.detail

        switch item.source {
        case .keyword:
            iconLabel.stringValue = "kw"
            iconLabel.textColor = NSColor(hex: "#569CD6")
        case .claude:
            iconLabel.stringValue = "ai"
            iconLabel.textColor = NSColor(hex: "#C586C0")
        }

        if isSelected {
            layer?.backgroundColor = NSColor(hex: "#094771").cgColor
            textLabel.textColor = .white
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            textLabel.textColor = NSColor(hex: "#D4D4D4")
        }
    }
}
