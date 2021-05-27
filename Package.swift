// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "swift-package-coverage",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "package-coverage",
            dependencies: [
                .target(name: "OptionsModule"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "ShellOut", package: "ShellOut"),
            ],
            path: "Sources/Main"
        ),
        .target(
            name: "OptionsModule",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
