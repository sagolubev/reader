import XCTest

final class ProjectConfigurationSourceTests: XCTestCase {
    func testReaderTargetUsesAppIconAsset() throws {
        let project = try sourceFile("Reader.xcodeproj/project.pbxproj")
        let appIconContents = try sourceFile("Reader/Assets.xcassets/AppIcon.appiconset/Contents.json")
        let appIconPath = repoRoot()
            .appendingPathComponent("Reader/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")

        XCTAssertTrue(project.contains("ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;"))
        XCTAssertTrue(appIconContents.contains("\"idiom\": \"ios-marketing\""))
        XCTAssertTrue(FileManager.default.fileExists(atPath: appIconPath.path))
    }

    func testReaderTargetDeclaresIPadOrientationsForArchiveValidation() throws {
        let project = try sourceFile("Reader.xcodeproj/project.pbxproj")

        XCTAssertTrue(project.contains("INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad"))
        XCTAssertTrue(project.contains("UIInterfaceOrientationPortraitUpsideDown"))
        XCTAssertTrue(project.contains("UIInterfaceOrientationLandscapeLeft"))
        XCTAssertTrue(project.contains("UIInterfaceOrientationLandscapeRight"))
    }

    private func sourceFile(_ path: String) throws -> String {
        let sourceURL = repoRoot().appendingPathComponent(path)
        return try String(contentsOf: sourceURL, encoding: .utf8)
    }

    private func repoRoot() -> URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
