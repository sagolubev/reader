## 1. Source And View Tests

- [x] 1.1 Add a failing source test that `LibraryView` exposes an add-book callback and visible add-book toolbar action.
- [x] 1.2 Update `ReaderTests` construction coverage for the new `LibraryView` initializer argument.
- [x] 1.3 Add a failing source test that the library add-book path opens direct file selection instead of `ReaderSheet.loadContent`.
- [x] 1.4 Add a failing source test that the main reader add-book button opens direct file selection instead of `LoadContentView`.
- [x] 1.5 Update app/unit/UI smoke coverage to stop depending on the removed load-content sheet.

## 2. Library Add-Book UI

- [x] 2.1 Add an `onAddBook` callback to `LibraryView`.
- [x] 2.2 Add a library toolbar button with a plus-style add-book label that is visible for empty and populated library states.

## 3. Direct File Selection Routing

- [x] 3.1 Wire the library add-book callback from `ReaderView` to direct document picker presentation for supported PDF and EPUB files.
- [x] 3.2 Extract or reuse file import completion handling so selected files still create `ImportedContent` through `DocumentImportService`.
- [x] 3.3 Verify successful library file imports create, persist, and open a new library book through the existing book creation path.
- [x] 3.4 Verify canceling document picker selection leaves the library unchanged.
- [x] 3.5 Wire the main reader add-book control to direct document picker presentation.
- [x] 3.6 Remove the legacy `Load Content` sheet and pasted-text UI route.

## 4. Verification

- [x] 4.1 Run `swift test`.
- [x] 4.2 Run the app/unit/UI suite on `iPhone 17` simulator because SwiftUI modal/file importer routing changes.
- [x] 4.3 Run `openspec validate add-library-add-book-button --strict`.
