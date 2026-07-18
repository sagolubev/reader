# document-import Specification

## Purpose
Define safe PDF and EPUB selection, extraction, normalization, validation, and
library-import behavior.
## Requirements
### Requirement: PDF import
The system SHALL allow users to import text-based PDF files from the iOS
document picker, extract readable text with PDFKit, persist the result as a
library book, and open it.

#### Scenario: Text-based PDF
- **WHEN** the user imports a text-based PDF
- **THEN** the extracted document string is normalized, saved as a new library
  book with PDF source metadata, and opened in the reader

#### Scenario: Empty PDF extraction
- **WHEN** PDF extraction produces no readable text
- **THEN** the system shows an import error, creates no library book, and keeps
  the active book unchanged

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

### Requirement: Text normalization
The system SHALL normalize imported document text by collapsing whitespace, trimming edges, and reducing repeated sentence punctuation.

#### Scenario: Normalized imported text
- **WHEN** extracted text contains repeated whitespace and `!!!`
- **THEN** the loaded text contains single spaces and a single `!`

### Requirement: Import feedback
The system SHALL show loading and error states during file import.

#### Scenario: Large import
- **WHEN** a document import is in progress
- **THEN** the UI displays a loading state and prevents duplicate import actions

#### Scenario: Unsupported file
- **WHEN** the selected file type is not PDF or EPUB
- **THEN** the system rejects it with a visible unsupported-type error

### Requirement: Bounded document processing
The system SHALL reject documents that exceed configured byte, page, EPUB
resource, spine, XML text-segment, extracted-character, token-count, or
per-token limits.

#### Scenario: Resource limit exceeded
- **WHEN** an imported document exceeds any configured processing limit
- **THEN** the system shows a safe import error, creates no library book, and
  keeps the active book unchanged

### Requirement: Imported documents SHALL use bounded resources

Reader SHALL reject a document before any individual resource, cumulative
resource set, decoded output, page set, or token set exceeds configured limits.

#### Scenario: Oversized EPUB archive entry

- **GIVEN** a valid EPUB containing an entry above the resource limit
- **WHEN** Reader imports the EPUB
- **THEN** import fails with `resourceLimitExceeded`

#### Scenario: Oversized EPUB directory resource

- **GIVEN** a directory-backed EPUB containing a file above the resource limit
- **WHEN** Reader imports the EPUB
- **THEN** import fails before reading the complete file

#### Scenario: Excessively segmented EPUB XHTML

- **GIVEN** an EPUB chapter below byte and character limits whose text is split
  across more XML text callbacks than policy permits
- **WHEN** Reader imports the EPUB
- **THEN** import fails with `resourceLimitExceeded` before retaining every text
  segment

#### Scenario: Excessive PDF pages

- **GIVEN** a valid PDF whose page count exceeds policy
- **WHEN** Reader imports the PDF
- **THEN** import fails before every page string is joined

#### Scenario: Excessive token count

- **GIVEN** imported text with more tokens than policy permits
- **WHEN** Reader tokenizes the text
- **THEN** tokenization fails without returning a partial token list

#### Scenario: Giant display token

- **GIVEN** a token longer than the display policy permits
- **WHEN** Reader prepares ORP display parts
- **THEN** processing fails before scanning the complete token

#### Scenario: Ordinary supported document

- **GIVEN** a supported PDF or EPUB below every configured limit
- **WHEN** Reader imports and opens it
- **THEN** extracted text and RSVP behavior remain unchanged
