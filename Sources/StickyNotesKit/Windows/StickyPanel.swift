import AppKit

/// Borderless panel that hosts a single sticky note.
///
/// A borderless panel does not receive keyboard focus by default, so
/// `canBecomeKey` is overridden; without it the Markdown editor would be
/// unusable. Window level and collection behavior follow the note's `isPinned`
/// flag: pinned notes float above other applications and join every space,
/// while unpinned notes behave like regular windows.
final class StickyPanel: NSPanel, NoteWindowControlling {
    /// Identifier of the note this panel renders, used to route window events
    /// back to the owning model.
    var noteID: UUID?

    /// Whether the note is pinned above other applications. Pinned panels float
    /// and join every space; unpinned panels activate the app when focused so
    /// they behave like regular windows and come to the front when selected.
    private(set) var isPinned = false

    init(frame: NoteFrame, isPinned: Bool = false) {
        super.init(
            contentRect: frame.nsRect,
            styleMask: [.borderless, .resizable],
            backing: .buffered,
            defer: false
        )
        configureStickyBehavior()
        applyPinned(isPinned)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    /// Unpinned panels request app activation so macOS raises them over the
    /// current frontmost app, just like a regular window.
    override func becomeKey() {
        if !isPinned {
            Task { @MainActor in
                NSApp.activate()
            }
        }
        super.becomeKey()
    }

    private func configureStickyBehavior() {
        level = .normal
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
        self.isPinned = isPinned
        isFloatingPanel = isPinned
        level = isPinned ? .floating : .normal
        collectionBehavior = isPinned ? [.canJoinAllSpaces, .fullScreenAuxiliary] : []
        if isPinned {
            orderFrontRegardless()
        }
    }
}
