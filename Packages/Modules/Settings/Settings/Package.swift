// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "Settings", targets: ["Settings"]),
    ],
    dependencies: [
        .package(name: "DesignSystem", path: "../../../DesignSystem"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "Settings",
            dependencies: ["DesignSystem"]
        ),
        .testTarget(
            name: "SettingsTests",
            dependencies: [
                "Settings",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
