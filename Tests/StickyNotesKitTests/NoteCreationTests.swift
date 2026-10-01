import Foundation
import Testing
@testable import StickyNotesKit

@MainActor
struct NoteCreationTests {
    @Test("TEST-1: creating a note adds an empty note to the store")
    func createsEmptyNote() {
        let store = NotesStore(repository: JSONFileRepository(directory: TestSupport.makeTemporaryDirectory()))
        #expect(store.notes.isEmpty)

        let created = store.createNote()

        #expect(store.notes.count == 1)
        #expect(created.text.isEmpty)
        #expect(store.notes.first?.id == created.id)
    }

    @Test("TEST-2: Markdown is stored raw and rendered on blur")
    func storesRawMarkdownAndRendersOnBlur() {
        let store = NotesStore(repository: JSONFileRepository(directory: TestSupport.makeTemporaryDirectory()))
        let note = store.createNote()
        let viewModel = NoteViewModel(note: note, store: store)
        let markdown = "# Title\n- item 1\n- item 2"

        viewModel.beginEditing()
        viewModel.draftText = markdown
        viewModel.endEditing()

        #expect(store.note(id: note.id)?.text == markdown)
        #expect(!viewModel.renderedText.characters.isEmpty)
    }

    @Test("TEST-7: an empty note stays valid and renders without error")
    func emptyNoteIsValid() {
        let store = NotesStore(repository: JSONFileRepository(directory: TestSupport.makeTemporaryDirectory()))
        let note = store.createNote()
        let viewModel = NoteViewModel(note: note, store: store)

        #expect(viewModel.renderedText.characters.isEmpty)
        #expect(MarkdownRenderer.render("").characters.isEmpty)

        viewModel.beginEditing()
        viewModel.endEditing()

        #expect(store.note(id: note.id)?.text == "")
        #expect(viewModel.renderedText.characters.isEmpty)
    }
}
