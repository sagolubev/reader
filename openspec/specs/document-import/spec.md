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
extract spine text in reading order, persist the result as a library book, and
open it.

#### Scenario: Valid EPUB
- **WHEN** the user imports an EPUB with readable spine content
- **THEN** the extracted chapter text is normalized, saved as a new library book
  with EPUB source metadata, and opened in spine order

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
