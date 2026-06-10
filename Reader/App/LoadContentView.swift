import SwiftUI
import UniformTypeIdentifiers

struct LoadContentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var state = LoadContentState()

    let importService: DocumentImportService
    let onLoadText: (String) -> Void

    init(
        importService: DocumentImportService = DocumentImportService(),
        onLoadText: @escaping (String) -> Void
    ) {
        self.importService = importService
        self.onLoadText = onLoadText
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 18) {
                    TextEditor(text: $state.pastedText)
                        .font(.body.monospaced())
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.16), lineWidth: 1)
                        }
                        .frame(minHeight: 220)
                        .accessibilityLabel("Text to load")
                        .accessibilityIdentifier("load-content.text-editor")

                    VStack(spacing: 12) {
                        Button(action: loadPastedText) {
                            Label("Load Text", systemImage: "text.badge.checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!state.canLoadPastedText)
                        .accessibilityIdentifier("load-content.load-text")

                        Button(action: showFileImporter) {
                            Label("Import PDF/EPUB", systemImage: "doc.badge.plus")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(state.isImportingFile)
                        .accessibilityIdentifier("load-content.import-file")
                    }
                    .controlSize(.large)

                    if state.isImportingFile {
                        ProgressView("Importing...")
                            .foregroundStyle(.secondary)
                            .accessibilityIdentifier("load-content.import-progress")
                    }

                    if let errorMessage = state.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .accessibilityIdentifier("load-content.error")
                    }

                    Spacer(minLength: 0)
                }
                .padding(24)
            }
            .navigationTitle("Load Content")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .accessibilityIdentifier("load-content.sheet")
        .fileImporter(
            isPresented: $state.isFileImporterPresented,
            allowedContentTypes: [.pdf, .epubDocument],
            allowsMultipleSelection: false,
            onCompletion: handleFileSelection
        )
    }

    private func loadPastedText() {
        guard let text = state.takePastedText() else {
            return
        }

        onLoadText(text)
        dismiss()
    }

    private func showFileImporter() {
        guard !state.isImportingFile else {
            return
        }

        state.isFileImporterPresented = true
    }

    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                state.failFileSelection(DocumentImportError.unsupportedFileType("unknown"))
                return
            }

            importDocument(at: url)
        case .failure(let error):
            state.failFileSelection(error)
        }
    }

    private func importDocument(at url: URL) {
        guard state.beginFileImport() else {
            return
        }

        Task {
            await Task.yield()

            let didAccessSecurityScope = url.startAccessingSecurityScopedResource()
            defer {
                if didAccessSecurityScope {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let result: Result<String, Error>
            do {
                result = .success(try importService.importText(from: url))
            } catch {
                result = .failure(error)
            }

            guard let text = state.finishFileImport(result) else {
                return
            }

            onLoadText(text)
            dismiss()
        }
    }
}

private extension UTType {
    static var epubDocument: UTType {
        UTType(filenameExtension: "epub") ?? UTType(importedAs: "org.idpf.epub-container")
    }
}

#Preview {
    LoadContentView { _ in }
}
