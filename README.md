# Sticky Notes

A native macOS desktop app that turns every note into an always-on-top floating panel (`NSPanel`), editable in Markdown, customizable by color, and persisted locally.

- Content in **SwiftUI**; window lifecycle in **AppKit**.
- Global state with **`@Observable`** (MVVM).
- Minimal hexagonal persistence: one JSON file per note.
- Tests with **Swift Testing**.

## Requirements

- macOS 14 (Sonoma) or later.
- Swift 6 (bundled with the Command Line Tools or Xcode).

Check the installed version:

```bash
swift --version
```

> Note: in a Command Line Tools-only environment, SwiftPM does not auto-detect the toolchain's bundled `Testing.framework`. For that reason the project declares `swiftlang/swift-testing` (6.2.4) as a **test-only** dependency. The first test build requires network access to fetch it. The app itself has no third-party runtime dependencies.

## Build

```bash
swift build
```

Release build:

```bash
swift build -c release
```

## Run

```bash
swift run StickyNotes
```

On launch, the app restores saved notes. If none exist, it creates one empty note so the "+" button on the bar is available. A note can also be created with `Cmd + N`.

## Test

```bash
swift test
```

Runs the Swift Testing suites covering note creation (TEST-1), Markdown rendering on blur (TEST-2), restore across sessions (TEST-3), color persistence (TEST-4), frame persistence (TEST-5), deleting the last note (TEST-6), empty content (TEST-7), corrupted-file isolation, and store behavior (z-order, resize, autosave).

## Package

Build a `.app` bundle and a distributable `.dmg`:

```bash
make dmg
```

`SwiftPM` only produces a bare executable, so the pipeline assembles the bundle itself: `swift build -c release`, then `dist/StickyNotes.app` (`Contents/MacOS`, `Info.plist`, icon, and the resource bundle), then an ad-hoc code signature, and finally `dist/StickyNotes.dmg` with `create-dmg`. All output goes to `dist/`.

Available targets:

| Target | Description |
|--------|-------------|
| `make` / `make dmg` | Full pipeline: build, bundle, sign, DMG (default). |
| `make build` | Release build only. |
| `make app` | Assemble `dist/StickyNotes.app`. |
| `make sign` | Sign the bundle. |
| `make verify` | Validate the DMG with `hdiutil verify`. |
| `make open` | Build the DMG and open it. |
| `make clean` | Remove `dist/`. |

`create-dmg` is required for the DMG step (`brew install create-dmg`).

Signing is ad-hoc by default, which is enough to run locally but not to distribute. To sign with a Developer ID:

```bash
make dmg SIGN_IDENTITY="Developer ID Application: Your Name (TEAMID)"
```

> Notes: the bundle is built for the host architecture only; universal builds (`swift build --arch arm64 --arch x86_64`) require Xcode's `xcbuild`, which the Command Line Tools toolchain does not ship. Ad-hoc signed apps are not notarized, so on another Mac Gatekeeper still requires right-click → Open (or `xattr -dr com.apple.quarantine /Applications/StickyNotes.app`).

## Usage

- **Create note**: `+` button on a note's bar (or `Cmd + N`).
- **Edit**: click the content and type Markdown.
- **Render**: when the note loses focus, Markdown is converted to formatted text (`AttributedString(markdown:)`).
- **Color**: `…` menu on the bar; the selected color is persisted.
- **Move**: drag the note's background.
- **Resize**: drag the grip at the bottom-right corner.
- **Delete**: trash icon on the bar.
- **Always visible**: panels float above everything else and appear across all spaces and full-screen apps.

## Persistence

- Each note is stored as a JSON file (`<UUID>.json`) in:

```
~/Library/Application Support/StickyNotes/
```

- Debounced autosave at 0.7 s, plus forced saves on move, close, and app termination.
- Text, color, frame, and order (z-index) are restored on every launch.
- A corrupted or unreadable file is skipped in isolation without preventing the rest from loading.

## Project structure

```
Makefile                               # Release packaging: .app bundle + .dmg
Package.swift                          # SPM: targets, platform, test dependency
Sources/
  StickyNotes/                         # Executable target
    StickyNotesApp.swift               # @main + AppDelegate
  StickyNotesKit/                      # Library (logic and UI)
    AppController.swift                # Public facade: store + coordinator
    Domain/                            # Note, NoteColor, NoteFrame, AppConstants
    Persistence/                       # NoteRepository (protocol) + JSONFileRepository
    Presentation/                      # NotesStore, NoteViewModel, NoteView, MarkdownRenderer
    Windows/                           # StickyPanel, WindowCoordinator, AppKit bridges
Tests/
  StickyNotesKitTests/                 # Swift Testing suites
```

## Architecture

Single data flow `View → ViewModel → Store → Repository`:

- **Domain**: `Note` (id, text, color, frame, zIndex, createdAt, updatedAt). Window state is part of the persisted model.
- **Persistence**: `NoteRepository` (port) and `JSONFileRepository` (adapter, one file per note).
- **Presentation**: `NotesStore` (global state) and `NoteViewModel` (per-note state).
- **Windows**: `WindowCoordinator` creates/restores/destroys one `StickyPanel` per note via `NSHostingController`; it contains no business logic.
