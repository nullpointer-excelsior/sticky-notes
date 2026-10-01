import Foundation

/// Converts raw Markdown into an `AttributedString` for display.
///
/// Rendering never fails from the caller's perspective: empty input yields an
/// empty result and malformed input falls back to the unparsed text.
enum MarkdownRenderer {
    static func render(_ markdown: String) -> AttributedString {
        do {
            return try AttributedString(markdown: markdown)
        } catch {
            return AttributedString(markdown)
        }
    }
}
