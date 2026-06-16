# iOS RSVP Reader Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking.

**Status:** Completed on 2026-06-10. The active OpenSpec checklist for
`ios-rsvp-reader` reached 39/39 tasks complete, the change validated under
`openspec validate ios-rsvp-reader --strict`, and the final acceptance notes live
in `docs/ios-rsvp-reader-acceptance.md`.

**Goal:** Build a native iOS SwiftUI RSVP reader that matches the behavior of `thomaskolmans/rsvp-reading`: PDF/EPUB/text loading, one-word centered reading, ORP highlight, speed controls, pauses, progress, jump, focus mode, and saved session restore.

**Architecture:** Port the web app's core reading logic into pure Swift domain types first, then wrap it with SwiftUI screens and iOS-native file import/storage. Keep parsing, timing, persistence, and UI state separate so RSVP behavior is unit-testable without launching the app.

**Tech Stack:** SwiftUI, Observation (`@Observable`) on iOS 17+, SwiftData for saved documents/sessions, PDFKit for PDF text extraction, Swift Package Manager dependency for EPUB parsing, XCTest, XCUITest.

---

## Source Behavior Baseline

The source web project is a Svelte/Vite app with these user-facing behaviors to reproduce:

- Load content from pasted text, PDF, or EPUB.
- Split text into words and show the current word at a fixed focal point.
- Highlight the Optimal Recognition Point (ORP) letter in red.
- Support Unicode letters and RTL scripts.
- Read at 50-1000 WPM, stepping by 25 WPM.
- Add optional punctuation pauses for `.`, `!`, `?`, `;`, `:`, and comma pauses.
- Add optional longer delays for long words.
- Add optional periodic pauses every N words.
- Support one-word and multi-word frame display.
- Show progress, word count, WPM, and estimated remaining time.
- Allow jump by word number or percentage.
- Save and resume the current text, position, and settings.
- Provide focus mode while reading.
- Support keyboard shortcuts where hardware keyboard is available.

## Product Decisions

- Build native SwiftUI, not a WebView wrapper. A WebView copy would be faster initially but worse for files, persistence, accessibility, background interruptions, Dynamic Type, and App Store-grade polish.
- Minimum target: iOS 17.0. This allows Observation and SwiftData. If iOS 16 support becomes mandatory, replace SwiftData with a small JSON store and `@Observable` with `ObservableObject`.
- Store imported text locally after extraction; do not retain external security-scoped file URLs as the primary reading source.
- Treat EPUB parsing as a replaceable adapter. Start with a small Swift package dependency if it cleanly extracts spine text; otherwise implement a minimal EPUB pipeline with ZIP + OPF/spine + XHTML text extraction.
- Keep UI visually close to the source: black background, muted controls, red ORP/focus marker, minimal focus mode.

## Planned File Structure

- `Reader/ReaderApp.swift`: app entry point, SwiftData container, root scene.
- `Reader/App/RootView.swift`: top-level SwiftUI shell.
- `Reader/App/AppRoute.swift`: modal and navigation state.
- `Reader/Domain/ReaderSettings.swift`: WPM, fade, pause, frame-count settings.
- `Reader/Domain/ReadingSession.swift`: current text, words, index, progress, derived stats.
- `Reader/Domain/RSVPTextProcessor.swift`: text splitting, ORP, Unicode letter handling, word frames.
- `Reader/Domain/WordTiming.swift`: delay calculation for WPM, punctuation, long words, periodic pauses.
- `Reader/Domain/TimeFormatting.swift`: remaining-time formatting.
- `Reader/Persistence/SavedReadingSession.swift`: SwiftData model for saved session.
- `Reader/Persistence/SessionStore.swift`: save/load/clear session operations.
- `Reader/Import/DocumentImportService.swift`: high-level text/PDF/EPUB import API.
- `Reader/Import/PDFTextExtractor.swift`: PDFKit-backed text extraction.
- `Reader/Import/EPUBTextExtractor.swift`: EPUB-backed text extraction.
- `Reader/Features/Reader/ReaderView.swift`: main reader screen.
- `Reader/Features/Reader/RSVPDisplayView.swift`: centered ORP word display.
- `Reader/Features/Reader/ProgressBarView.swift`: progress display and seek gestures.
- `Reader/Features/Reader/PlaybackControlsView.swift`: play/pause/resume/stop/restart controls.
- `Reader/Features/Reader/SettingsView.swift`: WPM, pauses, fade, frame settings.
- `Reader/Features/Reader/LoadContentView.swift`: paste text and file import entry.
- `Reader/Features/Reader/JumpToPositionView.swift`: word/percentage jump UI.
- `Reader/Features/Reader/ResumeSessionView.swift`: saved session prompt.
- `Reader/Features/Reader/KeyboardShortcutHandler.swift`: hardware keyboard commands.
- `ReaderTests/RSVPTextProcessorTests.swift`: text/ORP/frame tests.
- `ReaderTests/WordTimingTests.swift`: delay and pause tests.
- `ReaderTests/SessionStoreTests.swift`: save/load/clear tests.
- `ReaderTests/DocumentImportServiceTests.swift`: parser dispatch and error tests.
- `ReaderUITests/ReaderFlowUITests.swift`: smoke tests for load, play, pause, jump, save/resume.

## Task 1: Scaffold Native iOS App

**Files:**
- Create: `Reader.xcodeproj`
- Create: `Reader/ReaderApp.swift`
- Create: `Reader/App/RootView.swift`
- Create: `ReaderTests/ReaderTests.swift`
- Create: `ReaderUITests/ReaderUITests.swift`

- [x] Create a SwiftUI iOS app named `Reader` with bundle id placeholder `com.sigius.reader`.
- [x] Set deployment target to iOS 17.0.
- [x] Add unit test and UI test targets.
- [x] Add package dependency for EPUB parsing only after evaluating the API in Task 6.
- [x] Build once:

```bash
xcodebuild -scheme Reader -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: build succeeds with the default app.

## Task 2: Port Core Text And ORP Logic

**Files:**
- Create: `Reader/Domain/RSVPTextProcessor.swift`
- Create: `ReaderTests/RSVPTextProcessorTests.swift`

- [x] Write tests for whitespace splitting, empty input, punctuation, Unicode, Cyrillic, CJK, Arabic/Hebrew, and leading punctuation.
- [x] Implement `parseText(_:) -> [String]`.
- [x] Implement `orpLetterOffset(in:) -> String.Index?` using Unicode letter checks.
- [x] Implement `splitForDisplay(_:) -> WordDisplayParts`.
- [x] Implement `wordFrame(words:centerIndex:frameSize:) -> WordFrame`.
- [x] Run:

```bash
xcodebuild test -scheme Reader -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:ReaderTests/RSVPTextProcessorTests
```

Expected: all text processor tests pass.

Acceptance criteria:

- `"  Hello   world\nagain "` becomes `["Hello", "world", "again"]`.
- `"привет"` highlights the third displayed letter under the source algorithm.
- `"«привет»"` skips the opening quote before calculating the displayed ORP offset.
- RTL words do not crash the display model.

## Task 3: Port Timing, Pause, And Remaining-Time Logic

**Files:**
- Create: `Reader/Domain/ReaderSettings.swift`
- Create: `Reader/Domain/WordTiming.swift`
- Create: `Reader/Domain/TimeFormatting.swift`
- Create: `ReaderTests/WordTimingTests.swift`

- [x] Write tests for 300 WPM, 600 WPM, sentence punctuation, comma, disabled punctuation pause, invalid WPM fallback, long-word multiplier, periodic pause, and remaining-time formatting.
- [x] Implement settings defaults:

```swift
wordsPerMinute = 300
fadeEnabled = true
fadeDurationMilliseconds = 150
pauseAfterWords = 0
pauseDurationMilliseconds = 500
pauseOnPunctuation = true
punctuationPauseMultiplier = 2.0
wordLengthWPMMultiplier = 5.0
frameWordCount = 1
```

- [x] Implement `delay(for:settings:) -> Duration`.
- [x] Implement `shouldPause(atWordIndex:pauseAfterWords:) -> Bool`.
- [x] Implement `formatTimeRemaining(remainingWords:wpm:) -> String`.
- [x] Run timing tests.

Acceptance criteria:

- `hello` at 300 WPM delays 200 ms.
- `word.` at 300 WPM with 2x punctuation delays 400 ms.
- `word,` at 300 WPM delays 300 ms.
- `extraordinary` at 300 WPM with 10% long-word multiplier delays about 220 ms.

## Task 4: Build Reading Session State Machine

**Files:**
- Create: `Reader/Domain/ReadingSession.swift`
- Create: `ReaderTests/ReadingSessionTests.swift`

- [x] Model session state: text, words, current index, playing/paused/stopped, progress, current word, current frame, remaining time.
- [x] Implement actions: load text, play, pause, resume, stop, restart, step forward, step backward, seek percentage, jump value.
- [x] Use a testable clock/timer abstraction so playback tests do not sleep.
- [x] Run session tests.

Acceptance criteria:

- Play advances word-by-word using `WordTiming`.
- Pause cancels scheduled advancement without losing position.
- Stop resets to word 0.
- Jump accepts `150` and `50%`, clamps out-of-range input.
- Progress is consistent with current word index.

## Task 5: Implement Native Main Reader UI

**Files:**
- Create: `Reader/Features/Reader/ReaderView.swift`
- Create: `Reader/Features/Reader/RSVPDisplayView.swift`
- Create: `Reader/Features/Reader/ProgressBarView.swift`
- Create: `Reader/Features/Reader/PlaybackControlsView.swift`
- Modify: `Reader/App/RootView.swift`

- [x] Build black full-screen reader layout.
- [x] Add red center marker line.
- [x] Center the ORP character exactly at the screen midpoint.
- [x] Add single-word and multi-word display modes.
- [x] Add bottom progress and controls.
- [x] Add focus mode when playing or paused.
- [x] Add portrait and landscape previews.
- [x] Build and run on simulator.

Acceptance criteria:

- No visible layout shift when words change.
- Very short and very long words remain readable without overlapping controls.
- The ORP character stays aligned to the center marker.
- Focus mode hides nonessential controls.

## Task 6: Implement Text, PDF, And EPUB Import

**Files:**
- Create: `Reader/Import/DocumentImportService.swift`
- Create: `Reader/Import/PDFTextExtractor.swift`
- Create: `Reader/Import/EPUBTextExtractor.swift`
- Create: `Reader/Features/Reader/LoadContentView.swift`
- Create: `ReaderTests/DocumentImportServiceTests.swift`
- Modify: `Reader/Info.plist`

- [x] Add paste-text UI.
- [x] Add SwiftUI `.fileImporter` for `.pdf` and `.epub`.
- [x] Implement PDF text extraction with `PDFDocument(url:)` and `document.string`.
- [x] Evaluate EPUB package API against a real EPUB fixture.
- [x] Implement EPUB text extraction from spine order.
- [x] Normalize extracted text with whitespace collapse and repeated terminal punctuation cleanup.
- [x] Add user-visible loading and error states.
- [x] Run parser tests and a manual import smoke test.

Acceptance criteria:

- PDF import produces readable text from a text-based PDF.
- EPUB import preserves chapter order.
- Unsupported file types are rejected with a clear error.
- Large files show loading state and do not freeze the UI.

## Task 7: Implement Settings And Control Surface

**Files:**
- Create: `Reader/Features/Reader/SettingsView.swift`
- Modify: `Reader/Features/Reader/ReaderView.swift`
- Modify: `Reader/Domain/ReaderSettings.swift`

- [x] Add WPM slider 50-1000 with step 25.
- [x] Add WPM presets 200, 300, 400, 500.
- [x] Add toggles/sliders for fade, punctuation pause, long-word multiplier, periodic pause, pause duration, and frame word count.
- [x] Add touch controls for back/forward and slower/faster.
- [x] Add hardware keyboard commands for Space, Escape, arrows, `G`, and Command-S.
- [x] Run UI smoke tests.

Acceptance criteria:

- Settings match source defaults and ranges.
- Settings changes affect playback immediately.
- Hardware keyboard shortcuts work on simulator with keyboard connected.

## Task 8: Implement Jump, Progress Seek, Save, And Resume

**Files:**
- Create: `Reader/Features/Reader/JumpToPositionView.swift`
- Create: `Reader/Features/Reader/ResumeSessionView.swift`
- Create: `Reader/Persistence/SavedReadingSession.swift`
- Create: `Reader/Persistence/SessionStore.swift`
- Create: `ReaderTests/SessionStoreTests.swift`
- Modify: `Reader/Features/Reader/ProgressBarView.swift`
- Modify: `Reader/Features/Reader/ReaderView.swift`

- [x] Add jump sheet accepting word number or percentage.
- [x] Add tappable/draggable progress seek when not playing.
- [x] Add SwiftData model containing text, current index, total words, settings, and saved timestamp.
- [x] Add save action.
- [x] Add startup resume prompt.
- [x] Add clear saved session action.
- [x] Run persistence and UI tests.

Acceptance criteria:

- Closing/reopening the app can restore the saved session.
- Resume restores position and all settings.
- Start fresh clears the saved session.
- Progress seeking is disabled during active playback.

## Task 9: Accessibility, Interruption Handling, And Polish

**Files:**
- Modify: all `Reader/Features/Reader/*.swift`
- Modify: `Reader/Domain/ReadingSession.swift`
- Create: `ReaderUITests/ReaderFlowUITests.swift`

- [x] Add accessibility labels to icon-only controls.
- [x] Respect Reduce Motion by disabling fade animation.
- [x] Pause playback on app backgrounding and incoming interruption.
- [x] Ensure Dynamic Type does not overlap controls.
- [x] Add VoiceOver-friendly labels for current word/progress.
- [x] Add screenshot verification on iPhone SE-size and large Pro Max-size simulators.

Acceptance criteria:

- Main flow is usable without hidden unlabeled buttons.
- Reduce Motion disables fade.
- App does not keep advancing while backgrounded.
- No text/control overlap on small screens.

## Task 10: Final Verification And Release Readiness

**Files:**
- Create: `docs/ios-rsvp-reader-acceptance.md`
- Modify: `README.md`

- [x] Document supported formats, limitations, and controls.
- [x] Run full unit and UI suite:

```bash
xcodebuild test -scheme Reader -destination 'platform=iOS Simulator,name=iPhone 17'
```

- [x] Run archive build:

```bash
xcodebuild -scheme Reader -destination 'generic/platform=iOS' archive
```

- [x] Manually test:
  - paste text
  - import PDF
  - import EPUB
  - play/pause/resume
  - WPM changes
  - punctuation pauses
  - jump by word and percentage
  - save/resume
  - focus mode
  - hardware keyboard shortcuts

Acceptance criteria:

- All tests pass.
- Archive succeeds.
- Manual checklist passes on at least one small and one large iPhone simulator.
- The app behaves close enough to the source project that differences are documented, intentional, and iOS-specific.

## Execution Order

1. Domain logic: Tasks 2-4.
2. UI shell: Task 5.
3. Import pipeline: Task 6.
4. Settings and controls: Task 7.
5. Persistence and resume: Task 8.
6. Polish and verification: Tasks 9-10.

## Main Risks

- EPUB extraction quality varies by book structure. Mitigation: isolate `EPUBTextExtractor`, test with several EPUB fixtures, and keep parser dependency replaceable.
- PDF text extraction may be poor for scanned PDFs. Mitigation: MVP supports text-based PDFs only; OCR can be a later feature using Vision.
- Timer precision and app lifecycle can cause skipped/duplicated words. Mitigation: centralize scheduling in `ReadingSession` and pause on backgrounding.
- ORP centering can drift with proportional fonts. Mitigation: use monospaced font and split left/ORP/right layout around fixed center.
- Exact web keyboard shortcuts are not primary on touch devices. Mitigation: support hardware keyboard plus native touch controls.

## Definition Of Done

- Native iOS SwiftUI app builds and runs.
- Feature parity with the source web app is covered by acceptance checklist.
- Core RSVP logic has unit tests independent of UI.
- PDF and EPUB imports work from the iOS document picker.
- Saved session restores text, settings, and position.
- UI is readable and non-overlapping on small and large iPhone simulators.
