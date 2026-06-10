import XCTest

final class ProjectConfigurationSourceTests: XCTestCase {
    func testReaderTargetDeclaresIPadOrientationsForArchiveValidation() throws {
        let project = try sourceFile("Reader.xcodeproj/project.pbxproj")

        XCTAssertTrue(project.contains("INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad"))
        XCTAssertTrue(project.contains("UIInterfaceOrientationPortraitUpsideDown"))
        XCTAssertTrue(project.contains("UIInterfaceOrientationLandscapeLeft"))
        XCTAssertTrue(project.contains("UIInterfaceOrientationLandscapeRight"))
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
