//
//  Options.swift
//  swift-package-coverage
//
//  Created by Braden Scothern on 5/26/21.
//  Copyright © 2021 Braden Scothern. All rights reserved.
//

import ArgumentParser

public struct Options: ParsableArguments {
    @Option(
        name: [.customLong("coverage-paths")],
        parsing: .upToNextOption,
        help: """
        Allows you to customize which paths are included in the coverage details. \
        If the coverage report contains one of these values in the file path then it will be included in the report.
        """
    )
    public var includedPaths: [String] = [
        "Sources/",
        "Source/",
        "Src/",
    ]

    @Option(
        help: """
        Set the path to change directories to before running commands.
        """
    )
    public var runPath: String = "."

    @Flag(
        help: """
        When set this will cause the `.build` directory to be deleted after gathering code coverage.
        """
    )
    var cleanAfterRun = false

    @Option(
        parsing: .upToNextOption,
        help: """
        Flags to pass to the swift compiler. \
        If you have an argument that contains spaces in it put it inside of quotes. \
        -Xswiftc will automatically be prepended to each input for you.
        """
    )
    public var swiftBuildFlags: [String] = []

    @Option(
        parsing: .upToNextOption,
        help: """
        Flags to pass to the C compiler. \
        If you have an argument that contains spaces in it put it inside of quotes. \
        -Xcc will automatically be prepended to each input for you.
        """
    )
    public var cBuildFlags: [String] = []

    @Option(
        parsing: .upToNextOption,
        help: """
        Flags to pass to the C++ compiler. \
        If you have an argument that contains spaces in it put it inside of quotes. \
        -Xcxx will automatically be prepended to each input for you.
        """
    )
    public var cxxBuildFlags: [String] = []
    
    @Option(
        parsing: .upToNextOption,
        help: """
        Flags to pass to the linker. \
        If you have an argument that contains spaces in it put it inside of quotes. \
        -Xlinker will automatically be prepended to each input for you.
        """
    )
    public var linkerFlags: [String] = []

    @Flag(
        inversion: .prefixedNo,
        help: """
        Controls if line counts should be printed out as part of coverage details.
        """
    )
    public var showLineCounts = true

    @Flag(
        inversion: .prefixedNo,
        help: """
        Controls if the coverage percentage should be printed out as part of coverage details.
        """
    )
    public var showPercentage = true

    @Flag(
        help: """
        When set the command that will be run to generate the code coverage report from SwiftPM will be printed to the console. \
        Then executaion will terminate without actually running it. \
        No other input or options will be considered beyond determining what would have been run.
        """
    )
    public var dryRun = false

    
    @Option(
        name: [.customLong("llvm-cov-json-path")],
        help: """
        An output path to write an llvm-cov JSON export file to that matches the output of this tool.
        """
    )
    public var llvmCovJSONOutputPath: String?

    public init() {}
}
