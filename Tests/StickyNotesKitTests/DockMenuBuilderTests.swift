import AppKit
import Foundation
import Testing
@testable import StickyNotesKit

@MainActor
private final class MenuTarget: NSObject {
    var focusedNoteID: UUID?
    var didCreateNote = false

    @objc func focusNote(_ sender: NSMenuItem) {
        focusedNoteID = sender.representedObject as? UUID
    }

    @objc func createNote(_ sender: NSMenuItem) {
        didCreateNote = true
    }
}

@MainActor
struct DockMenuBuilderTests {
    @Test("builds one enabled item per note in order, then a separator and New Note")
    func buildsOneItemPerNote() {
        let notes = [makeNote(text: "First"), makeNote(text: "Second")]
        let target = MenuTarget()

        let menu = DockMenuBuilder().buildMenu(
            notes: notes,
            target: target,
            focusSelector: #selector(MenuTarget.focusNote(_:)),
            newNoteSelector: #selector(MenuTarget.createNote(_:))
        )

        #expect(menu.autoenablesItems == false)
        #expect(menu.items.count == notes.count + 2)

        for (index, note) in notes.enumerated() {
            let item = menu.items[index]
            #expect(item.title == note.dockTitle(position: index + 1))
            #expect(item.representedObject as? UUID == note.id)
            #expect(item.target === target)
            #expect(item.isEnabled)
        }

        #expect(menu.items[notes.count].isSeparatorItem)

        let newNoteItem = menu.items.last
        #expect(newNoteItem?.title == AppConstants.dockMenuNewNoteTitle)
        #expect(newNoteItem?.isEnabled == true)
    }

    @Test("an empty store shows a single disabled item plus the New Note item")
    func emptyStoreShowsEmptyState() {
        let menu = DockMenuBuilder().buildMenu(
            notes: [],
            target: MenuTarget(),
            focusSelector: #selector(MenuTarget.focusNote(_:)),
            newNoteSelector: #selector(MenuTarget.createNote(_:))
        )

        #expect(menu.items.count == 3)
        #expect(menu.items[0].title == AppConstants.dockMenuEmptyStateTitle)
        #expect(menu.items[0].isEnabled == false)
        #expect(menu.items[1].isSeparatorItem)
        #expect(menu.items[2].title == AppConstants.dockMenuNewNoteTitle)
        #expect(menu.items[2].isEnabled == true)
    }

    private func makeNote(text: String) -> Note {
        let now = Date()
        return Note(
            id: UUID(),
            text: text,
            color: .yellow,
            frame: NoteFrame(x: 0, y: 0, width: 280, height: 240),
            zIndex: 0,
            createdAt: now,
            updatedAt: now
        )
    }
}
