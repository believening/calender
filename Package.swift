// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MultiCalendarApp",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "MultiCalendarApp",
            targets: ["MultiCalendarApp"]),
    ],
    dependencies: [
        // SQLite 数据库
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.21.0"),
    ],
    targets: [
        .target(
            name: "MultiCalendarApp",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ]),
        .testTarget(
            name: "MultiCalendarAppTests",
            dependencies: ["MultiCalendarApp"],
            path: "Tests"),
    ]
)
