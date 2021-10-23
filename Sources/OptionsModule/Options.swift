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
        name: [.customLong("exclude-paths")],
        parsing: .upToNextOption,
        help: """
        Allows you to customize which paths are excluded in the coverage details. \
        If the coverage report contains one of these values in the file path then it will be excluded from the report. \
        This takes presidence over --coverage-paths.
        """
    )
    public var excludedPaths: [String] = [
        ".build/",
        ".git/",
    ]

    @Flag(
        help: """
        Determines if hidden directories should be searched or not when found in the --coverage-paths. \
        By default they are ignored.
        """
    )
    public var includeHiddenDirectories = false

    @Option(
        help: """
        Set the path to change directories to before running commands.
        """
    )
    public var runPath: String = "."

    @Flag(
        help: """
        Process the exisiting coverage file without running tests. \
        If no coverage file exists then exit with an error.
        """
    )
    public var skipRun = false

    @Flag(
        help: """
        When set the command that will be run to generate the code coverage report from SwiftPM will be printed to the console. \
        Then executaion will terminate without actually running it. \
        No other input or options will be considered beyond determining what would have been run.
        """
    )
    public var dryRun = false

    @Option(
        parsing: .upToNextOption,
        help: """
        Flags to pass to swift test. \
        These flags will be passed first after the base swift test command without any modification. \
        Use this to customize other swift build/test flags as needed.
        """
    )
    public var swiftFlags: [String] = []

    @Flag(
        help: """
        What kind of progress to show while gathering coverage.
        \(ProgressMode.allCases.map(\.help).map { "  \($0)" }.joined(separator: "\n"))
        """
    )
    public var progressMode: ProgressMode = .fullProgress

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

    @Option(
        name: [.customLong("llvm-cov-json")],
        help: """
        An output path to write an llvm-cov JSON export file to that matches the output of this tool.
        """
    )
    public var llvmCovJSONOutputPath: String?

    @Flag(help: """
    The llvm-cov JSON total section to report on. \
    The default matches the percentages shown in Xcode.
    """)
    public var llvmTotalType: LLVMTotalType = .lines

    public init() {}
}

extension Sequence {
    func beforeEachValue(insert insertedValue: Element) -> AnyIterator<Element> {
        var shouldInsert = true
        var sequenceIterator = makeIterator()
        var _nextValue = sequenceIterator.next()

        return AnyIterator<Element> {
            guard let nextValue = _nextValue else {
                return nil
            }
            defer { shouldInsert.toggle() }
            if shouldInsert {
                return insertedValue
            } else {
                _nextValue = sequenceIterator.next()
                return nextValue
            }
        }
    }
}

extension Options {
    /// All options processed and turned into the arguments to pass to the `swift` commands.
    public var swiftArguments: [String] {
        swiftFlags
    }
}
