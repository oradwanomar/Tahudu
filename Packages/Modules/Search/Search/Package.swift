// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Search",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Search", targets: ["Search"]),
    ],
    dependencies: [
        .package(name: "AnalyticsInterface", path: "../../../AnalyticsInterface"),
        .package(name: "Caching", path: "../../../Caching"),
        .package(name: "DesignSystem", path: "../../../DesignSystem"),
        .package(name: "Networking", path: "../../../Networking"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.19.4"),
    ],
    targets: [
        .target(
            name: "Search",
            dependencies: [
                .product(name: "AnalyticsInterface", package: "AnalyticsInterface"),
                .product(name: "Caching", package: "Caching"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Networking", package: "Networking"),
            ]
        ),
        .testTarget(
            name: "SearchTests",
            dependencies: [
                "Search", "Networking", "AnalyticsInterface", "Caching",
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
