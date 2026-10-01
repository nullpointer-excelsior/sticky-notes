import Foundation
import Testing
@testable import StickyNotesKit

struct MarkdownRendererTests {
    @Test("Markdown blocks render on separate lines")
    func keepsBlocksOnSeparateLines() {
        let rendered = MarkdownRenderer.render("# Hello\nsoy una nota")

        #expect(String(rendered.characters) == "Hello\nsoy una nota")
    }

    @Test("Unordered list items render with bullets")
    func rendersUnorderedListMarkers() {
        let rendered = MarkdownRenderer.render("- item\n- otro item")

        #expect(String(rendered.characters) == "• item\n• otro item")
    }

    @Test("Ordered list items render with their ordinal")
    func rendersOrderedListMarkers() {
        let rendered = MarkdownRenderer.render("1. first\n2. second")

        #expect(String(rendered.characters) == "1. first\n2. second")
    }

    @Test("Nested list items are indented")
    func indentsNestedListItems() {
        let rendered = MarkdownRenderer.render("- a\n  - nested")

        #expect(String(rendered.characters) == "• a\n  • nested")
    }

    @Test("Empty input renders empty")
    func rendersEmptyInput() {
        #expect(MarkdownRenderer.render("").characters.isEmpty)
    }
}
