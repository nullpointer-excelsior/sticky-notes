import Foundation
import SwiftUI

/// Converts raw Markdown into an `AttributedString` for display.
///
/// `AttributedString`'s Markdown parser encodes block elements (headings,
/// paragraphs, lists) as presentation intents, which `Text` does not draw. This
/// renderer walks the parsed result and restores the visible structure: line
/// breaks between blocks, list markers, and heading emphasis.
///
/// Rendering never fails from the caller's perspective: empty input yields an
/// empty result and malformed input falls back to the unparsed text.
enum MarkdownRenderer {
    static func render(_ markdown: String) -> AttributedString {
        let parsed: AttributedString
        do {
            parsed = try AttributedString(markdown: markdown)
        } catch {
            return AttributedString(markdown)
        }
        return restoringBlockStructure(of: parsed)
    }

    private static func restoringBlockStructure(of source: AttributedString) -> AttributedString {
        var result = AttributedString()
        var previousBlockID: Int?

        for run in source.runs {
            guard let intent = run.presentationIntent else {
                result += AttributedString(source[run.range])
                continue
            }

            let blockID = intent.components.first?.identity
            if blockID != previousBlockID {
                if previousBlockID != nil {
                    result += AttributedString("\n")
                }
                result += AttributedString(listPrefix(for: intent))
                previousBlockID = blockID
            }

            var piece = AttributedString(source[run.range])
            applyHeadingStyle(to: &piece, intent: intent)
            result += piece
        }

        return result
    }

    /// Marker (with indentation for nested lists) that precedes a list item, or
    /// an empty string when the block is not part of a list.
    private static func listPrefix(for intent: PresentationIntent) -> String {
        var depth = 0
        var capturedListType = false
        var isOrdered = false
        var ordinal = 1
        var capturedOrdinal = false

        for component in intent.components {
            switch component.kind {
            case .unorderedList:
                depth += 1
                if !capturedListType { isOrdered = false; capturedListType = true }
            case .orderedList:
                depth += 1
                if !capturedListType { isOrdered = true; capturedListType = true }
            case .listItem(let number):
                if !capturedOrdinal { ordinal = number; capturedOrdinal = true }
            default:
                break
            }
        }

        guard depth > 0 else { return "" }
        let indent = String(repeating: "  ", count: depth - 1)
        return indent + (isOrdered ? "\(ordinal). " : "• ")
    }

    private static func applyHeadingStyle(to piece: inout AttributedString, intent: PresentationIntent) {
        guard let kind = intent.components.first?.kind, case .header(let level) = kind else { return }
        piece.font = .system(size: headingSize(for: level), weight: .bold)
    }

    private static func headingSize(for level: Int) -> CGFloat {
        switch level {
        case 1: return 18
        case 2: return 16
        case 3: return 15
        default: return 14
        }
    }
}
