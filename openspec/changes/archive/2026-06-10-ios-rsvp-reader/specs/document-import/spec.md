## ADDED Requirements

### Requirement: Pasted text import
The system SHALL allow users to paste or type text and load it as the active reading text.

#### Scenario: Load pasted text
- **WHEN** the user enters non-empty text and confirms loading
- **THEN** the text becomes the active reading text and word parsing runs on it

#### Scenario: Reject blank pasted text
- **WHEN** the user attempts to load blank text
- **THEN** the active reading text is not replaced

### Requirement: PDF import
The system SHALL allow users to import text-based PDF files from the iOS document picker and extract readable text with PDFKit.

#### Scenario: Text-based PDF
- **WHEN** the user imports a text-based PDF
- **THEN** the extracted document string becomes the active reading text

#### Scenario: Empty PDF extraction
- **WHEN** PDF extraction produces no readable text
- **THEN** the system shows an import error and does not replace the active text

### Requirement: EPUB import
The system SHALL allow users to import EPUB files from the iOS document picker and extract spine text in reading order.

#### Scenario: Valid EPUB
- **WHEN** the user imports an EPUB with readable spine content
- **THEN** the extracted chapter text becomes the active reading text in spine order

#### Scenario: EPUB parse failure
- **WHEN** EPUB parsing fails
- **THEN** the system shows an import error and keeps the previous reading text

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
