## Context

`LibraryView` currently presents an empty state, a list of persisted
`LibraryBookSnapshot` rows, open-book callbacks, and delete callbacks. Adding
content was implemented by `ReaderView` through the `LoadContentView` sheet and
`loadImportedContent(_:)`, but the sheet adds an unnecessary choice before file
selection. Both reader and library add-book controls should skip that
intermediate sheet and open file selection directly.

## Goals / Non-Goals

**Goals:**

- Add a clear add-book action inside the library for both empty and populated
  states.
- Open the system document picker directly from the library add-book action.
- Open the system document picker directly from the main reader add-book action.
- Remove the legacy `Load Content` sheet route from `ReaderView`.
- Reuse existing PDF and EPUB extraction, validation, persistence, and active
  book restoration after file selection.
- Keep persistence and import behavior centralized in the existing
  `ReaderView.loadImportedContent(_:)` path.
- Keep the change scoped to SwiftUI wiring and source/UI tests.

**Non-Goals:**

- No new book data model, import service, or persistence path.
- No multi-select library editing mode.
- No change to existing swipe or long-press delete behavior.
- No replacement pasted-text entry point in this change; add-book is file-based
  direct selection.

## Decisions

- Add an `onAddBook` callback to `LibraryView`. This keeps `LibraryView`
  presentation-focused and avoids giving it direct knowledge of
  `ReaderView`'s sheet routing or import persistence.
- Present the add-book action as a toolbar button in the library navigation
  stack. A toolbar action remains visible in empty and populated states without
  competing with book rows.
- Route main reader `onAddBook` to a direct file-import presentation owned by
  `ReaderView`. This keeps the document picker state near the existing import
  service and avoids presenting `LoadContentView` just to reach its file
  importer.
- Let `LibraryView` own its local file importer and pass selected URLs back to
  `ReaderView` through `onAddBook`. This keeps cancelation behavior local: if
  the user cancels from the library, the library remains open and unchanged.
- Share the file-selection completion path with the existing document import
  behavior where practical: selected PDF/EPUB URLs are imported with
  `DocumentImportService`, converted to `ImportedContent`, then passed through
  the current book creation and restoration logic.
- Add source-level coverage for the callback and visible toolbar action, plus
  update app construction tests for the new initializer argument.

## Risks / Trade-offs

- Presenting a document picker while the library sheet is open can conflict
  with SwiftUI modal ownership. Mitigation: keep the direct file importer state
  in `ReaderView` and dismiss or replace the library presentation in one
  controlled callback path.
- A toolbar-only action may be less prominent than a large empty-state button.
  Mitigation: the button is visible in both library states and can be paired
  with an empty-state prompt later if testing shows discoverability issues.
- Removing the pasted-text sheet means text must come from PDF/EPUB files for
  now. Mitigation: keep the file import path stable and central so a future
  plain-text file or paste-specific flow can be added intentionally.
