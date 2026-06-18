## Context

SwiftUI `fileImporter` disables files whose Uniform Type Identifier does not
match any entry in `allowedContentTypes`. The app currently allows `.pdf` and a
single `.epubDocument` helper, which maps to `org.idpf.epub-container`.

Files coming from provider-specific book sources can use a different UTI. Those
files are valid import candidates for our importer, but the picker prevents the
user from selecting them before `DocumentImportService` can inspect the file.

## Approach

- Add `.content` to `SupportedBookFileTypes.documentTypes` as a system fallback
  for provider-specific document types.
- Keep `DocumentImportService` as the authoritative format gate after selection,
  so unsupported extensions still show the existing unsupported-file error.

## Non-Goals

- Do not add parsing support for FB2, MOBI, DOCX, or other formats in this
  change.
- Do not change EPUB parsing behavior.
