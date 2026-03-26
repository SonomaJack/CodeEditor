// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CodeEditor",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "CodeEditor",
            path: "Sources/CodeEditor"
        )
    ]
)
