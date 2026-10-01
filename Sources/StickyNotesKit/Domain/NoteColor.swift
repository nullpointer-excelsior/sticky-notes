import Foundation

/// Background palette available for a note. The raw value is the stable
/// identifier that gets persisted, so cases must not be renamed.
enum NoteColor: String, Codable, CaseIterable, Sendable, Hashable {
    case yellow
    case green
    case blue
    case pink
    case purple
    case orange
    case gray

    /// Returns a color picked uniformly at random from the full palette.
    static func random() -> NoteColor {
        allCases.randomElement() ?? .yellow
    }

    var displayName: String {
        switch self {
        case .yellow: "Yellow"
        case .green: "Green"
        case .blue: "Blue"
        case .pink: "Pink"
        case .purple: "Purple"
        case .orange: "Orange"
        case .gray: "Gray"
        }
    }

    var red: Double {
        switch self {
        case .yellow: 0.99
        case .green: 0.74
        case .blue: 0.65
        case .pink: 0.99
        case .purple: 0.83
        case .orange: 1.00
        case .gray: 0.88
        }
    }

    var greenComponent: Double {
        switch self {
        case .yellow: 0.92
        case .green: 0.93
        case .blue: 0.85
        case .pink: 0.73
        case .purple: 0.74
        case .orange: 0.82
        case .gray: 0.88
        }
    }

    var blueComponent: Double {
        switch self {
        case .yellow: 0.60
        case .green: 0.64
        case .blue: 0.98
        case .pink: 0.80
        case .purple: 0.97
        case .orange: 0.56
        case .gray: 0.89
        }
    }
}
