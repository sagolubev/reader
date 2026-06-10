enum ReaderLifecyclePhase: Equatable {
    case active
    case inactive
    case background

    var shouldPausePlayback: Bool {
        self == .inactive || self == .background
    }
}

enum ReaderMotionPolicy {
    static func isFadeEnabled(
        settings: ReaderSettings,
        reduceMotionEnabled: Bool
    ) -> Bool {
        settings.fadeEnabled && !reduceMotionEnabled
    }
}
