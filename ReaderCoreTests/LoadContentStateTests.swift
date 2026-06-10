import XCTest
@testable import ReaderCore

final class LoadContentStateTests: XCTestCase {
    func testLoadPastedTextReturnsNormalizedTextAndClearsInput() {
        var state = LoadContentState(pastedText: "  Hello\n\nreader!!!  ")

        let text = state.takePastedText()

        XCTAssertEqual(text, "Hello reader!")
        XCTAssertEqual(state.pastedText, "")
        XCTAssertNil(state.errorMessage)
    }

    func testLoadPastedTextRejectsBlankWithoutClearingInput() {
        var state = LoadContentState(pastedText: " \n\t ")

        let text = state.takePastedText()

        XCTAssertNil(text)
        XCTAssertEqual(state.pastedText, " \n\t ")
        XCTAssertEqual(state.errorMessage, "Enter text to load.")
    }

    func testFileImportStatePreventsDuplicateImportsAndReturnsNormalizedText() {
        var state = LoadContentState()

        XCTAssertTrue(state.beginFileImport())
        XCTAssertFalse(state.beginFileImport())

        let text = state.finishFileImport(.success("  Imported\tbook??  "))

        XCTAssertEqual(text, "Imported book?")
        XCTAssertFalse(state.isImportingFile)
        XCTAssertNil(state.errorMessage)
    }

    func testFileImportFailureShowsVisibleErrorAndClearsLoadingState() {
        var state = LoadContentState()

        XCTAssertTrue(state.beginFileImport())
        let text = state.finishFileImport(.failure(DocumentImportError.unsupportedFileType("txt")))

        XCTAssertNil(text)
        XCTAssertFalse(state.isImportingFile)
        XCTAssertEqual(state.errorMessage, "Unsupported file type: txt")
    }

    func testFileImportSuccessWithBlankTextShowsEmptyExtractionError() {
        var state = LoadContentState()

        XCTAssertTrue(state.beginFileImport())
        let text = state.finishFileImport(.success(" \n\t "))

        XCTAssertNil(text)
        XCTAssertFalse(state.isImportingFile)
        XCTAssertEqual(state.errorMessage, "No readable text was found in this document.")
    }
}
