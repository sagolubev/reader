import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum ReaderThemeMode: String, CaseIterable {
    case lightWarm
    case dark

    static let storageKey = "reader.theme.mode"

    var next: ReaderThemeMode {
        switch self {
        case .lightWarm:
            return .dark
        case .dark:
            return .lightWarm
        }
    }

    var preferredColorScheme: ColorScheme {
        switch self {
        case .lightWarm:
            return .light
        case .dark:
            return .dark
        }
    }

    var toggleSystemName: String {
        switch self {
        case .lightWarm:
            return "moon.fill"
        case .dark:
            return "sun.max.fill"
        }
    }

    var toggleAccessibilityLabel: String {
        switch self {
        case .lightWarm:
            return "Switch to dark theme"
        case .dark:
            return "Switch to light theme"
        }
    }
}

enum ReaderTheme {
    static let background = adaptiveColor(
        light: color(0.98, 0.94, 0.86),
        dark: color(0.00, 0.00, 0.00)
    )
    static let surface = adaptiveColor(
        light: color(1.00, 0.97, 0.91),
        dark: color(0.07, 0.07, 0.07)
    )
    static let primaryText = adaptiveColor(
        light: color(0.13, 0.10, 0.07),
        dark: color(1.00, 1.00, 1.00)
    )
    static let secondaryText = adaptiveColor(
        light: color(0.45, 0.37, 0.29),
        dark: color(1.00, 1.00, 1.00, alpha: 0.62)
    )
    static let accent = adaptiveColor(
        light: color(0.88, 0.10, 0.10),
        dark: color(0.92, 0.12, 0.12)
    )
    static let progressTrack = adaptiveColor(
        light: color(0.30, 0.23, 0.16, alpha: 0.16),
        dark: color(1.00, 1.00, 1.00, alpha: 0.16)
    )
    static let controlFill = adaptiveColor(
        light: color(0.20, 0.15, 0.10, alpha: 0.12),
        dark: color(1.00, 1.00, 1.00, alpha: 0.14)
    )
    static let controlForeground = primaryText
    static let primaryControlFill = adaptiveColor(
        light: color(0.17, 0.12, 0.08),
        dark: color(1.00, 1.00, 1.00)
    )
    static let primaryControlForeground = adaptiveColor(
        light: color(0.98, 0.94, 0.86),
        dark: color(0.00, 0.00, 0.00)
    )
    static let textInputFill = adaptiveColor(
        light: color(1.00, 1.00, 1.00, alpha: 0.56),
        dark: color(1.00, 1.00, 1.00, alpha: 0.08)
    )
    static let separator = adaptiveColor(
        light: color(0.32, 0.24, 0.17, alpha: 0.18),
        dark: color(1.00, 1.00, 1.00, alpha: 0.16)
    )

    private static func color(_ red: Double, _ green: Double, _ blue: Double, alpha: Double = 1) -> PlatformColor {
        PlatformColor(
            red: CGFloat(red),
            green: CGFloat(green),
            blue: CGFloat(blue),
            alpha: CGFloat(alpha)
        )
    }

    private static func adaptiveColor(light: PlatformColor, dark: PlatformColor) -> Color {
        #if canImport(UIKit)
        Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
        #else
        Color(light)
        #endif
    }
}

#if canImport(UIKit)
private typealias PlatformColor = UIColor
#else
private typealias PlatformColor = NSColor
#endif
