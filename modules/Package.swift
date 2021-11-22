// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "wtNavLink",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "TCA", targets: ["TCA"]),
        .library(name: "TCA2", targets: ["TCA2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMinor(from: "0.28.1")),
    ],
    targets: [
        .target(
            name: "TCA",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "TCA2",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
    ]
)
