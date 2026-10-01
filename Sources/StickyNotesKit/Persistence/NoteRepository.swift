import Foundation

/// Persistence contract for notes (minimal hexagonal port).
///
/// Implementations must isolate per-note failures: a single unreadable or
/// corrupted note must never prevent the remaining notes from loading.
protocol NoteRepository: AnyObject {
    /// Loads every stored note, ordered by stacking index (ascending).
    func loadAll() throws -> [Note]

    /// Creates or overwrites the stored representation of `note`.
    func save(_ note: Note) throws

    /// Removes the stored representation of the note with `id`, if present.
    func delete(id: UUID) throws
}
