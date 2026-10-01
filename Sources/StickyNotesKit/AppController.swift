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

    /// Enlarges the font size of the focused note.
    public func increaseFontSize() {
        adjustFontSize(by: AppConstants.fontSizeStep)
    }

    /// Shrinks the font size of the focused note.
    public func decreaseFontSize() {
        adjustFontSize(by: -AppConstants.fontSizeStep)
    }

    /// Flushes the geometry of every open note. Called on app termination.
    public func persistAll() {
        coordinator.persistAll()
    }

    private func adjustFontSize(by delta: Double) {
        guard let id = coordinator.activeNoteID else { return }
        store.update(id: id) { note in
            let newSize = note.fontSize + delta
            note.fontSize = min(max(newSize, AppConstants.minimumFontSize), AppConstants.maximumFontSize)
        }
    }
}
