import Foundation
import Testing
@testable import StickyNotesKit

@MainActor
private final class MockNoteWindowController: NoteWindowControlling {
    var appliedPinState: Bool?
    var contentSize: CGSize = .zero

    func resizeContent(to size: CGSize) {}
    func applyPinned(_ isPinned: Bool) { appliedPinState = isPinned }
}

@MainActor
struct NotePinningTests {
    @Test("new notes are created unpinned")
    func newNotesStartUnpinned() {
        let store = NotesStore(repository: JSONFileRepository(directory: TestSupport.makeTemporaryDirectory()))

        let note = store.createNote()

        #expect(!note.isPinned)
    }

    @Test("toggling pin persists the state and updates the window")
    func togglePinPersistsAndUpdatesWindow() {
        let store = NotesStore(repository: JSONFileRepository(directory: TestSupport.makeTemporaryDirectory()))
        let note = store.createNote()
        let viewModel = NoteViewModel(note: note, store: store)
        let controller = MockNoteWindowController()
        viewModel.windowController = controller

        viewModel.togglePinned()

        #expect(store.note(id: note.id)?.isPinned == true)
        #expect(controller.appliedPinState == true)

        viewModel.togglePinned()

        #expect(store.note(id: note.id)?.isPinned == false)
        #expect(controller.appliedPinState == false)
    }

    @Test("the pinned state is persisted and restored")
    func persistsPinnedState() {
        let directory = TestSupport.makeTemporaryDirectory()
        let first = NotesStore(repository: JSONFileRepository(directory: directory))
        let note = first.createNote()
        let viewModel = NoteViewModel(note: note, store: first)

        viewModel.togglePinned()

        let restored = NotesStore(repository: JSONFileRepository(directory: directory))
        restored.load()

        #expect(restored.note(id: note.id)?.isPinned == true)
    }
}
