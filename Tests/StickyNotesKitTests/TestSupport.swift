import Foundation
@testable import StickyNotesKit

/// Shared fixtures for the note tests.
enum TestSupport {
    /// Returns a unique, isolated storage directory for a single test.
    static func makeTemporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory
            .appendingPathComponent("StickyNotesTests-\(UUID().uuidString)", isDirectory: true)
    }
}
