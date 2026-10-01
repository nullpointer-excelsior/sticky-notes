import Foundation
import Testing
@testable import StickyNotesKit

@MainActor
struct NotePersistenceTests {
    @Test("TEST-3: notes are restored with identical text, color, frame and order")
    func restoresNotesAcrossSessions() {
        let directory = TestSupport.makeTemporaryDirectory()
        let first = NotesStore(repository: JSONFileRepository(directory: directory))
        let background = first.createNote()
        first.update(id: background.id) {
            $0.text = "background"
            $0.zIndex = 0
        }
        let foreground = first.createNote()
        first.update(id: foreground.id) {
            $0.text = "foreground"
            $0.color = .green
            $0.frame = NoteFrame(x: 12, y: 34, width: 300, height: 250)
            $0.zIndex = 5
        }

        let restored = NotesStore(repository: JSONFileRepository(directory: directory))
        restored.load()

        #expect(restored.notes.count == 2)
        #expect(restored.notes.first?.id == background.id)
        #expect(restored.notes.last?.id == foreground.id)
        #expect(restored.note(id: foreground.id)?.text == "foreground")
        #expect(restored.note(id: foreground.id)?.color == .green)
        #expect(restored.note(id: foreground.id)?.frame == NoteFrame(x: 12, y: 34, width: 300, height: 250))
    }

    @Test("TEST-4: the selected color is persisted and restored")
    func persistsColor() {
        let directory = TestSupport.makeTemporaryDirectory()
        let first = NotesStore(repository: JSONFileRepository(directory: directory))
        let note = first.createNote()
        let viewModel = NoteViewModel(note: note, store: first)
        viewModel.setColor(.purple)

        let restored = NotesStore(repository: JSONFileRepository(directory: directory))
        restored.load()

        #expect(restored.note(id: note.id)?.color == .purple)
    }

    @Test("TEST-5: frame changes from move and resize are persisted and restored")
    func persistsFrame() {
        let directory = TestSupport.makeTemporaryDirectory()
        let first = NotesStore(repository: JSONFileRepository(directory: directory))
        let note = first.createNote()
        let expected = NoteFrame(x: -40, y: 88, width: 420, height: 360)
        first.update(id: note.id) { $0.frame = expected }

        let restored = NotesStore(repository: JSONFileRepository(directory: directory))
        restored.load()

        #expect(restored.note(id: note.id)?.frame == expected)
    }

    @Test("the note font size is persisted and restored")
    func persistsFontSize() {
        let directory = TestSupport.makeTemporaryDirectory()
        let first = NotesStore(repository: JSONFileRepository(directory: directory))
        let note = first.createNote()
        first.update(id: note.id) { $0.fontSize = 20 }

        let restored = NotesStore(repository: JSONFileRepository(directory: directory))
        restored.load()

        #expect(restored.note(id: note.id)?.fontSize == 20)
    }

    @Test("notes persisted before fontSize existed load with the default size")
    func decodesLegacyNotesWithDefaultFontSize() throws {
        let id = UUID()
        let json = """
        {
          "id": "\(id.uuidString)",
          "text": "legacy",
          "color": "green",
          "frame": { "x": 0, "y": 0, "width": 200, "height": 150 },
          "zIndex": 1,
          "createdAt": "2024-01-01T00:00:00Z",
          "updatedAt": "2024-01-01T00:00:00Z"
        }
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let note = try decoder.decode(Note.self, from: Data(json.utf8))

        #expect(note.id == id)
        #expect(note.fontSize == AppConstants.defaultFontSize)
    }

    @Test("a corrupted note file is skipped without failing the whole load")
    func skipsCorruptedFiles() throws {
        let directory = TestSupport.makeTemporaryDirectory()
        let repository = JSONFileRepository(directory: directory)
        let store = NotesStore(repository: repository)
        let healthy = store.createNote()
        store.update(id: healthy.id) { $0.text = "keep" }

        let corruptURL = directory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        try Data("not json".utf8).write(to: corruptURL)

        let loaded = try repository.loadAll()

        #expect(loaded.count == 1)
        #expect(loaded.first?.id == healthy.id)
    }
}
