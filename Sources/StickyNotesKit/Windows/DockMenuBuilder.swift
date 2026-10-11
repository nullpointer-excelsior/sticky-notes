import AppKit

/// Builds the Dock context menu from the current notes. A fresh menu is built on
/// every open, so nothing is cached or mutated after construction.
///
/// `autoenablesItems` is disabled so the explicit enabled/disabled state of each
/// item is preserved by AppKit instead of being re-derived from a target lookup.
@MainActor
struct DockMenuBuilder {
    func buildMenu(notes: [Note], target: AnyObject, focusSelector: Selector, newNoteSelector: Selector) -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        if notes.isEmpty {
            menu.addItem(makeDisabledEmptyStateItem())
        } else {
            for (index, note) in notes.enumerated() {
                menu.addItem(makeNoteItem(note: note, position: index + 1, target: target, focusSelector: focusSelector))
            }
        }

        menu.addItem(.separator())
        menu.addItem(makeNewNoteItem(target: target, newNoteSelector: newNoteSelector))

        return menu
    }

    private func makeNoteItem(note: Note, position: Int, target: AnyObject, focusSelector: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: note.dockTitle(position: position), action: focusSelector, keyEquivalent: "")
        item.target = target
        item.representedObject = note.id
        item.isEnabled = true
        return item
    }

    private func makeDisabledEmptyStateItem() -> NSMenuItem {
        let item = NSMenuItem(title: AppConstants.dockMenuEmptyStateTitle, action: nil, keyEquivalent: "")
        item.isEnabled = false
        return item
    }

    private func makeNewNoteItem(target: AnyObject, newNoteSelector: Selector) -> NSMenuItem {
        let item = NSMenuItem(title: AppConstants.dockMenuNewNoteTitle, action: newNoteSelector, keyEquivalent: "")
        item.target = target
        item.isEnabled = true
        return item
    }
}
