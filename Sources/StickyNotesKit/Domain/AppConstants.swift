import Foundation

/// Shared configuration for the notes. Centralized here to avoid magic values.
enum AppConstants {
    /// Default geometry for a newly created note.
    static let defaultNoteFrame = NoteFrame(x: 240, y: 240, width: 280, height: 240)

    /// Cascade offset applied per newly created note so they do not overlap exactly.
    static let newNoteOffset: Double = 28

    /// Minimum size a note window can be resized to.
    static let minimumNoteWidth: Double = 180
    static let minimumNoteHeight: Double = 140

    /// Color applied to new notes.
    static let defaultColor: NoteColor = .yellow

    /// Full palette exposed to the user.
    static let palette: [NoteColor] = NoteColor.allCases

    /// Debounce interval for autosaving edits.
    static let autosaveDebounce: TimeInterval = 0.7

    /// Application Support subdirectory that stores the note files.
    static let storageDirectoryName = "StickyNotes"

    /// File extension used for one note per file.
    static let noteFileExtension = "json"

    /// Corner radius shared by the note surface.
    static let cornerRadius: Double = 10

    /// Subsystem identifier used by the app's loggers.
    static let loggerSubsystem = "com.stickynotes.app"
}
