// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "swift-package-coverage",
    platforms: [
        .macOS(.v10_15),
    ],
    dependencies: [
        .package(url: "https://github.com/bscothern/SignalHandler", .branch("main")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.0")),
        .package(url: "https://github.com/JohnSundell/ShellOut.git", from: "2.0.0"),
        .package(url: "https://github.com/kiliankoe/CLISpinner", .exact("0.4.0")),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.1.4"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "package-coverage",
            dependencies: [
                .target(name: "LLVMCovJSON"),
                .target(name: "OptionsModule"),
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "CLISpinner", package: "CLISpinner"),
                .product(name: "Rainbow", package: "Rainbow"),
                .product(name: "ShellOut", package: "ShellOut"),
                .product(name: "SignalHandler", package: "SignalHandler"),
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
