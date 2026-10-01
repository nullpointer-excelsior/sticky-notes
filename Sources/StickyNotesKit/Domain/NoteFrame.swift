import Foundation

/// Persistent geometry of a note window. Stored as part of the `Note` model
/// so that position, size and stacking survive across sessions.
struct NoteFrame: Codable, Equatable, Sendable {
    var x: Double
    var y: Double
    var width: Double
    var height: Double

    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

extension NoteFrame {
    /// Returns a copy resized to `size`, clamped to the given minimum, keeping
    /// the top-left corner anchored: the y origin moves by the height delta.
    func resized(to size: CGSize, minimumWidth: Double, minimumHeight: Double) -> NoteFrame {
        let width = max(minimumWidth, size.width)
        let height = max(minimumHeight, size.height)
        return NoteFrame(x: x, y: y - (height - self.height), width: width, height: height)
    }
}
