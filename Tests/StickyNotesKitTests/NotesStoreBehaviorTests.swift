import Foundation
import Testing
@testable import StickyNotesKit

@MainActor
struct NotesStoreBehaviorTests {
    @Test("bringToFront promotes the note above the others without a crash")
    func bringToFrontPromotesNote() {
        let store = NotesStore(repository: JSONFileRepository(directory: TestSupport.makeTemporaryDirectory()))
        let first = store.createNote()
        let second = store.createNote()
        #expect(store.note(id: second.id)!.zIndex > store.note(id: first.id)!.zIndex)

        store.bringToFront(id: first.id)

        #expect(store.note(id: first.id)!.zIndex > store.note(id: second.id)!.zIndex)
    }

    @Test("bringToFront ignores unknown ids")
    func bringToFrontIgnoresUnknownIds() {
        let store = NotesStore(repository: JSONFileRepository(directory: TestSupport.makeTemporaryDirectory()))
        _ = store.createNote()

        store.bringToFront(id: UUID())

        #expect(store.notes.count == 1)
    }

    @Test("resizing anchors the top-left corner and clamps to the minimum")
    func resizeAnchorsTopLeftAndClamps() {
        let frame = NoteFrame(x: 100, y: 200, width: 300, height: 240)

        let grown = frame.resized(to: CGSize(width: 400, height: 340), minimumWidth: 180, minimumHeight: 140)
        #expect(grown.x == 100)
        #expect(grown.width == 400)
        #expect(grown.height == 340)
        #expect(grown.y == 200 - (340 - 240))

        let clamped = grown.resized(to: CGSize(width: 10, height: 10), minimumWidth: 180, minimumHeight: 140)
        #expect(clamped.x == 100)
        #expect(clamped.width == 180)
        #expect(clamped.height == 140)

        // Re-applying an already clamped size must not drift the origin.
        let reapplied = clamped.resized(to: CGSize(width: 10, height: 10), minimumWidth: 180, minimumHeight: 140)
        #expect(reapplied == clamped)
    }

    @Test("autosave commits the draft after the debounce interval")
    func autosaveCommitsAfterDebounce() async throws {
        let store = NotesStore(repository: JSONFileRepository(directory: TestSupport.makeTemporaryDirectory()))
        let note = store.createNote()
        let viewModel = NoteViewModel(note: note, store: store)

        viewModel.beginEditing()
        viewModel.draftText = "written while editing"
        viewModel.scheduleAutosave()

        try await Task.sleep(for: .seconds(AppConstants.autosaveDebounce + 0.3))

        #expect(store.note(id: note.id)?.text == "written while editing")
    }
}
