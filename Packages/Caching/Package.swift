// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Caching",
    platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        .library(name: "Caching", targets: ["Caching"]),
    ],
    targets: [
        .target(name: "Caching"),
        .testTarget(name: "CachingTests", dependencies: ["Caching"]),
    ],
    swiftLanguageModes: [.v5]
)
