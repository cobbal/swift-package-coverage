//
//  SwiftPackageCoverage.swift
//  swift-package-coverage
//
//  Created by Braden Scothern on 5/26/21.
//  Copyright © 2021 Braden Scothern. All rights reserved.
//

import ArgumentParser
import Foundation
import LLVMCovJSON
import OptionsModule
import ShellOut
import SwiftyJSON

@main
struct SwiftPackageCoverageCommand: ParsableCommand {
    static let configuration: CommandConfiguration = .init(
        commandName: "package-coverage",
        abstract: "Tests a Swift Package and gathers its code coverage.",
        version: "0.1.0"
    )

    struct ExitError: Swift.Error, CustomStringConvertible {
        let description: String
    }

    @OptionGroup
    var options: Options

    mutating func run() {
        runSwiftTestWithCoverage()
        let coverageFilePath = findCoverageFilePath()
        let coverage = processCoverageFile(atPath: coverageFilePath)
        output(coverage: coverage)
    }

    /// Runs `swift test` and generates the coverage file.
    func runSwiftTestWithCoverage() {
        guard !options.skipRun else {
            return
        }

        let arguments = options.arguments
        guard !options.dryRun else {
            print("swift test --enable-code-coverage", terminator: "")
            if !arguments.isEmpty {
                print("", arguments.joined(separator: " "))
            }
            Self.exit(withError: ExitCode.success)
        }
        do {
            try shellOut(
                to: "swift test",
                arguments: ["--enable-code-coverage"] + arguments,
                at: options.runPath
            )
        } catch let error as ShellOutError {
            print(error.output)
            print(error.message)
            Self.exit(withError: ExitError(description: "Unable to run swift tests and gather coverage."))
        } catch {
            Self.exit(withError: ExitError(description: "Unknown Error. Unable to run swift tests and gather coverage. \(error)"))
        }
    }

    /// Finds the coverage file that should be processed.
    func findCoverageFilePath() -> String {
        do {
            return try shellOut(
                to: "swift test",
                arguments: ["--show-codecov-path"],
                at: options.runPath
            )
        } catch let error as ShellOutError {
            print(error.output)
            print(error.message)
            Self.exit(withError: ExitError(description: "Unknown Error. Unable to find coverage file."))
        } catch {
            Self.exit(withError: ExitError(description: "Unknown Error. Unable to find coverage file. \(error)"))
        }
    }

    /// Open and process the coverage JSON file.
    ///
    /// This will remove files that aren't applicable and recalculate totals to create an updated version of the JSON.
    func processCoverageFile(atPath path: String) -> JSON {
        var coverage: JSON
        do {
            let json = try Data(contentsOf: URL(fileURLWithPath: path))
            coverage = try .init(data: json)
        } catch {
            Self.exit(withError: ExitError(description: "Unable to open coverage JSON file: \(path)."))
        }

        return coverage
    }

    /// Write the coverage data to the appropriate places according to options.
    func output(coverage: JSON) {
        let totals = coverage[\.data].arrayValue[0][\.totals]
        let section: JSON

        switch options.llvmTotalType {
        case .branches:
            section = totals[\.branches]
        case .functions:
            section = totals[\.functions]
        case .instantiations:
            section = totals[\.instantiations]
        case .lines:
            section = totals[\.lines]
        case .regions:
            section = totals[\.regions]
        }

        if options.showLineCounts || options.showPercentage {
            print("=== \(options.llvmTotalType.rawValue.uppercasedFirst()) Coverage ===")
        }

        if options.showLineCounts {
            print("""
            Lines Total:    \(section[\.count].intValue)
            Lines Covered:  \(section[\.covered].intValue)
            """)
        }

        if options.showPercentage {
            print("""
            Percentage:     \(section[\.percent].doubleValue)
            """)
        }

        if let llvmCovJSONOutputPath = options.llvmCovJSONOutputPath {
            do {
                var data = try coverage.rawData(options: [.prettyPrinted, .sortedKeys])
                data.append("\n".data(using: .utf8)!)
                try data.write(to: URL(fileURLWithPath: llvmCovJSONOutputPath))
            } catch {
                Self.exit(withError: ExitError(description: "Unable to write llvm-cov JSON file to: \(llvmCovJSONOutputPath)."))
            }
        }
    }
}
