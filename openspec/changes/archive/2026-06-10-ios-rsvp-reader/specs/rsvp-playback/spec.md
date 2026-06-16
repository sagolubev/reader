## ADDED Requirements

### Requirement: Text tokenization
The system SHALL parse reading text into an ordered array of non-empty word tokens by trimming leading/trailing whitespace and splitting on one or more Unicode whitespace characters.

#### Scenario: Multiple whitespace characters
- **WHEN** the reader loads `  Hello   world\nagain\t `
- **THEN** the parsed words are `Hello`, `world`, and `again` in that order

#### Scenario: Empty input
- **WHEN** the reader loads an empty or whitespace-only string
- **THEN** the parsed word list is empty and playback cannot start

### Requirement: ORP calculation
The system SHALL calculate the Optimal Recognition Point letter for each displayed word using the source algorithm: 1-3 letters highlight letter 1, 4-5 letters highlight letter 2, 6-9 letters highlight letter 3, 10-12 letters highlight letter 4, and longer words use `floor(log2(letterCount - 1)) + 2` as a one-based letter position.

#### Scenario: Latin word
- **WHEN** the reader displays `hello`
- **THEN** the highlighted ORP letter is `e`

#### Scenario: Cyrillic word
- **WHEN** the reader displays `привет`
- **THEN** the highlighted ORP letter is the third letter

#### Scenario: Leading punctuation
- **WHEN** the reader displays `«привет»`
- **THEN** the highlighted ORP letter skips the leading punctuation before applying the ORP position

#### Scenario: Word without letters
- **WHEN** the reader displays a token containing no letters
- **THEN** the reader highlights the first displayable character without crashing

### Requirement: Word display frame
The system SHALL support one-word display and odd-number multi-word display frames where the active word is centered within the frame whenever surrounding words exist.

#### Scenario: Single word mode
- **WHEN** frame word count is `1`
- **THEN** only the active word is displayed

#### Scenario: Multi-word mode
- **WHEN** frame word count is `5` and the active word has enough neighboring words
- **THEN** two preceding words, the active word, and two following words are displayed with the active word highlighted

### Requirement: Reading speed and word delay
The system SHALL calculate a base word delay as `60000 / wordsPerMinute` milliseconds and support WPM values from 50 through 1000 in 25 WPM increments.

#### Scenario: Base delay
- **WHEN** WPM is `300` and the word is `hello`
- **THEN** the delay is `200` milliseconds

#### Scenario: Fast delay
- **WHEN** WPM is `600` and the word is `hello`
- **THEN** the delay is `100` milliseconds

### Requirement: Punctuation and long-word pauses
The system SHALL optionally extend word delay for sentence-ending punctuation, commas, and long words using reader settings.

#### Scenario: Sentence punctuation pause
- **WHEN** WPM is `300`, punctuation pauses are enabled, multiplier is `2`, and the word is `word.`
- **THEN** the delay is `400` milliseconds

#### Scenario: Comma pause
- **WHEN** WPM is `300`, punctuation pauses are enabled, and the word is `word,`
- **THEN** the delay is `300` milliseconds

#### Scenario: Punctuation disabled
- **WHEN** punctuation pauses are disabled and the word is `word.`
- **THEN** punctuation does not change the base delay

#### Scenario: Long word multiplier
- **WHEN** WPM is `300`, long-word multiplier is `10`, and the word is `extraordinary`
- **THEN** the delay is approximately `220` milliseconds

### Requirement: Playback state
The system SHALL provide play, pause, resume, stop, restart, step forward, and step backward actions while preserving a consistent current word index.

#### Scenario: Play advances
- **WHEN** playback starts with loaded words
- **THEN** the current word advances according to the calculated word delay

#### Scenario: Pause preserves position
- **WHEN** playback is paused
- **THEN** scheduled word advancement stops and the current word index is preserved

#### Scenario: Stop resets
- **WHEN** playback is stopped
- **THEN** the current word index resets to the start and progress resets to zero

### Requirement: Progress and jump
The system SHALL expose progress as a percentage of current word index over total words and allow jumping by absolute word number or percentage.

#### Scenario: Jump by word number
- **WHEN** the user jumps to `150`
- **THEN** the current word index becomes `150` clamped to the available word range

#### Scenario: Jump by percentage
- **WHEN** the user jumps to `50%` in a 200-word text
- **THEN** the current word index becomes `100`

#### Scenario: Time remaining
- **WHEN** 300 words remain at 300 WPM
- **THEN** the displayed remaining time is `1:00`
