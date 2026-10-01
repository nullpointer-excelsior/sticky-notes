import Foundation
import Observation
import os

/// Global collection state. Owns the note list and delegates every write to the
/// persistence port. Views observe this type; presentation never touches the
/// repository directly.
@MainActor
@Observable
final class NotesStore {
    private(set) var notes: [Note] = []

    /// Notifications used by the window layer to react to collection changes.
    var onNoteAdded: ((Note) -> Void)?
    var onNoteRemoved: ((UUID) -> Void)?

    private let repository: NoteRepository
    private let logger = Logger(subsystem: AppConstants.loggerSubsystem, category: "persistence")

    init(repository: NoteRepository) {
        self.repository = repository
    }

    /// Loads persisted notes into memory, ordered by stacking index.
    @discardableResult
    func load() -> [Note] {
        do {
            notes = try repository.loadAll().sorted { $0.zIndex < $1.zIndex }
        } catch {
            logger.error("Failed to load notes: \(error.localizedDescription, privacy: .public)")
            notes = []
        }
        return notes
    }

    /// Creates a new empty note, persists it and notifies observers.
    @discardableResult
    func createNote() -> Note {
        var frame = AppConstants.defaultNoteFrame
        let cascade = Double(notes.count) * AppConstants.newNoteOffset
        frame.x += cascade
        frame.y += cascade

        let now = Date()
        let note = Note(
            id: UUID(),
            text: "",
            color: AppConstants.defaultColor,
            frame: frame,
            zIndex: nextZIndex(excluding: nil),
            createdAt: now,
            updatedAt: now
        )
        notes.append(note)
        save(note)
        onNoteAdded?(note)
        return note
    }

    /// Mutates a single note in place and persists the result. Field-scoped
    /// mutation avoids clobbering concurrent changes with a stale copy.
    func update(id: UUID, _ transform: (inout Note) -> Void) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        transform(&notes[index])
        notes[index].updatedAt = Date()
        save(notes[index])
    }

    /// Removes a note from state and storage and notifies observers.
    func delete(id: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        notes.remove(at: index)
        deleteStored(id: id)
        onNoteRemoved?(id)
    }

    func note(id: UUID) -> Note? {
        notes.first { $0.id == id }
    }

    /// Promotes a note to the top of the stacking order and persists it.
    func bringToFront(id: UUID) {
        guard notes.contains(where: { $0.id == id }) else { return }
        // Resolve the new index before mutating, so `update`'s exclusive access
        // to `notes` never overlaps a read of the whole array.
        let newZIndex = nextZIndex(excluding: id)
        update(id: id) { $0.zIndex = newZIndex }
    }

    private func nextZIndex(excluding id: UUID?) -> Int {
        let highest = notes.filter { $0.id != id }.map(\.zIndex).max() ?? 0
        return highest + 1
    }

    private func save(_ note: Note) {
        do {
            try repository.save(note)
        } catch {
            logger.error("Failed to save note \(note.id.uuidString, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }

    private func deleteStored(id: UUID) {
        do {
            try repository.delete(id: id)
        } catch {
            logger.error("Failed to delete note \(id.uuidString, privacy: .public): \(error.localizedDescription, privacy: .public)")
        }
    }
}
