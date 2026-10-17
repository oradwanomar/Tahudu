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
        .package(name: "DesignSystem", path: "../../../DesignSystem"),
        .package(name: "Networking", path: "../../../Networking"),
    ],
    targets: [
        .target(
            name: "Search",
            dependencies: [
                .product(name: "AnalyticsInterface", package: "AnalyticsInterface"),
                .product(name: "DesignSystem", package: "DesignSystem"),
                .product(name: "Networking", package: "Networking"),
            ]
        ),
        .testTarget(
            name: "SearchTests",
            dependencies: ["Search", "Networking", "AnalyticsInterface"]
        ),
    ],
    swiftLanguageModes: [.v5]
)
