import SwiftUI

/// Visual representation of a single note: a top bar with the collection and
/// style controls, plus the content area that toggles between Markdown editing
/// and rendered output.
struct NoteView: View {
    @Bindable var viewModel: NoteViewModel
    @FocusState private var isFocused: Bool
    @State private var resizeStartSize: CGSize?

    var body: some View {
        VStack(spacing: 0) {
            bar
            Divider().overlay(Color.black.opacity(0.08))
            content
        }
        .background(viewModel.note.color.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.cornerRadius, style: .continuous)
                .strokeBorder(Color.black.opacity(0.12), lineWidth: 1)
        )
        .overlay(alignment: .bottomTrailing) { resizeGrip }
        .onChange(of: isFocused) { _, focused in
            if !focused { viewModel.endEditing() }
        }
        .onChange(of: viewModel.isEditing) { _, editing in
            if editing { isFocused = true }
        }
    }

    private var bar: some View {
        HStack(spacing: 10) {
            Button(action: viewModel.createNote) {
                Image(systemName: "plus")
            }
            .buttonStyle(.plain)
            .help("New note")

            Spacer(minLength: 0)

            Button(action: viewModel.togglePinned) {
                Image(systemName: viewModel.note.isPinned ? "pin.fill" : "pin")
            }
            .buttonStyle(.plain)
            .help(viewModel.note.isPinned ? "Unpin note" : "Pin note")

            Menu {
                ForEach(AppConstants.palette, id: \.self) { color in
                    Button {
                        viewModel.setColor(color)
                    } label: {
                        Label(color.displayName, systemImage: viewModel.note.color == color ? "checkmark.circle.fill" : "circle.fill")
                    }
                }
            } label: {
                Image(systemName: "paintpalette")
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            .fixedSize()
            .help("Color")

            Button(role: .destructive, action: viewModel.deleteSelf) {
                Image(systemName: "trash")
            }
            .buttonStyle(.plain)
            .help("Delete note")
        }
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(Color.black.opacity(0.65))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.06))
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isEditing {
            TextEditor(text: $viewModel.draftText)
                .font(.system(size: viewModel.note.fontSize))
                .foregroundStyle(Color(white: 0.35))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .focused($isFocused)
                .padding(8)
                .onChange(of: viewModel.draftText) { _, _ in
                    viewModel.scheduleAutosave()
                }
        } else {
            ScrollView {
                Group {
                    if viewModel.renderedText.characters.isEmpty {
                        Text("Empty note. Click to edit.")
                            .italic()
                            .foregroundStyle(Color.black.opacity(0.35))
                    } else {
                        Text(viewModel.renderedText)
                            .textSelection(.enabled)
                    }
                }
                .font(.system(size: viewModel.note.fontSize))
                .foregroundStyle(Color.black.opacity(0.9))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
            }
            .contentShape(Rectangle())
            .onTapGesture { viewModel.beginEditing() }
        }
    }

    /// Bottom-right grip that resizes the hosting panel. Background dragging
    /// moves the panel (via `isMovableByWindowBackground`); this gesture covers
    /// edge resizing, which borderless panels do not provide natively.
    private var resizeGrip: some View {
        Image(systemName: "arrow.down.right")
            .font(.system(size: 9, weight: .bold))
            .foregroundStyle(Color.black.opacity(0.3))
            .frame(width: 18, height: 18)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard let controller = viewModel.windowController else { return }
                        let start = resizeStartSize ?? controller.contentSize
                        if resizeStartSize == nil { resizeStartSize = start }
                        controller.resizeContent(
                            to: CGSize(
                                width: start.width + value.translation.width,
                                height: start.height + value.translation.height
                            )
                        )
                    }
                    .onEnded { _ in resizeStartSize = nil }
            )
            .help("Resize note")
    }
}
