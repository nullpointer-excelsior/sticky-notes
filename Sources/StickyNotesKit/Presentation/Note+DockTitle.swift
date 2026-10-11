import Foundation

extension Note {
    /// Title shown for this note in the Dock menu: the first non-empty line of
    /// the text, trimmed and truncated with an ellipsis when it exceeds
    /// `AppConstants.dockMenuTitleMaxLength`. Notes without a usable first line
    /// fall back to a positional placeholder, so the menu stays unambiguous.
    func dockTitle(position: Int) -> String {
        guard let line = firstNonEmptyLine else {
            return "\(AppConstants.dockMenuUntitledPrefix) \(position)"
        }
        guard line.count > AppConstants.dockMenuTitleMaxLength else {
            return line
        }
        return String(line.prefix(AppConstants.dockMenuTitleMaxLength)) + AppConstants.dockMenuTitleEllipsis
    }

    private var firstNonEmptyLine: String? {
        for rawLine in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = rawLine.trimmingCharacters(in: .whitespacesAndNewlines)
            if !line.isEmpty {
                return line
            }
        }
        return nil
    }
}
