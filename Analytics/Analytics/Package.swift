// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Analytics",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        .library(name: "Analytics", targets: ["Analytics"]),
    ],
    dependencies: [
        .package(name: "AnalyticsInterface", path: "../AnalyticsInterface"),
    ],
    targets: [
        .target(
            name: "Analytics",
            dependencies: [
                .product(name: "AnalyticsInterface", package: "AnalyticsInterface"),
            ]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: [
                "Analytics",
                .product(name: "AnalyticsInterface", package: "AnalyticsInterface"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
