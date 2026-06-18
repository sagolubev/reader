## MODIFIED Requirements

### Requirement: EPUB import
The system SHALL allow users to import EPUB files from the iOS document picker,
extract spine text in reading order, persist the result as a library book, and
open it while preserving access to the selected security-scoped file for the
duration of import.

#### Scenario: Valid EPUB
- **WHEN** the user imports an EPUB with readable spine content
- **THEN** the app starts access to the selected file before async import work
- **AND** the extracted chapter text is normalized, saved as a new library book
  with EPUB source metadata, and opened in spine order

#### Scenario: EPUB parse failure
- **WHEN** EPUB parsing fails
- **THEN** the system shows an import error, creates no library book, and keeps
  the active book unchanged
