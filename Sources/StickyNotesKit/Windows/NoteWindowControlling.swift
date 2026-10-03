import CoreGraphics

/// Abstraction over the hosting `NSPanel` used by the SwiftUI content to request
/// geometry changes. Keeps the presentation layer free of an AppKit import.
@MainActor
protocol NoteWindowControlling: AnyObject {
    /// Current size of the window's content area.
    var contentSize: CGSize { get }

    /// Resizes the window's content area, keeping the top-left corner anchored.
    func resizeContent(to size: CGSize)

    /// Applies the pinned window behavior: pinned notes float above other
    /// applications; unpinned notes behave like regular windows.
    func applyPinned(_ isPinned: Bool)
}
