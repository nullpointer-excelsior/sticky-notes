import Foundation
import Observation

/// Per-note state and behavior. Reads its note through the store (single source
/// of truth) and routes every mutation back through it.
@MainActor
@Observable
final class NoteViewModel {
    let id: UUID

    /// Raw Markdown currently bound to the editor.
    var draftText: String

    /// Markdown rendered to formatted text, refreshed when editing ends.
    private(set) var renderedText: AttributedString

    /// Whether the note is in raw Markdown edit mode.
    var isEditing = false

    /// Hosting window, injected by the window layer. Weak to avoid a retain
    /// cycle: the panel owns the hosting view which owns this view model.
    weak var windowController: NoteWindowControlling?

    private let store: NotesStore
    private let initialNote: Note
    private var autosaveTask: Task<Void, Never>?

    init(note: Note, store: NotesStore) {
        self.id = note.id
        self.initialNote = note
        self.store = store
        self.draftText = note.text
        self.renderedText = MarkdownRenderer.render(note.text)
    }

    /// Current persisted note, falling back to the initial snapshot if it has
    /// already been removed from the store.
    var note: Note {
        store.note(id: id) ?? initialNote
    }

    func beginEditing() {
        draftText = note.text
        isEditing = true
    }

    /// Commits the draft and renders it. Called when the note loses focus.
    func endEditing() {
        guard isEditing else { return }
        isEditing = false
        commitText()
    }

    /// Debounced autosave for in-progress edits.
    func scheduleAutosave() {
        autosaveTask?.cancel()
        autosaveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(AppConstants.autosaveDebounce * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.commitText()
        }
    }

    func commitText() {
        store.update(id: id) { $0.text = draftText }
        renderedText = MarkdownRenderer.render(draftText)
    }

    func setColor(_ color: NoteColor) {
        store.update(id: id) { $0.color = color }
    }

    /// Flips the pin state, persists it, and applies it to the hosting window.
    func togglePinned() {
        store.update(id: id) { $0.isPinned.toggle() }
        windowController?.applyPinned(note.isPinned)
    }

    func createNote() {
        store.createNote()
    }

    func deleteSelf() {
        store.delete(id: id)
    }
}
