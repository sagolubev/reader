## Context

The document picker returns security-scoped URLs for files outside the app
sandbox. EPUB parsing uses ZIPFoundation and reads multiple entries from the
selected archive, so the security scope must be active before the first archive
read and remain active through extraction.

The direct file-selection flow introduced a `Task` boundary, plus an explicit
`Task.yield()`, before `startAccessingSecurityScopedResource()` is called. On a
real iPhone this can make the selected EPUB inaccessible by the time import
begins.

## Approach

- In `ReaderView.importLibraryBookFile(_:)`, call
  `startAccessingSecurityScopedResource()` before creating async work.
- Capture the access result and call `stopAccessingSecurityScopedResource()` in
  a `defer` inside the import task, so the scope stays active until the import
  attempt finishes.
- Call `importLibraryBookFile(_:)` directly from the file importer completion
  instead of wrapping it in another `Task`.

## Non-Goals

- Do not reintroduce the old Load Content sheet.
- Do not change EPUB parsing rules or document normalization.
- Do not add a loading overlay in this narrow bug fix.
