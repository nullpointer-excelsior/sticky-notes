import AppKit
import SwiftUI

/// Owns the AppKit side of the app: it projects each `Note` model into an
/// `NSPanel` hosting a `NoteView`, restores persisted panels on launch and
/// tears them down on deletion. It contains no business logic; all mutations are
/// delegated to the `NotesStore`.
@MainActor
final class WindowCoordinator: NSObject {
    private let store: NotesStore
    private var panels: [UUID: StickyPanel] = [:]
    private var viewModels: [UUID: NoteViewModel] = [:]

    init(store: NotesStore) {
        self.store = store
        super.init()
        store.onNoteAdded = { [weak self] note in self?.present(note) }
        store.onNoteRemoved = { [weak self] id in self?.dismiss(id) }
    }

    /// Recreates a panel for every persisted note, ordered so the stacking
    /// matches the stored `zIndex`.
    func restoreAll() {
        for note in store.notes {
            present(note)
        }
    }

    /// Flushes any pending editor draft and persists the current geometry of
    /// every open panel. Called on termination.
    func persistAll() {
        flushAllEdits()
        for (id, panel) in panels {
            persistFrame(of: panel, for: id)
        }
    }

    private func present(_ note: Note) {
        if let existing = panels[note.id] {
            existing.setFrame(note.frame.nsRect, display: true)
            existing.orderFrontRegardless()
            return
        }

        let viewModel = NoteViewModel(note: note, store: store)
        let panel = StickyPanel(frame: note.frame)
        panel.noteID = note.id
        panel.delegate = self
        panel.contentViewController = NSHostingController(rootView: NoteView(viewModel: viewModel))
        panel.setFrame(note.frame.nsRect, display: true)
        panel.orderFrontRegardless()

        viewModel.windowController = panel
        panels[note.id] = panel
        viewModels[note.id] = viewModel
    }

    private func dismiss(_ id: UUID) {
        guard let panel = panels[id] else { return }
        panel.delegate = nil
        panel.noteID = nil
        panel.close()
        panels[id] = nil
        viewModels[id] = nil
    }

    private func persistFrame(of panel: StickyPanel, for id: UUID) {
        let frame = NoteFrame(panel.frame)
        store.update(id: id) { $0.frame = frame }
    }

    private func flushAllEdits() {
        for viewModel in viewModels.values {
            viewModel.endEditing()
        }
    }

    private func flushEdits(for id: UUID) {
        viewModels[id]?.endEditing()
    }
}

extension WindowCoordinator: NSWindowDelegate {
    func windowDidMove(_ notification: Notification) {
        persist(from: notification)
    }

    func windowDidResize(_ notification: Notification) {
        persist(from: notification)
    }

    func windowDidBecomeKey(_ notification: Notification) {
        guard let panel = notification.object as? StickyPanel, let id = panel.noteID else { return }
        store.bringToFront(id: id)
    }

    func windowWillClose(_ notification: Notification) {
        guard let panel = notification.object as? StickyPanel, let id = panel.noteID else { return }
        flushEdits(for: id)
        persistFrame(of: panel, for: id)
    }

    private func persist(from notification: Notification) {
        guard let panel = notification.object as? StickyPanel, let id = panel.noteID else { return }
        persistFrame(of: panel, for: id)
    }
}
