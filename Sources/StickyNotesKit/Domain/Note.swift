import Foundation

/// A single sticky note. Window geometry (`frame`, `zIndex`) is part of the
/// model on purpose: it is persistent state, not ephemeral UI state.
struct Note: Codable, Identifiable, Equatable, Sendable {
    let id: UUID
    var text: String
    var color: NoteColor
    var frame: NoteFrame
    var zIndex: Int
    var fontSize: Double
    var isPinned: Bool
    let createdAt: Date
    var updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, text, color, frame, zIndex, fontSize, isPinned, createdAt, updatedAt
    }

    init(id: UUID, text: String, color: NoteColor, frame: NoteFrame, zIndex: Int, fontSize: Double = AppConstants.defaultFontSize, isPinned: Bool = false, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.text = text
        self.color = color
        self.frame = frame
        self.zIndex = zIndex
        self.fontSize = fontSize
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Custom decoding so notes persisted before `fontSize` and `isPinned`
    /// existed load with their defaults instead of being skipped as undecodable.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        color = try container.decode(NoteColor.self, forKey: .color)
        frame = try container.decode(NoteFrame.self, forKey: .frame)
        zIndex = try container.decode(Int.self, forKey: .zIndex)
        fontSize = try container.decodeIfPresent(Double.self, forKey: .fontSize) ?? AppConstants.defaultFontSize
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
