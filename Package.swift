// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ReaderCore",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "ReaderCore", targets: ["ReaderCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", .upToNextMajor(from: "0.9.0"))
    ],
    targets: [
        .target(
            name: "ReaderCore",
            dependencies: [
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "Reader/Domain"
        ),
        .testTarget(
            name: "ReaderCoreTests",
            dependencies: [
                "ReaderCore",
                .product(name: "ZIPFoundation", package: "ZIPFoundation")
            ],
            path: "ReaderCoreTests"
        )
    ]
)
