## ADDED Requirements

### Requirement: Add book from library
The system SHALL expose an add-book action from the library that starts the
system file selection flow for importing a book file.

#### Scenario: Empty library add action
- **WHEN** the user opens the library and no books exist
- **THEN** the library shows a visible add-book action

#### Scenario: Populated library add action
- **WHEN** the user opens the library and one or more books exist
- **THEN** the library shows a visible add-book action without hiding existing
  books

#### Scenario: Start add-book flow
- **WHEN** the user taps the library add-book action
- **THEN** the system opens the document picker directly for supported book
  files
- **AND** the system does not present the `Load Content` sheet

#### Scenario: Cancel file selection
- **WHEN** the user cancels document picker selection from the library add-book
  action
- **THEN** the library remains open with its existing books unchanged

#### Scenario: Complete add-book flow
- **WHEN** the user selects a supported PDF or EPUB file from the library
  add-book flow
- **THEN** the system imports the file, persists the content as a new library
  book, and opens it in the reader
