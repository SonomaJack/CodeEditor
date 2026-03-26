import Foundation
import AppKit

// MARK: - Token Types

enum TokenType {
    case keyword
    case string
    case comment
    case number
    case type
    case function_
    case operator_
    case preprocessor
}

// MARK: - Language Definition

enum Language: String, CaseIterable, Identifiable {
    case swift
    case java
    case javascript
    case typescript
    case python
    case html
    case css
    case c
    case cpp
    case go
    case rust
    case json
    case ruby
    case plainText

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .swift: return "Swift"
        case .java: return "Java"
        case .javascript: return "JavaScript"
        case .typescript: return "TypeScript"
        case .python: return "Python"
        case .html: return "HTML"
        case .css: return "CSS"
        case .c: return "C"
        case .cpp: return "C++"
        case .go: return "Go"
        case .rust: return "Rust"
        case .json: return "JSON"
        case .ruby: return "Ruby"
        case .plainText: return "Plain Text"
        }
    }

    var fileExtensions: [String] {
        switch self {
        case .swift: return ["swift"]
        case .java: return ["java"]
        case .javascript: return ["js", "jsx", "mjs", "cjs"]
        case .typescript: return ["ts", "tsx"]
        case .python: return ["py", "pyw", "pyi"]
        case .html: return ["html", "htm", "xhtml"]
        case .css: return ["css", "scss", "sass", "less"]
        case .c: return ["c", "h"]
        case .cpp: return ["cpp", "cc", "cxx", "hpp", "hxx", "hh"]
        case .go: return ["go"]
        case .rust: return ["rs"]
        case .json: return ["json", "jsonc"]
        case .ruby: return ["rb", "rake", "gemspec"]
        case .plainText: return ["txt", "text", "md", "markdown"]
        }
    }

    var keywords: [String] {
        switch self {
        case .swift:
            return ["associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
                    "func", "import", "init", "inout", "internal", "let", "open", "operator",
                    "private", "precedencegroup", "protocol", "public", "rethrows", "static",
                    "struct", "subscript", "typealias", "var", "break", "case", "catch",
                    "continue", "default", "defer", "do", "else", "fallthrough", "for",
                    "guard", "if", "in", "repeat", "return", "throw", "switch", "where",
                    "while", "Any", "as", "await", "false", "is", "nil", "rethrows", "self",
                    "Self", "super", "throws", "true", "try", "async", "actor", "nonisolated",
                    "isolated", "convenience", "dynamic", "final", "indirect", "lazy", "mutating",
                    "nonmutating", "optional", "override", "required", "unowned", "weak",
                    "@MainActor", "@State", "@Binding", "@ObservedObject", "@StateObject",
                    "@EnvironmentObject", "@Environment", "@Published", "@discardableResult"]
        case .java:
            return ["abstract", "assert", "boolean", "break", "byte", "case", "catch", "char",
                    "class", "const", "continue", "default", "do", "double", "else", "enum",
                    "extends", "final", "finally", "float", "for", "goto", "if", "implements",
                    "import", "instanceof", "int", "interface", "long", "native", "new",
                    "package", "private", "protected", "public", "return", "short", "static",
                    "strictfp", "super", "switch", "synchronized", "this", "throw", "throws",
                    "transient", "try", "var", "void", "volatile", "while", "true", "false", "null",
                    "record", "sealed", "permits", "yield"]
        case .javascript, .typescript:
            return ["break", "case", "catch", "class", "const", "continue", "debugger", "default",
                    "delete", "do", "else", "export", "extends", "false", "finally", "for",
                    "function", "if", "import", "in", "instanceof", "let", "new", "null",
                    "return", "static", "super", "switch", "this", "throw", "true", "try",
                    "typeof", "undefined", "var", "void", "while", "with", "yield", "async",
                    "await", "of", "from", "as", "get", "set", "interface", "type", "enum",
                    "implements", "namespace", "declare", "abstract", "override", "readonly",
                    "keyof", "infer", "never", "unknown", "any", "string", "number", "boolean",
                    "symbol", "bigint", "object"]
        case .python:
            return ["False", "None", "True", "and", "as", "assert", "async", "await", "break",
                    "class", "continue", "def", "del", "elif", "else", "except", "finally",
                    "for", "from", "global", "if", "import", "in", "is", "lambda", "nonlocal",
                    "not", "or", "pass", "raise", "return", "try", "while", "with", "yield",
                    "self", "cls", "print", "len", "range", "type", "list", "dict", "set",
                    "tuple", "str", "int", "float", "bool", "bytes", "super", "property",
                    "staticmethod", "classmethod", "abstractmethod"]
        case .html:
            return ["html", "head", "body", "div", "span", "p", "a", "img", "ul", "ol", "li",
                    "table", "tr", "td", "th", "form", "input", "button", "select", "option",
                    "textarea", "script", "style", "link", "meta", "title", "h1", "h2", "h3",
                    "h4", "h5", "h6", "header", "footer", "nav", "main", "section", "article",
                    "aside", "figure", "figcaption", "video", "audio", "canvas", "svg",
                    "class", "id", "href", "src", "type", "name", "value", "placeholder",
                    "onclick", "onsubmit", "onchange", "rel", "charset", "content",
                    "DOCTYPE", "lang", "xmlns"]
        case .css:
            return ["color", "background", "background-color", "background-image", "margin",
                    "padding", "border", "border-radius", "font-size", "font-weight", "font-family",
                    "display", "flex", "grid", "position", "top", "left", "right", "bottom",
                    "width", "height", "min-width", "max-width", "overflow", "opacity",
                    "transform", "transition", "animation", "box-shadow", "text-align",
                    "line-height", "letter-spacing", "z-index", "cursor", "pointer-events",
                    "visibility", "content", "float", "clear", "list-style", "text-decoration",
                    "white-space", "word-break", "align-items", "justify-content", "flex-direction",
                    "flex-wrap", "gap", "grid-template-columns", "grid-template-rows",
                    "auto", "none", "inherit", "initial", "unset", "important",
                    "@media", "@keyframes", "@import", "@font-face", "@supports"]
        case .c:
            return ["auto", "break", "case", "char", "const", "continue", "default", "do",
                    "double", "else", "enum", "extern", "float", "for", "goto", "if",
                    "inline", "int", "long", "register", "restrict", "return", "short",
                    "signed", "sizeof", "static", "struct", "switch", "typedef", "union",
                    "unsigned", "void", "volatile", "while", "NULL", "true", "false",
                    "bool", "uint8_t", "uint16_t", "uint32_t", "uint64_t",
                    "int8_t", "int16_t", "int32_t", "int64_t", "size_t", "ptrdiff_t"]
        case .cpp:
            return ["alignas", "alignof", "and", "and_eq", "asm", "auto", "bitand", "bitor",
                    "bool", "break", "case", "catch", "char", "char8_t", "char16_t", "char32_t",
                    "class", "compl", "concept", "const", "consteval", "constexpr", "constinit",
                    "const_cast", "continue", "co_await", "co_return", "co_yield", "decltype",
                    "default", "delete", "do", "double", "dynamic_cast", "else", "enum",
                    "explicit", "export", "extern", "false", "float", "for", "friend", "goto",
                    "if", "inline", "int", "long", "mutable", "namespace", "new", "noexcept",
                    "not", "not_eq", "nullptr", "operator", "or", "or_eq", "private", "protected",
                    "public", "register", "reinterpret_cast", "requires", "return", "short",
                    "signed", "sizeof", "static", "static_assert", "static_cast", "struct",
                    "switch", "template", "this", "thread_local", "throw", "true", "try",
                    "typedef", "typeid", "typename", "union", "unsigned", "using", "virtual",
                    "void", "volatile", "wchar_t", "while", "xor", "xor_eq",
                    "std", "string", "vector", "map", "set", "list", "deque", "queue", "stack",
                    "unique_ptr", "shared_ptr", "weak_ptr", "make_unique", "make_shared",
                    "NULL", "nullptr", "size_t"]
        case .go:
            return ["break", "case", "chan", "const", "continue", "default", "defer", "else",
                    "fallthrough", "for", "func", "go", "goto", "if", "import", "interface",
                    "map", "package", "range", "return", "select", "struct", "switch", "type",
                    "var", "true", "false", "nil", "iota", "append", "cap", "close", "copy",
                    "delete", "imag", "len", "make", "new", "panic", "print", "println",
                    "real", "recover", "error", "string", "int", "int8", "int16", "int32",
                    "int64", "uint", "uint8", "uint16", "uint32", "uint64", "float32",
                    "float64", "complex64", "complex128", "byte", "rune", "bool", "uintptr"]
        case .rust:
            return ["as", "async", "await", "break", "const", "continue", "crate", "dyn",
                    "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in",
                    "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return",
                    "self", "Self", "static", "struct", "super", "trait", "true", "type",
                    "unsafe", "use", "where", "while", "abstract", "become", "box", "do",
                    "final", "macro", "override", "priv", "typeof", "unsized", "virtual",
                    "yield", "u8", "u16", "u32", "u64", "u128", "usize", "i8", "i16",
                    "i32", "i64", "i128", "isize", "f32", "f64", "bool", "char", "str",
                    "String", "Vec", "Option", "Result", "Some", "None", "Ok", "Err",
                    "Box", "Rc", "Arc", "Cell", "RefCell", "HashMap", "HashSet", "println",
                    "print", "eprintln", "eprint", "panic", "assert", "assert_eq", "todo",
                    "unimplemented", "unreachable", "dbg"]
        case .json:
            return ["true", "false", "null"]
        case .ruby:
            return ["BEGIN", "END", "__ENCODING__", "__FILE__", "__LINE__", "alias", "and",
                    "begin", "break", "case", "class", "def", "defined?", "do", "else",
                    "elsif", "end", "ensure", "false", "for", "if", "in", "module", "next",
                    "nil", "not", "or", "redo", "rescue", "retry", "return", "self",
                    "super", "then", "true", "undef", "unless", "until", "when", "while",
                    "yield", "puts", "print", "p", "pp", "require", "require_relative",
                    "attr_accessor", "attr_reader", "attr_writer", "include", "extend",
                    "prepend", "private", "protected", "public", "raise", "fail", "lambda",
                    "proc", "block_given?", "Integer", "Float", "String", "Array", "Hash",
                    "Symbol", "Regexp", "Range", "IO", "File", "Dir"]
        case .plainText:
            return []
        }
    }

    var tokenPatterns: [(regex: String, type: TokenType)] {
        switch self {
        case .swift:
            return [
                // Single-line comments
                ("//[^\n]*", .comment),
                // Multi-line comments
                ("/\\*[\\s\\S]*?\\*/", .comment),
                // String literals (with escape sequences)
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                // Multi-line strings
                ("\"\"\"[\\s\\S]*?\"\"\"", .string),
                // Numbers
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?\\b", .number),
                ("\\b0x[0-9a-fA-F]+\\b", .number),
                ("\\b\\d+\\b", .number),
                // Attributes
                ("@\\w+", .preprocessor),
                // Keywords
                ("\\b(associatedtype|class|deinit|enum|extension|fileprivate|func|import|init|inout|internal|let|open|operator|private|precedencegroup|protocol|public|rethrows|static|struct|subscript|typealias|var|break|case|catch|continue|default|defer|do|else|fallthrough|for|guard|if|in|repeat|return|throw|switch|where|while|Any|as|await|false|is|nil|self|Self|super|throws|true|try|async|actor|nonisolated|isolated|convenience|dynamic|final|indirect|lazy|mutating|nonmutating|optional|override|required|unowned|weak)\\b", .keyword),
                // Type names (capitalized)
                ("\\b[A-Z][a-zA-Z0-9]*\\b", .type),
                // Function calls
                ("\\b[a-z][a-zA-Z0-9]*(?=\\()", .function_),
            ]
        case .java:
            return [
                ("//[^\n]*", .comment),
                ("/\\*[\\s\\S]*?\\*/", .comment),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("'(?:[^'\\\\]|\\\\.)'", .string),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?[fFdD]?\\b", .number),
                ("\\b0x[0-9a-fA-F]+[lL]?\\b", .number),
                ("\\b\\d+[lL]?\\b", .number),
                ("@\\w+", .preprocessor),
                ("\\b(abstract|assert|boolean|break|byte|case|catch|char|class|const|continue|default|do|double|else|enum|extends|final|finally|float|for|goto|if|implements|import|instanceof|int|interface|long|native|new|package|private|protected|public|return|short|static|strictfp|super|switch|synchronized|this|throw|throws|transient|try|var|void|volatile|while|true|false|null|record|sealed|permits|yield)\\b", .keyword),
                ("\\b[A-Z][a-zA-Z0-9]*\\b", .type),
                ("\\b[a-z][a-zA-Z0-9]*(?=\\()", .function_),
            ]
        case .javascript, .typescript:
            return [
                ("//[^\n]*", .comment),
                ("/\\*[\\s\\S]*?\\*/", .comment),
                ("`(?:[^`\\\\]|\\\\.)*`", .string),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("'(?:[^'\\\\]|\\\\.)*'", .string),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?n?\\b", .number),
                ("\\b0x[0-9a-fA-F]+n?\\b", .number),
                ("\\b\\d+n?\\b", .number),
                ("\\b(break|case|catch|class|const|continue|debugger|default|delete|do|else|export|extends|false|finally|for|function|if|import|in|instanceof|let|new|null|return|static|super|switch|this|throw|true|try|typeof|undefined|var|void|while|with|yield|async|await|of|from|as|get|set|interface|type|enum|implements|namespace|declare|abstract|override|readonly|keyof|infer|never|unknown|any|string|number|boolean|symbol|bigint|object)\\b", .keyword),
                ("\\b[A-Z][a-zA-Z0-9]*\\b", .type),
                ("\\b[a-z_][a-zA-Z0-9_]*(?=\\()", .function_),
            ]
        case .python:
            return [
                ("#[^\n]*", .comment),
                ("\"\"\"[\\s\\S]*?\"\"\"", .string),
                ("'''[\\s\\S]*?'''", .string),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("'(?:[^'\\\\]|\\\\.)*'", .string),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?[jJ]?\\b", .number),
                ("\\b0x[0-9a-fA-F]+\\b", .number),
                ("\\b0o[0-7]+\\b", .number),
                ("\\b0b[01]+\\b", .number),
                ("\\b\\d+[jJ]?\\b", .number),
                ("@\\w+", .preprocessor),
                ("\\b(False|None|True|and|as|assert|async|await|break|class|continue|def|del|elif|else|except|finally|for|from|global|if|import|in|is|lambda|nonlocal|not|or|pass|raise|return|try|while|with|yield|self|cls|print|len|range|type|list|dict|set|tuple|str|int|float|bool|bytes|super|property|staticmethod|classmethod|abstractmethod)\\b", .keyword),
                ("\\b[A-Z][a-zA-Z0-9_]*\\b", .type),
                ("\\b[a-z_][a-zA-Z0-9_]*(?=\\()", .function_),
            ]
        case .html:
            return [
                ("<!--[\\s\\S]*?-->", .comment),
                ("<script[\\s\\S]*?</script>", .string),
                ("<style[\\s\\S]*?</style>", .preprocessor),
                ("</?[a-zA-Z][a-zA-Z0-9]*", .keyword),
                (">", .keyword),
                ("[a-zA-Z-]+(?==)", .type),
                ("\"[^\"]*\"", .string),
                ("'[^']*'", .string),
                ("&[a-zA-Z]+;|&#\\d+;|&#x[0-9a-fA-F]+;", .number),
            ]
        case .css:
            return [
                ("/\\*[\\s\\S]*?\\*/", .comment),
                ("//[^\n]*", .comment),
                ("#[0-9a-fA-F]{3,8}\\b", .number),
                ("\\b\\d+\\.?\\d*(?:px|em|rem|vh|vw|vmin|vmax|%|deg|rad|s|ms|fr|pt|pc|cm|mm|in|ex|ch|lh|rlh|svh|svw|dvh|dvw)?\\b", .number),
                ("\"[^\"]*\"", .string),
                ("'[^']*'", .string),
                ("@[a-zA-Z-]+", .preprocessor),
                ("[.#:][a-zA-Z][a-zA-Z0-9_-]*", .type),
                ("[a-zA-Z][a-zA-Z0-9-]*(?=\\s*:)", .keyword),
                ("\\b(auto|none|inherit|initial|unset|important|flex|grid|block|inline|absolute|relative|fixed|sticky|bold|normal|italic|solid|dashed|dotted|transparent|currentColor)\\b", .keyword),
                ("[a-zA-Z-]+(?=\\()", .function_),
            ]
        case .c:
            return [
                ("//[^\n]*", .comment),
                ("/\\*[\\s\\S]*?\\*/", .comment),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("'(?:[^'\\\\]|\\\\.)'", .string),
                ("#\\s*(?:include|define|ifdef|ifndef|endif|else|elif|undef|pragma|error|warning|line)[^\n]*", .preprocessor),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?[fFlL]?\\b", .number),
                ("\\b0x[0-9a-fA-F]+[uUlL]*\\b", .number),
                ("\\b\\d+[uUlL]*\\b", .number),
                ("\\b(auto|break|case|char|const|continue|default|do|double|else|enum|extern|float|for|goto|if|inline|int|long|register|restrict|return|short|signed|sizeof|static|struct|switch|typedef|union|unsigned|void|volatile|while|NULL|true|false|bool|uint8_t|uint16_t|uint32_t|uint64_t|int8_t|int16_t|int32_t|int64_t|size_t|ptrdiff_t)\\b", .keyword),
                ("\\b[A-Z][A-Z0-9_]*\\b", .type),
                ("\\b[a-z_][a-zA-Z0-9_]*(?=\\()", .function_),
            ]
        case .cpp:
            return [
                ("//[^\n]*", .comment),
                ("/\\*[\\s\\S]*?\\*/", .comment),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("'(?:[^'\\\\]|\\\\.)*'", .string),
                ("#\\s*(?:include|define|ifdef|ifndef|endif|else|elif|undef|pragma|error|warning|line)[^\n]*", .preprocessor),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?[fFlL]?\\b", .number),
                ("\\b0x[0-9a-fA-F]+[uUlL]*\\b", .number),
                ("\\b\\d+[uUlL]*\\b", .number),
                ("\\b(alignas|alignof|and|and_eq|asm|auto|bitand|bitor|bool|break|case|catch|char|char8_t|char16_t|char32_t|class|compl|concept|const|consteval|constexpr|constinit|const_cast|continue|co_await|co_return|co_yield|decltype|default|delete|do|double|dynamic_cast|else|enum|explicit|export|extern|false|float|for|friend|goto|if|inline|int|long|mutable|namespace|new|noexcept|not|not_eq|nullptr|operator|or|or_eq|private|protected|public|register|reinterpret_cast|requires|return|short|signed|sizeof|static|static_assert|static_cast|struct|switch|template|this|thread_local|throw|true|try|typedef|typeid|typename|union|unsigned|using|virtual|void|volatile|wchar_t|while|xor|xor_eq|NULL|size_t)\\b", .keyword),
                ("\\b[A-Z][a-zA-Z0-9_]*\\b", .type),
                ("\\b[a-z_][a-zA-Z0-9_]*(?=\\()", .function_),
            ]
        case .go:
            return [
                ("//[^\n]*", .comment),
                ("/\\*[\\s\\S]*?\\*/", .comment),
                ("`[^`]*`", .string),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("'(?:[^'\\\\]|\\\\.)*'", .string),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?[fFiI]?\\b", .number),
                ("\\b0x[0-9a-fA-F]+\\b", .number),
                ("\\b0o[0-7]+\\b", .number),
                ("\\b0b[01]+\\b", .number),
                ("\\b\\d+[iI]?\\b", .number),
                ("\\b(break|case|chan|const|continue|default|defer|else|fallthrough|for|func|go|goto|if|import|interface|map|package|range|return|select|struct|switch|type|var|true|false|nil|iota|append|cap|close|copy|delete|imag|len|make|new|panic|print|println|real|recover|error|string|int|int8|int16|int32|int64|uint|uint8|uint16|uint32|uint64|float32|float64|complex64|complex128|byte|rune|bool|uintptr)\\b", .keyword),
                ("\\b[A-Z][a-zA-Z0-9]*\\b", .type),
                ("\\b[a-z_][a-zA-Z0-9_]*(?=\\()", .function_),
            ]
        case .rust:
            return [
                ("//[^\n]*", .comment),
                ("/\\*[\\s\\S]*?\\*/", .comment),
                ("r#\"[\\s\\S]*?\"#", .string),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("'(?:[^'\\\\]|\\\\.)*'", .string),
                ("#!?\\[[^\\]]*\\]", .preprocessor),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?(?:f32|f64)?\\b", .number),
                ("\\b0x[0-9a-fA-F_]+(?:u8|u16|u32|u64|u128|usize|i8|i16|i32|i64|i128|isize)?\\b", .number),
                ("\\b0o[0-7_]+\\b", .number),
                ("\\b0b[01_]+\\b", .number),
                ("\\b\\d[\\d_]*(?:u8|u16|u32|u64|u128|usize|i8|i16|i32|i64|i128|isize|f32|f64)?\\b", .number),
                ("\\b(as|async|await|break|const|continue|crate|dyn|else|enum|extern|false|fn|for|if|impl|in|let|loop|match|mod|move|mut|pub|ref|return|self|Self|static|struct|super|trait|true|type|unsafe|use|where|while|u8|u16|u32|u64|u128|usize|i8|i16|i32|i64|i128|isize|f32|f64|bool|char|str|String|Vec|Option|Result|Some|None|Ok|Err|Box|Rc|Arc|Cell|RefCell|HashMap|HashSet|println|print|eprintln|eprint|panic|assert|assert_eq|todo|unimplemented|unreachable|dbg)\\b", .keyword),
                ("\\b[A-Z][a-zA-Z0-9]*\\b", .type),
                ("\\b[a-z_][a-zA-Z0-9_]*(?=!?\\()", .function_),
            ]
        case .json:
            return [
                ("\"(?:[^\"\\\\]|\\\\.)*\"\\s*:", .keyword),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?\\b", .number),
                ("\\b\\d+\\b", .number),
                ("\\b(true|false|null)\\b", .keyword),
            ]
        case .ruby:
            return [
                ("#[^\n]*", .comment),
                ("=begin[\\s\\S]*?=end", .comment),
                ("%q\\{[^}]*\\}", .string),
                ("%Q\\{[^}]*\\}", .string),
                ("\"(?:[^\"\\\\]|\\\\.)*\"", .string),
                ("'(?:[^'\\\\]|\\\\.)*'", .string),
                ("/(?:[^/\\\\]|\\\\.)+/[imxouesn]*", .string),
                (":[a-zA-Z_][a-zA-Z0-9_]*", .type),
                ("\\b\\d+\\.\\d+(?:[eE][+-]?\\d+)?\\b", .number),
                ("\\b0x[0-9a-fA-F]+\\b", .number),
                ("\\b0o[0-7]+\\b", .number),
                ("\\b0b[01]+\\b", .number),
                ("\\b\\d+\\b", .number),
                ("\\b(BEGIN|END|__ENCODING__|__FILE__|__LINE__|alias|and|begin|break|case|class|def|defined\\?|do|else|elsif|end|ensure|false|for|if|in|module|next|nil|not|or|redo|rescue|retry|return|self|super|then|true|undef|unless|until|when|while|yield|puts|print|p|pp|require|require_relative|attr_accessor|attr_reader|attr_writer|include|extend|prepend|private|protected|public|raise|fail|lambda|proc|block_given\\?)\\b", .keyword),
                ("\\b[A-Z][a-zA-Z0-9_]*\\b", .type),
                ("\\b[a-z_][a-zA-Z0-9_]*(?=\\(|\\s+do)", .function_),
            ]
        case .plainText:
            return []
        }
    }

    // MARK: - Language Detection

    static func detect(from ext: String) -> Language {
        let lowercased = ext.lowercased()
        for language in Language.allCases {
            if language.fileExtensions.contains(lowercased) {
                return language
            }
        }
        return .plainText
    }
}
