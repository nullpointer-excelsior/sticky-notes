import AppKit

/// Borderless, floating panel that hosts a single sticky note.
///
/// A borderless panel does not receive keyboard focus by default, so
/// `canBecomeKey` is overridden; without it the Markdown editor would be
/// unusable. The panel joins every space and stays above regular windows.
final class StickyPanel: NSPanel, NoteWindowControlling {
    /// Identifier of the note this panel renders, used to route window events
    /// back to the owning model.
    var noteID: UUID?

    init(frame: NoteFrame) {
        super.init(
            contentRect: frame.nsRect,
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )
        configureStickyBehavior()
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    private func configureStickyBehavior() {
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isFloatingPanel = true
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
}
