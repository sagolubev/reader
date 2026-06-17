import SwiftUI

struct ReaderView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotionEnabled
    @Environment(\.scenePhase) private var scenePhase

    private let libraryStore: BookLibraryStore?
    private let legacySessionStore: SessionStore?
    private let resetSavedSessionOnLaunch: Bool

    @AppStorage(ReaderThemeMode.storageKey) private var themeModeRawValue = ReaderThemeMode.lightWarm.rawValue

    @State private var session: ReadingSession
    @State private var activeBookID: UUID?
    @State private var books: [LibraryBookSnapshot] = []
    @State private var bookmarks: [BookmarkSnapshot] = []
    @State private var isCurrentPositionBookmarked = false
    @State private var playbackLoopID = 0
    @State private var isFocusMode = false
    @State private var presentedSheet: ReaderSheet?
    @State private var isBookFileImporterPresented = false
    @State private var didCheckLibrary = false
    @State private var persistenceErrorMessage: String?

    init(
        initialText: String = ReaderView.defaultText,
        libraryStore: BookLibraryStore? = nil,
        legacySessionStore: SessionStore? = nil,
        resetSavedSessionOnLaunch: Bool = false
    ) {
        self.libraryStore = libraryStore
        self.legacySessionStore = legacySessionStore
        self.resetSavedSessionOnLaunch = resetSavedSessionOnLaunch

        var session = ReadingSession()
        session.loadText(initialText)
        _session = State(initialValue: session)
    }

    var body: some View {
        ZStack {
            ReaderTheme.background.ignoresSafeArea()

            VStack(spacing: 28) {
                ReaderHeaderView(
                    wordCount: session.words.count,
                    isFocusMode: isFocusMode,
                    canJump: canJump,
                    canBookmark: canBookmark,
                    onOpenLibrary: showLibrary,
                    onAddBook: showBookFileImporter,
                    onOpenBookmarks: showBookmarks,
                    onJump: showJump,
                    onOpenSettings: showSettings,
                    themeMode: themeMode,
                    onToggleTheme: toggleTheme,
                    onExitFocusMode: exitFocusMode
                )

                Spacer(minLength: 24)

                RSVPDisplayView(
                    frame: session.currentFrame,
                    fadeEnabled: ReaderMotionPolicy.isFadeEnabled(
                        settings: session.settings,
                        reduceMotionEnabled: reduceMotionEnabled
                    ),
                    fadeDurationMilliseconds: session.settings.fadeDurationMilliseconds
                )
                    .accessibilityIdentifier("reader.current-word")

                VStack(spacing: 18) {
                    ReaderProgressView(
                        progress: session.progressPercentage / 100,
                        isSeekingEnabled: session.playbackState != .playing
                    ) { fraction in
                        session.seek(toPercentage: fraction * 100)
                        persistActiveBook()
                        refreshBookmarkState()
                    }

                    HStack {
                        Text("\(session.currentWordIndex + 1) / \(session.words.count)")
                        Spacer()
                        Text(session.timeRemaining)
                    }
                    .font(.footnote.monospacedDigit())
                    .foregroundStyle(ReaderTheme.secondaryText)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Reading position")
                    .accessibilityValue("\(session.currentWordIndex + 1) of \(session.words.count) words, \(session.timeRemaining) remaining")
                    .accessibilityIdentifier("reader.progress-summary")

                    PlaybackControlsView(
                        playbackState: session.playbackState,
                        canStep: !session.words.isEmpty,
                        onRestart: restart,
                        onStepBackward: stepBackward,
                        onPlayPause: playPause,
                        onStop: stop,
                        onStepForward: stepForward
                    )

                    ReaderTouchControlsView(
                        canStep: !session.words.isEmpty,
                        wordsPerMinute: session.settings.wordsPerMinute,
                        onStepBackward: stepBackwardByTouch,
                        onSlower: slowDown,
                        onFaster: speedUp,
                        onStepForward: stepForwardByTouch
                    )

                    ReaderBookmarkControlsView(
                        canBookmark: canBookmark,
                        isCurrentPositionBookmarked: isCurrentPositionBookmarked,
                        onToggleBookmark: toggleBookmark
                    )
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 28)

            ReaderKeyboardShortcutsView(
                onPlayPause: playPause,
                onExit: exitFocusMode,
                onSpeedUp: speedUpByKeyboard,
                onSlowDown: slowDownByKeyboard,
                onStepBackward: stepBackwardByKeyboard,
                onStepForward: stepForward,
                onJump: showJumpShortcut,
                onSave: saveShortcut
            )
        }
        .task(id: playbackLoopID) {
            await runPlaybackLoop()
        }
        .onChange(of: scenePhase) { _, newScenePhase in
            handleScenePhaseChange(newScenePhase)
        }
        .sheet(item: $presentedSheet) { sheet in
            switch sheet {
            case .library:
                LibraryView(
                    books: books,
                    activeBookID: activeBookID,
                    onOpenBook: openLibraryBook,
                    onAddBook: importLibraryBookFile,
                    onDeleteBook: deleteLibraryBook
                )
            case .bookmarks:
                BookmarksView(
                    bookmarks: bookmarks,
                    onSelectBookmark: jumpToBookmark,
                    onDeleteBookmark: deleteBookmark
                )
            case .settings:
                SettingsView(settings: settingsBinding)
            case .jump:
                JumpToPositionView(
                    currentWordIndex: session.currentWordIndex,
                    totalWordCount: session.words.count,
                    onJump: jumpToPosition
                )
            }
        }
        .fileImporter(
            isPresented: $isBookFileImporterPresented,
            allowedContentTypes: SupportedBookFileTypes.documentTypes,
            allowsMultipleSelection: false,
            onCompletion: handleBookFileSelection
        )
        .task {
            openLastBookIfNeeded()
        }
        .alert("Library Error", isPresented: persistenceErrorIsPresented) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(persistenceErrorMessage ?? "")
        }
        .preferredColorScheme(themeMode.preferredColorScheme)
    }

    @MainActor
    private func showLibrary() {
        persistActiveBook()
        refreshLibrary()
        presentedSheet = .library
    }

    @MainActor
    private func showBookFileImporter() {
        isBookFileImporterPresented = true
    }

    @MainActor
    private func showSettings() {
        presentedSheet = .settings
    }

    @MainActor
    private func toggleTheme() {
        themeModeRawValue = themeMode.next.rawValue
    }

    @MainActor
    private func showBookmarks() {
        guard canBookmark else {
            return
        }

        refreshBookmarks()
        presentedSheet = .bookmarks
    }

    @MainActor
    private func showJump() {
        guard canJump else {
            return
        }

        presentedSheet = .jump
    }

    @MainActor
    private func openLastBookIfNeeded() {
        guard !didCheckLibrary, let libraryStore else {
            return
        }

        didCheckLibrary = true

        do {
            if resetSavedSessionOnLaunch {
                try libraryStore.clearLibrary()
                try legacySessionStore?.clear()
                refreshLibrary()
                return
            }

            let migratedBook = try migrateLegacySessionIfNeeded()
            refreshLibrary()
            let bookToOpen: LibraryBookSnapshot?
            if let migratedBook {
                bookToOpen = migratedBook
            } else {
                bookToOpen = try libraryStore.lastOpenedBook()
            }

            if let snapshot = bookToOpen {
                restoreLibraryBook(snapshot)
            }
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func loadImportedContent(_ content: ImportedContent) {
        guard let libraryStore else {
            session.loadText(content.text)
            isFocusMode = false
            playbackLoopID += 1
            return
        }

        do {
            persistActiveBook()
            let book = try libraryStore.createBook(
                title: content.title,
                sourceKind: content.sourceKind,
                text: content.text,
                settings: session.settings
            )
            restoreLibraryBook(book)
            refreshLibrary()
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func importLibraryBookFile(_ url: URL) {
        Task {
            await Task.yield()

            let didAccessSecurityScope = url.startAccessingSecurityScopedResource()
            defer {
                if didAccessSecurityScope {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let text = try DocumentImportService().importText(from: url)
                loadImportedContent(ImportedContent(
                    title: url.deletingPathExtension().lastPathComponent,
                    sourceKind: BookSourceKind(url: url),
                    text: text
                ))
                presentedSheet = nil
            } catch {
                persistenceErrorMessage = error.localizedDescription
            }
        }
    }

    private func handleBookFileSelection(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let url = urls.first else {
            return
        }

        Task { @MainActor in
            importLibraryBookFile(url)
        }
    }

    @MainActor
    private func openLibraryBook(_ book: LibraryBookSnapshot) {
        guard let libraryStore else {
            restoreLibraryBook(book)
            return
        }

        do {
            persistActiveBook()
            if let opened = try libraryStore.openBook(id: book.id) {
                restoreLibraryBook(opened)
                refreshLibrary()
            }
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func deleteLibraryBook(_ book: LibraryBookSnapshot) {
        guard let libraryStore else {
            return
        }

        do {
            try libraryStore.deleteBook(id: book.id)
            refreshLibrary()

            if activeBookID == book.id {
                if let replacement = try libraryStore.lastOpenedBook() {
                    restoreLibraryBook(replacement)
                } else {
                    activeBookID = nil
                    session.loadText(Self.defaultText)
                    bookmarks = []
                    isCurrentPositionBookmarked = false
                    isFocusMode = false
                    playbackLoopID += 1
                }
            }
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func restoreLibraryBook(_ book: LibraryBookSnapshot) {
        activeBookID = book.id
        session.restore(from: book)
        isFocusMode = false
        refreshBookmarks()
        refreshBookmarkState()
        playbackLoopID += 1
    }

    @MainActor
    private func migrateLegacySessionIfNeeded() throws -> LibraryBookSnapshot? {
        guard
            let libraryStore,
            let legacySessionStore,
            let legacySnapshot = try legacySessionStore.load()
        else {
            return nil
        }

        guard let migratedBook = try libraryStore.migrateLegacySession(legacySnapshot) else {
            return nil
        }

        try legacySessionStore.clear()
        return migratedBook
    }

    @MainActor
    private func toggleBookmark() {
        guard let libraryStore, let activeBookID else {
            return
        }

        do {
            _ = try libraryStore.toggleBookmark(
                bookID: activeBookID,
                wordIndex: session.currentWordIndex,
                words: session.words
            )
            refreshBookmarks()
            refreshBookmarkState()
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func jumpToBookmark(_ bookmark: BookmarkSnapshot) {
        session.currentWordIndex = min(session.words.count - 1, max(0, bookmark.wordIndex))
        session.playbackState = .stopped
        isFocusMode = false
        persistActiveBook()
        refreshBookmarkState()
        playbackLoopID += 1
    }

    @MainActor
    private func deleteBookmark(_ bookmark: BookmarkSnapshot) {
        guard let libraryStore, bookmark.bookID == activeBookID else {
            return
        }

        do {
            try libraryStore.deleteBookmark(
                bookID: bookmark.bookID,
                wordIndex: bookmark.wordIndex
            )
            refreshBookmarks()
            refreshBookmarkState()
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func playPause() {
        switch session.playbackState {
        case .playing:
            session.pause()
            persistActiveBook()
        case .paused:
            session.resume()
            isFocusMode = true
        case .stopped:
            session.play()
            isFocusMode = true
        }

        playbackLoopID += 1
    }

    @MainActor
    private func restart() {
        session.restart()
        isFocusMode = true
        persistActiveBook()
        refreshBookmarkState()
        playbackLoopID += 1
    }

    @MainActor
    private func stop() {
        session.stop()
        isFocusMode = false
        persistActiveBook()
        refreshBookmarkState()
        playbackLoopID += 1
    }

    @MainActor
    private func exitFocusMode() {
        if session.playbackState == .playing {
            session.pause()
            playbackLoopID += 1
        }

        isFocusMode = false
        persistActiveBook()
    }

    @MainActor
    private func handleScenePhaseChange(_ newScenePhase: ScenePhase) {
        let lifecyclePhase = ReaderLifecyclePhase(scenePhase: newScenePhase)
        if session.pauseForLifecycleTransition(to: lifecyclePhase) {
            playbackLoopID += 1
        }

        if lifecyclePhase.shouldPausePlayback {
            persistActiveBook()
        }
    }

    @MainActor
    private func stepBackward() {
        session.stepBackward()
        persistActiveBook()
        refreshBookmarkState()
    }

    @MainActor
    private func stepForward() {
        session.stepForward()
        persistActiveBook()
        refreshBookmarkState()
    }

    @MainActor
    private func stepBackwardByTouch() {
        session.stepBackward(by: Self.touchWordStep)
        persistActiveBook()
        refreshBookmarkState()
    }

    @MainActor
    private func stepForwardByTouch() {
        session.stepForward(by: Self.touchWordStep)
        persistActiveBook()
        refreshBookmarkState()
    }

    @MainActor
    private func slowDown() {
        session.adjustWordsPerMinute(by: -Self.touchWordsPerMinuteStep)
        persistActiveBook()
    }

    @MainActor
    private func speedUp() {
        session.adjustWordsPerMinute(by: Self.touchWordsPerMinuteStep)
        persistActiveBook()
    }

    @MainActor
    private func stepBackwardByKeyboard() {
        session.stepBackward(by: Self.keyboardBackwardWordStep)
        persistActiveBook()
        refreshBookmarkState()
    }

    @MainActor
    private func slowDownByKeyboard() {
        session.adjustWordsPerMinute(by: -ReaderSettings.wordsPerMinuteStep)
        persistActiveBook()
    }

    @MainActor
    private func speedUpByKeyboard() {
        session.adjustWordsPerMinute(by: ReaderSettings.wordsPerMinuteStep)
        persistActiveBook()
    }

    @MainActor
    private func showJumpShortcut() {
        showJump()
    }

    @MainActor
    private func saveShortcut() {
        persistActiveBook()
    }

    @MainActor
    private func jumpToPosition(_ target: String) {
        session.jump(to: target)
        persistActiveBook()
        refreshBookmarkState()
    }

    @MainActor
    private func runPlaybackLoop() async {
        guard session.playbackState == .playing else {
            return
        }

        while session.playbackState == .playing, !Task.isCancelled {
            let delay = playbackDelayMilliseconds()

            do {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000))
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            session.advanceOneWord()
            refreshBookmarkState()
        }
    }

    @MainActor
    private func persistActiveBook() {
        guard let libraryStore, let activeBookID else {
            return
        }

        do {
            try libraryStore.updateBook(id: activeBookID, from: session)
            refreshLibrary()
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func refreshLibrary() {
        guard let libraryStore else {
            return
        }

        do {
            books = try libraryStore.listBooks()
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func refreshBookmarks() {
        guard let libraryStore, let activeBookID else {
            bookmarks = []
            return
        }

        do {
            bookmarks = try libraryStore.bookmarks(for: activeBookID)
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func refreshBookmarkState() {
        guard let libraryStore, let activeBookID else {
            isCurrentPositionBookmarked = false
            return
        }

        do {
            isCurrentPositionBookmarked = try libraryStore.isBookmarked(
                bookID: activeBookID,
                wordIndex: session.currentWordIndex
            )
        } catch {
            persistenceErrorMessage = error.localizedDescription
        }
    }

    private func playbackDelayMilliseconds() -> Double {
        var delay = WordTiming.delayMilliseconds(
            for: session.currentWord,
            settings: session.settings
        )

        if WordTiming.shouldPause(
            atWordIndex: session.currentWordIndex,
            pauseAfterWords: session.settings.pauseAfterWords
        ) {
            delay += Double(session.settings.pauseDurationMilliseconds)
        }

        return max(1, delay)
    }

    private var settingsBinding: Binding<ReaderSettings> {
        Binding(
            get: { session.settings },
            set: { newSettings in
                var normalizedSettings = newSettings
                normalizedSettings.normalizeForControls()
                session.settings = normalizedSettings
                persistActiveBook()
            }
        )
    }

    private var canJump: Bool {
        !session.words.isEmpty && session.playbackState != .playing
    }

    private var canBookmark: Bool {
        activeBookID != nil && !session.words.isEmpty
    }

    private var themeMode: ReaderThemeMode {
        ReaderThemeMode(rawValue: themeModeRawValue) ?? .lightWarm
    }

    private var persistenceErrorIsPresented: Binding<Bool> {
        Binding(
            get: { persistenceErrorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    persistenceErrorMessage = nil
                }
            }
        )
    }
}

private enum ReaderSheet: Identifiable {
    case library
    case bookmarks
    case settings
    case jump

    var id: String {
        switch self {
        case .library:
            return "library"
        case .bookmarks:
            return "bookmarks"
        case .settings:
            return "settings"
        case .jump:
            return "jump"
        }
    }
}

private extension ReaderView {
    static let touchWordStep = 5
    static let touchWordsPerMinuteStep = 50
    static let keyboardBackwardWordStep = 2

    static let defaultText = """
    Быстрое последовательное визуальное предъявление (англ. Rapid serial visual presentation, RSVP) — способ показа текстовой информации на дисплее, при котором все слова показываются быстро одно за другим в фиксированной области экрана (обычно в центре). При этом большой объём текста может быть показан на дисплее очень маленького размера, например, на экране миниатюрного мобильного телефона или даже в электронных наручных часах. Кроме того, данный метод позволяет воспринимать текст очень быстро за счёт отсутствия необходимости движения глаз, что нашло своё применение в скорочтении, в устройствах для людей с нарушениями зрения и глазодвигательной активности, и даже при лечении дислексии.

    Учёные из Университета Карнеги — Меллон установили, что быстрое последовательное визуальное предъявление позволяет достичь пиковой скорости чтения на английском языке в 720 слов в минуту (12 в секунду). Или, что также очень важно, позволяет повысить скорость чтения на 33 % по сравнению с нормальной без существенной потери понимания материала.
    """
}

private extension ReaderLifecyclePhase {
    init(scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            self = .active
        case .inactive:
            self = .inactive
        case .background:
            self = .background
        @unknown default:
            self = .inactive
        }
    }
}

#Preview("Default") {
    ReaderView()
}

#Preview("Small Phone", traits: .fixedLayout(width: 375, height: 667)) {
    ReaderView(initialText: "Short words keep the focal point stable on compact screens.")
}

#Preview("Large Phone", traits: .fixedLayout(width: 430, height: 932)) {
    ReaderView(initialText: """
    Longer sample text keeps the reader surface populated while checking spacing, centered ORP alignment, progress, and controls on a large phone.
    """)
}
