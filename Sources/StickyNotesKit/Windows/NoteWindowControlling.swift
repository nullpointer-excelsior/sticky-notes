import CoreGraphics

/// Abstraction over the hosting `NSPanel` used by the SwiftUI content to request
/// geometry changes. Keeps the presentation layer free of an AppKit import.
@MainActor
protocol NoteWindowControlling: AnyObject {
    /// Current size of the window's content area.
    var contentSize: CGSize { get }

    /// Resizes the window's content area, keeping the top-left corner anchored.
    func resizeContent(to size: CGSize)
}
