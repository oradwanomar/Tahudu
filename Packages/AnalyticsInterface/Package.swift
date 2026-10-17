// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AnalyticsInterface",
    platforms: [.iOS(.v14), .macOS(.v12)],
    products: [
        .library(name: "AnalyticsInterface", targets: ["AnalyticsInterface"]),
    ],
    targets: [
        .target(name: "AnalyticsInterface"),
    ],
    swiftLanguageModes: [.v5]
)
