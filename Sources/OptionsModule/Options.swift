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
        Allows you to customize which paths are included in the coverage details.
        """
    )
    public var includedPaths: [String] = [
        "Sources/",
        "Source/",
        "Src/",
    ]

    @Option(
        parsing: .upToNextOption,
        help: """
        Flags to pass to the swift compiler. \
        If you have an argument that contains spaces in it put it inside of quotes.
        """
    )
    public var swiftBuildFlags: [String] = []

    @Option(
        parsing: .upToNextOption,
        help: """
        Flags to pass to the C compiler. \
        If you have an argument that contains spaces in it put it inside of quotes.
        """
    )
    public var cBuildFlags: [String] = []

    @Option(
        parsing: .upToNextOption,
        help: """
        Flags to pass to the C++ compiler. \
        If you have an argument that contains spaces in it put it inside of quotes.
        """
    )
    public var cxxBuildFlags: [String] = []

    @Flag(
        inversion: .prefixedNo,
        help: """
        Controls if line counts should be printed out as part of coverage details.
        """
    )
    var showLineCounts = false

    @Flag(
        inversion: .prefixedNo,
        help: """
        Controls if the coverage percentage should be printed out as part of coverage details.
        """
    )
    var showPercentage = true

    @Flag(
        help: """
        When set the command that will be run to generate the code coverage report from SwiftPM will be printed to the console. \
        Then executaion will terminate without actually running it.
        """
    )
    var dryRun = false

    public init() {}
}
