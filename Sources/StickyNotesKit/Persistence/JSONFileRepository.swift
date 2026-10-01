import Foundation

/// File-system adapter that persists exactly one JSON file per note, keyed by
/// the note identifier. A corrupt or undecodable file is skipped in isolation
/// so the rest of the store keeps loading.
final class JSONFileRepository: NoteRepository {
    private let directory: URL
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(directory: URL, fileManager: FileManager = .default) {
        self.directory = directory
        self.fileManager = fileManager

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    /// Default storage location inside the user's Application Support folder.
    static func defaultDirectory() -> URL {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent(AppConstants.storageDirectoryName, isDirectory: true)
    }

    func loadAll() throws -> [Note] {
        try ensureDirectoryExists()
        let files = try fileManager
            .contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == AppConstants.noteFileExtension }

        var notes: [Note] = []
        for file in files {
            do {
                let data = try Data(contentsOf: file)
                notes.append(try decoder.decode(Note.self, from: data))
            } catch {
                // Isolate the failure: skip the offending file and keep loading.
                continue
            }
        }
        return notes.sorted { $0.zIndex < $1.zIndex }
    }

    func save(_ note: Note) throws {
        try ensureDirectoryExists()
        let data = try encoder.encode(note)
        try data.write(to: fileURL(for: note.id), options: .atomic)
    }

    func delete(id: UUID) throws {
        let url = fileURL(for: id)
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }

    private func fileURL(for id: UUID) -> URL {
        directory
            .appendingPathComponent(id.uuidString)
            .appendingPathExtension(AppConstants.noteFileExtension)
    }

    private func ensureDirectoryExists() throws {
        guard !fileManager.fileExists(atPath: directory.path) else { return }
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    }
}
