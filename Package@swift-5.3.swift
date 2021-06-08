// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "swift-package-coverage",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .executable(name: "package-coverage", targets: ["main"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
    ],
    targets: [
        .target(
            name: "main",
            dependencies: [
                .target(name: "PackageCoverage")
            ],
            path: "Sources.5.3"
        ),
        .target(
            name: "PackageCoverage",
            dependencies: [
                .target(name: "LLVMCovJSON"),
                .target(name: "OptionsModule"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "ShellOut", package: "ShellOut"),
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
            ],
            path: "Sources/Main"
        ),
        .target(
            name: "LLVMCovJSON",
            dependencies: [
                .product(name: "SwiftyJSON", package: "SwiftyJSON"),
            ],
            path: "Sources/llvm-cov+JSON"
        ),
        .target(
            name: "OptionsModule",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
    ]
)
