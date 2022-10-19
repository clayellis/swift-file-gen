// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "swift-file-gen",
    products: [
        .library(
            name: "FileGen",
            targets: ["FileGen"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "FileGen",
            dependencies: []
        ),
        .testTarget(
            name: "FileGenTests",
            dependencies: [
                "FileGen"
            ]
        ),
    ]
)
