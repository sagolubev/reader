## 1. Theme Specification

- [x] 1.1 Add OpenSpec delta for warm light reader UI
- [x] 1.2 Validate the OpenSpec change

## 2. Theme Implementation

- [x] 2.1 Add failing source tests for light warm theme usage
- [x] 2.2 Add shared `ReaderTheme` semantic colors
- [x] 2.3 Apply theme to main reader, RSVP display, header, and controls
- [x] 2.4 Apply theme to sheets: library, bookmarks, load content, settings,
      jump, and resume
- [x] 2.5 Add failing source tests for persistent theme toggle
- [x] 2.6 Add header theme toggle and persisted theme mode

## 3. Verification

- [x] 3.1 Run `openspec validate reader-light-warm-theme --strict`
- [x] 3.2 Run `swift test`
- [x] 3.3 Run Xcode simulator tests
- [x] 3.4 Run simulator build and screenshot visual check
