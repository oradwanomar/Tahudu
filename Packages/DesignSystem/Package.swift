// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            resources: [.process("Resources/DesignSystem.xcassets")]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: [
                "DesignSystem",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
