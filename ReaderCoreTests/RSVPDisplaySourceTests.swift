import XCTest

final class RSVPDisplaySourceTests: XCTestCase {
    func testRSVPDisplayUsesBoundedSideColumnsInsteadOfOffsetOverlays() throws {
        let source = try sourceFile("Reader/App/RSVPDisplayView.swift")

        XCTAssertTrue(source.contains("GeometryReader"))
        XCTAssertTrue(source.contains("let sideWidth"))
        XCTAssertTrue(source.contains(".frame(width: sideWidth, alignment: .trailing)"))
        XCTAssertTrue(source.contains(".frame(width: sideWidth, alignment: .leading)"))
        XCTAssertTrue(source.contains(".clipped()"))
        XCTAssertFalse(source.contains(".offset(x:"))
    }

    private func sourceFile(_ path: String) throws -> String {
        let testFile = URL(fileURLWithPath: #filePath)
        let repoRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let sourceURL = repoRoot.appendingPathComponent(path)
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }
}
