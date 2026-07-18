## ADDED Requirements

### Requirement: Add book from reader header
The system SHALL expose an add-book action from the main reader header that
starts the system file selection flow for importing a book file.

#### Scenario: Start reader add-book flow
- **WHEN** the user taps the main reader add-book action
- **THEN** the system opens the document picker directly for supported book
  files
- **AND** the system does not present the `Load Content` sheet

#### Scenario: Cancel reader file selection
- **WHEN** the user cancels document picker selection from the main reader
  add-book action
- **THEN** the active reader content and library remain unchanged

#### Scenario: Complete reader add-book flow
- **WHEN** the user selects a supported PDF or EPUB file from the main reader
  add-book flow
- **THEN** the system imports the file, persists the content as a new library
  book, and opens it in the reader
