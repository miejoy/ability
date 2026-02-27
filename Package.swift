// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ability",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Ability",
            targets: ["Ability"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/miejoy/auto-config.git", branch: "main"),
        .package(url: "https://github.com/miejoy/module-monitor.git", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can dt;9csjskdjjkdnfeqwdbfgbn  bak zx o0 vcefine a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Ability",
            dependencies: [
                .product(name: "AutoConfig", package: "auto-config"),
                .product(name: "ModuleMonitor", package: "module-monitor")
            ]
        ),
        .testTarget(
            name: "AbilityTests",
            dependencies: ["Ability"]),
    ]
)
