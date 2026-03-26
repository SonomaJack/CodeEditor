import AppKit

// MARK: - Theme Colors (VS Code Dark+)

enum ThemeColors {
    static let background = NSColor(hex: "#1E1E1E")
    static let foreground = NSColor(hex: "#D4D4D4")
    static let keyword = NSColor(hex: "#569CD6")
    static let string = NSColor(hex: "#CE9178")
    static let comment = NSColor(hex: "#6A9955")
    static let number = NSColor(hex: "#B5CEA8")
    static let type = NSColor(hex: "#4EC9B0")
    static let function_ = NSColor(hex: "#DCDCAA")
    static let operator_ = NSColor(hex: "#D4D4D4")
    static let preprocessor = NSColor(hex: "#C586C0")
    static let lineNumber = NSColor(hex: "#858585")
    static let selection = NSColor(hex: "#264F78")
    static let cursor = NSColor(hex: "#AEAFAD")
}

extension NSColor {
    convenience init(hex: String) {
        var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }

        var rgb: UInt64 = 0
        Scanner(string: hexString).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(calibratedRed: r, green: g, blue: b, alpha: 1.0)
    }
}

// MARK: - SyntaxTextStorage

final class SyntaxTextStorage: NSTextStorage {

    private let backingStore = NSMutableAttributedString()
    private var language: Language = .plainText
    private var isHighlighting = false

    // Base attributes for default text
    var baseFont: NSFont {
        NSFont(name: "SF Mono", size: 13) ??
        NSFont(name: "Menlo", size: 13) ??
        NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
    }

    // MARK: - NSTextStorage Required Overrides

    override var string: String {
        backingStore.string
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key: Any] {
        guard location >= 0 && location < backingStore.length else {
            range?.pointee = NSRange(location: location, length: 0)
            return [:]
        }
        return backingStore.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        backingStore.replaceCharacters(in: range, with: str)
        let lengthDelta = str.utf16.count - range.length
        edited(.editedCharacters, range: range, changeInLength: lengthDelta)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key: Any]?, range: NSRange) {
        guard !isHighlighting else {
            backingStore.setAttributes(attrs, range: range)
            return
        }
        beginEditing()
        backingStore.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

    // MARK: - Editing

    override func processEditing() {
        // Expand the edited range to cover full lines
        let editedRange = self.editedRange
        let fullString = self.string as NSString
        let lineRange = fullString.lineRange(for: editedRange)

        applyHighlighting(to: lineRange)
        super.processEditing()
    }

    // MARK: - Language

    func setLanguage(_ newLanguage: Language) {
        language = newLanguage
        let fullRange = NSRange(location: 0, length: backingStore.length)
        applyHighlighting(to: fullRange)
    }

    // MARK: - Highlighting

    private func applyHighlighting(to range: NSRange) {
        guard range.length > 0,
              range.location + range.length <= backingStore.length else {
            return
        }

        isHighlighting = true
        defer { isHighlighting = false }

        // Apply base styling
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: ThemeColors.foreground
        ]
        backingStore.setAttributes(baseAttributes, range: range)

        let fullString = backingStore.string

        // Apply token patterns
        for (patternString, tokenType) in language.tokenPatterns {
            guard let regex = try? NSRegularExpression(pattern: patternString, options: [.dotMatchesLineSeparators]) else {
                continue
            }

            let color = colorForTokenType(tokenType)
            let searchRange = NSRange(location: 0, length: fullString.utf16.count)

            regex.enumerateMatches(in: fullString, options: [], range: searchRange) { match, _, _ in
                guard let matchRange = match?.range else { return }

                // Only apply attributes if the match overlaps with our range
                let intersection = NSIntersectionRange(matchRange, range)
                if intersection.length > 0 {
                    backingStore.addAttribute(.foregroundColor, value: color, range: matchRange)
                }
            }
        }
    }

    private func colorForTokenType(_ type: TokenType) -> NSColor {
        switch type {
        case .keyword: return ThemeColors.keyword
        case .string: return ThemeColors.string
        case .comment: return ThemeColors.comment
        case .number: return ThemeColors.number
        case .type: return ThemeColors.type
        case .function_: return ThemeColors.function_
        case .operator_: return ThemeColors.operator_
        case .preprocessor: return ThemeColors.preprocessor
        }
    }

    // MARK: - Full Rehighlight

    func rehighlight() {
        let fullRange = NSRange(location: 0, length: backingStore.length)
        guard fullRange.length > 0 else { return }

        isHighlighting = true
        beginEditing()
        applyHighlighting(to: fullRange)
        edited(.editedAttributes, range: fullRange, changeInLength: 0)
        endEditing()
        isHighlighting = false
    }
}
