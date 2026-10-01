import Foundation
import Testing
@testable import StickyNotesKit

@MainActor
struct NoteDeletionTests {
    @Test("TEST-6: deleting the only note empties the store without errors")
    func deletesOnlyNote() throws {
        let directory = TestSupport.makeTemporaryDirectory()
        let repository = JSONFileRepository(directory: directory)
        let store = NotesStore(repository: repository)
        let note = store.createNote()
        #expect(store.notes.count == 1)

        store.delete(id: note.id)

        #expect(store.notes.isEmpty)
        #expect(try repository.loadAll().isEmpty)
    }
}
