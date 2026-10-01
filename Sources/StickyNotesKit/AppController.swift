import AppKit

/// Public entry point of the kit. Wires the store with the window coordinator
/// and exposes the lifecycle operations the app target needs.
@MainActor
public final class AppController {
    private let store: NotesStore
    private let coordinator: WindowCoordinator

    public init() {
        let repository = JSONFileRepository(directory: JSONFileRepository.defaultDirectory())
        let store = NotesStore(repository: repository)
        self.store = store
        self.coordinator = WindowCoordinator(store: store)
    }

    /// Loads persisted notes, restores their panels and guarantees at least one
    /// note exists so the "+" control from UC-1 is always reachable.
    public func start() {
        store.load()
        coordinator.restoreAll()
        if store.notes.isEmpty {
            store.createNote()
        }
    }

    /// Creates a new empty note and shows its panel.
    public func createNote() {
        store.createNote()
    }

    /// Flushes the geometry of every open note. Called on app termination.
    public func persistAll() {
        coordinator.persistAll()
    }
}
