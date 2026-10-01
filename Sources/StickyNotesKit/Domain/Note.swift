import Foundation

/// A single sticky note. Window geometry (`frame`, `zIndex`) is part of the
/// model on purpose: it is persistent state, not ephemeral UI state.
struct Note: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var text: String
    var color: NoteColor
    var frame: NoteFrame
    var zIndex: Int
    let createdAt: Date
    var updatedAt: Date

    init(id: UUID, text: String, color: NoteColor, frame: NoteFrame, zIndex: Int, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.text = text
        self.color = color
        self.frame = frame
        self.zIndex = zIndex
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
