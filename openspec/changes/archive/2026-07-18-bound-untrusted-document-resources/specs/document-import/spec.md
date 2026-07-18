# Document Import Resource Safety

## ADDED Requirements

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
