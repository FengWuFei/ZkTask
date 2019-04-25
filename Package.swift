// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZkTask",
    dependencies: [
        .package(url: "https://github.com/FengWuFei/TaskKit.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ZkTask",
            dependencies: ["TaskKit"]),
        .testTarget(
            name: "ZkTaskTests",
            dependencies: ["ZkTask"]),
    ]
)
