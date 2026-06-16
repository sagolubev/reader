## MODIFIED Requirements

### Requirement: Pasted text import
The system SHALL allow users to paste or type text and load it as a persisted
library book that becomes the active reading book.

#### Scenario: Load pasted text
- **WHEN** the user enters non-empty text and confirms loading
- **THEN** the text is normalized, saved as a new library book, opened in the
  reader, and word parsing runs on it

#### Scenario: Reject blank pasted text
- **WHEN** the user attempts to load blank text
- **THEN** no library book is created and the active book is not replaced

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
