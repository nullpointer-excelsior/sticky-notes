import Foundation
import Testing
@testable import StickyNotesKit

struct NoteDockTitleTests {
    @Test("uses the first non-empty line, trimmed of surrounding whitespace")
    func usesFirstNonEmptyLine() {
        let note = makeNote(text: "  \n  First line  \nSecond line")

        #expect(note.dockTitle(position: 1) == "First line")
    }

    @Test("blank or whitespace-only text falls back to a positional placeholder")
    func blankTextUsesPositionalFallback() {
        let blank = makeNote(text: "")
        let whitespace = makeNote(text: "   \n\t\n  ")

        #expect(blank.dockTitle(position: 3) == "Note 3")
        #expect(whitespace.dockTitle(position: 2) == "Note 2")
    }

    @Test("titles longer than the limit are truncated with an ellipsis")
    func truncatesLongTitles() {
        let text = String(repeating: "a", count: AppConstants.dockMenuTitleMaxLength + 1)

        let title = makeNote(text: text).dockTitle(position: 1)

        #expect(title.count == AppConstants.dockMenuTitleMaxLength + 1)
        #expect(title.hasSuffix(AppConstants.dockMenuTitleEllipsis))
        #expect(title == String(repeating: "a", count: AppConstants.dockMenuTitleMaxLength) + AppConstants.dockMenuTitleEllipsis)
    }

    @Test("titles of exactly the maximum length are left unmodified")
    func leavesExactLengthUntouched() {
        let text = String(repeating: "b", count: AppConstants.dockMenuTitleMaxLength)

        #expect(makeNote(text: text).dockTitle(position: 1) == text)
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
