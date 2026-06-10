import Foundation

struct ReaderLaunchOptions {
    static let resetSavedSessionArgument = "--reader-ui-test-reset-session"

    let resetSavedSessionOnLaunch: Bool

    init(arguments: [String] = ProcessInfo.processInfo.arguments) {
        resetSavedSessionOnLaunch = arguments.contains(Self.resetSavedSessionArgument)
    }

    static var current: ReaderLaunchOptions {
        ReaderLaunchOptions()
    }
}
