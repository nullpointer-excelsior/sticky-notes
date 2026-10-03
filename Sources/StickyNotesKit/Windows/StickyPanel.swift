import AppKit

/// Borderless panel that hosts a single sticky note.
///
/// A borderless panel does not receive keyboard focus by default, so
/// `canBecomeKey` is overridden; without it the Markdown editor would be
/// unusable. The panel joins every space, and its window level follows the
/// note's `isPinned` flag: pinned notes float above other applications, while
/// unpinned notes sit at the normal level so they can be covered.
final class StickyPanel: NSPanel, NoteWindowControlling {
    /// Identifier of the note this panel renders, used to route window events
    /// back to the owning model.
    var noteID: UUID?

    init(frame: NoteFrame, isPinned: Bool = false) {
        super.init(
            contentRect: frame.nsRect,
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )
        configureStickyBehavior()
        applyPinned(isPinned)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    private func configureStickyBehavior() {
        level = .normal
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isFloatingPanel = false
        becomesKeyOnlyIfNeeded = false
        hidesOnDeactivate = false
        isMovableByWindowBackground = true
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        minSize = NSSize(
            width: AppConstants.minimumNoteWidth,
            height: AppConstants.minimumNoteHeight
        )
    }

    // MARK: - NoteWindowControlling

    var contentSize: CGSize {
        contentView?.frame.size ?? frame.size
    }

    func resizeContent(to size: CGSize) {
        let resized = NoteFrame(self.frame).resized(
            to: size,
            minimumWidth: AppConstants.minimumNoteWidth,
            minimumHeight: AppConstants.minimumNoteHeight
        )
        setFrame(resized.nsRect, display: true)
    }

    func applyPinned(_ isPinned: Bool) {
        isFloatingPanel = isPinned
        level = isPinned ? .floating : .normal
        if isPinned {
            orderFrontRegardless()
        }
    }
}
