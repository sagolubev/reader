# document-import Spec Delta

## MODIFIED Requirements

### Requirement: EPUB import

The system SHALL allow users to import EPUB files from the iOS document picker,
extract readable spine text in reading order, and support both ZIP-based EPUB
archives and filesystem package-directory EPUBs exported by providers such as
Apple Books.

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
- **THEN** the app shows an import error instead of creating a library book
