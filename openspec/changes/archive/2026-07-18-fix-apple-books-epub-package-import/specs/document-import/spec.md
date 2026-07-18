# document-import Spec Delta

## MODIFIED Requirements

### Requirement: EPUB import

The system SHALL allow users to import EPUB files from the iOS document picker,
including files exposed by providers with book/document content identifiers,
extract readable spine text in reading order from both ZIP-based archives and
filesystem package directories, persist the result as a library book, and open
it while preserving access to the selected security-scoped file for the
duration of import.

#### Scenario: Valid EPUB

- **WHEN** the user imports an EPUB with readable spine content
- **THEN** the app treats both standard EPUB and provider-specific content
  identifiers as selectable import candidates
- **AND** the app starts access to the selected file before async import work
- **AND** the extracted chapter text is normalized, saved as a new library book
  with EPUB source metadata, and opened in spine order

#### Scenario: Valid ZIP EPUB

- **WHEN** the user imports a ZIP-based EPUB with readable spine content
- **THEN** the app extracts normalized text in spine order

#### Scenario: Valid package-directory EPUB

- **GIVEN** a selected `.epub` URL is a directory package containing
  `META-INF/container.xml`, an OPF package document, and readable XHTML spine
  entries
- **WHEN** the user imports it
- **THEN** the app extracts normalized text in spine order

#### Scenario: URL-managed EPUB hrefs

- **GIVEN** an OPF manifest href contains percent escapes, query strings, or
  fragments
- **WHEN** the app resolves the referenced chapter
- **THEN** the app resolves the actual resource path before extracting text

#### Scenario: EPUB parse failure

- **WHEN** EPUB parsing fails
- **THEN** the system shows an import error, creates no library book, and keeps
  the active book unchanged

#### Scenario: Apple Books package

- **WHEN** the user selects a directory-package EPUB exported by Apple Books
- **THEN** the system resolves its container and spine resources using the same
  import behavior as a ZIP-based EPUB
