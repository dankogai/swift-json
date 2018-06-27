// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSON",
    products: [
        .library(
            name: "JSON",
            type: .dynamic,
            targets: ["JSON"]),
        ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "JSON",
            dependencies: []),
        .target(
          name: "JSONRun",
          dependencies: ["JSON"]),
        .testTarget(
            name: "JSONTests",
            dependencies: ["JSON"]),
        ]
)
