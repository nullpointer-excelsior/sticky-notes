// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "StickyNotes",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "StickyNotes", targets: ["StickyNotes"]),
        .library(name: "StickyNotesKit", targets: ["StickyNotesKit"])
    ],
    dependencies: [
        // Swift Testing. Declared explicitly because this environment ships the
        // Command Line Tools toolchain, whose bundled `Testing.framework` is not
        // auto-detected by SwiftPM. Test-only dependency; the app itself uses no
        // third-party runtime dependencies.
        .package(url: "https://github.com/swiftlang/swift-testing.git", .upToNextMinor(from: "6.2.4"))
    ],
    targets: [
        .target(
            name: "StickyNotesKit"
        ),
        .executableTarget(
            name: "StickyNotes",
            dependencies: ["StickyNotesKit"]
        ),
        .testTarget(
            name: "StickyNotesKitTests",
            dependencies: [
                "StickyNotesKit",
                .product(name: "Testing", package: "swift-testing")
            ]
        )
    ]
)
