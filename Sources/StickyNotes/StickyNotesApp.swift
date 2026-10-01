import AppKit
import StickyNotesKit
import SwiftUI

@main
struct StickyNotesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Note") {
                    appDelegate.createNote()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}

/// Bridges the SwiftUI application lifecycle to the kit's `AppController`.
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let controller = AppController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        controller.start()
    }

    func createNote() {
        controller.createNote()
    }

    func applicationWillTerminate(_ notification: Notification) {
        controller.persistAll()
    }
}
