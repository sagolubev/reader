## Why

The iOS document picker can show book files as disabled even when they are EPUB
documents. Some providers identify book files with provider-specific type
identifiers instead of the standard `org.idpf.epub-container`, so the current
strict picker filter is too narrow.

## What Changes

- Include a system `public.content` fallback in the supported picker types.
- Keep PDF and standard EPUB support unchanged.
- Keep final import validation in `DocumentImportService`, so unsupported
  extensions still produce a visible import error after selection.

## Impact

- `Reader/App/SupportedBookFileTypes.swift`: broaden picker UTType matching.
- `ReaderCoreTests/LibraryFlowSourceTests.swift`: guard the picker type list.
