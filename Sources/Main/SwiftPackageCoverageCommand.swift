//
//  SwiftPackageCoverage.swift
//  swift-package-coverage
//
//  Created by Braden Scothern on 5/26/21.
//  Copyright © 2021 Braden Scothern. All rights reserved.
//

import ArgumentParser
import CLISpinner
import Foundation
import LLVMCovJSON
import OptionsModule
import Rainbow
import ShellOut
import SignalHandler
import SwiftyJSON

// Temporary hack around GitHub action's not supporting macOS 11 which means they don't support Xcode 12.5 which adds support for @main in SwiftPM...
#if swift(>=5.4)
@main
extension SwiftPackageCoverageCommand {}
#endif

public struct SwiftPackageCoverageCommand: ParsableCommand {
    public static let configuration: CommandConfiguration = .init(
        commandName: "package-coverage",
        abstract: "Tests a Swift Package and gathers its code coverage.",
        version: "0.1.0" + {
            #if DEBUG
            return "-debug"
            #else
            return ""
            #endif
        }()
    )
    
    enum CodingKeys: CodingKey {
        case options
    }

    @OptionGroup
    var options: Options

    /// The process being used for the current `shellOut` command being run if any.
    var process: Process?

    /// The spinner being used to show that progress is being made.
    var spinner: Spinner = Spinner(pattern: .dots)

    public init() {}
}

// MARK: - Run
extension SwiftPackageCoverageCommand {
    public mutating func run() {
        Signals.handle(.interrupt) { [self] _ in
            exit()
        }

        hideCursor()
        startSpinnerIfNeeded()

        stepRunSwiftTestWithCoverage()
        stepSuccess()

        let coverageFilePath = stepFindCoverageFilePath()
        stepSuccess()

        let coverage = stepProcessCoverageFile(atPath: coverageFilePath)
        stepSuccess()

        stepOutputResults(coverage: coverage)

        spinner.stopAndClear()
        spinner.unhideCursor()
    }
}

// MARK: - Steps
extension SwiftPackageCoverageCommand {
    /// Runs `swift test` and generates the coverage file.
    mutating func stepRunSwiftTestWithCoverage() {
        guard !options.skipRun else {
            return
        }

        let arguments = options.swiftArguments
        guard !options.dryRun else {
            print("swift test --enable-code-coverage", terminator: "")
            if !arguments.isEmpty {
                print("", arguments.joined(separator: " "))
            }
            exit(withError: ExitCode.success)
        }
        advanceStep(to: "Running Tests")

        do {
            let process = Process()
            self.process = process
            defer { self.process = nil }
            try shellOut(
                to: "swift test",
                arguments: ["--enable-code-coverage"] + arguments,
                at: options.runPath,
                process: process
            )
        } catch let error as ShellOutError {
            print(error.output)
            print(error.message)
            exit(withError: ExitError(description: "Unable to run swift tests and gather coverage."))
        } catch {
            exit(withError: ExitError(description: "Unknown Error. Unable to run swift tests and gather coverage. \(error)"))
        }
    }
    
    /// Finds the coverage file that should be processed.
    mutating func stepFindCoverageFilePath() -> String {
        advanceStep(to: "Finding Coverage File")
        do {
            let process = Process()
            self.process = process
            defer { self.process = nil }
            return try shellOut(
                to: "swift test",
                arguments: ["--show-codecov-path"] + options.swiftArguments,
                at: options.runPath,
                process: process
            )
        } catch let error as ShellOutError {
            print(error.output)
            print(error.message)
            exit(withError: ExitError(description: "Unknown Error. Unable to find coverage file."))
        } catch {
            exit(withError: ExitError(description: "Unknown Error. Unable to find coverage file. \(error)"))
        }
    }

    /// Open and process the coverage JSON file.
    ///
    /// This will remove files that aren't applicable and recalculate totals to create an updated version of the JSON.
    func stepProcessCoverageFile(atPath path: String) -> JSON {
        advanceStep(to: "Processing Coverage File")
        let coverage: JSON
        do {
            let json = try Data(contentsOf: URL(fileURLWithPath: path))
            coverage = try .init(data: json)
        } catch {
            exit(withError: ExitError(description: "Unable to open coverage JSON file: \(path)."))
        }

        // See Documentation/llvm-cov-2.0.1.md for details on this spec.
        var processedCoverage: JSON = [:]
        processedCoverage[.type] = coverage[.type]
        processedCoverage[.version] = coverage[.version]

        let filesData = JSON(coverage[.data].array?[0][.files].arrayValue.filter { file in
            guard let filePath = file[.filename].string else {
                exit(withError: ExitError(description: "Unexpected JSON format. Unable to parse file data:\n\(file)"))
            }
            return shouldInclude(filePath: filePath)
        } ?? [])

        let functionsData = JSON(coverage[.data].array?[0][.functions].arrayValue.filter { function in
            guard let fileNames = function[.filenames].array?.compactMap(\.string) else {
                exit(withError: ExitError(description: "Unexpected JSON format. Unable to parse function data:\n\(function)"))
            }
            for filePath in fileNames where shouldInclude(filePath: filePath) {
                return true
            }
            return false
        } ?? [])

        let totalSections: [LLVMCovPath] = [.branches, .functions, .instantiations, .lines, .regions]

        var totalsData: JSON = [:]
        for section in totalSections {
            totalsData[section] = [:]
            totalsData[section][.count] = 0
            totalsData[section][.covered] = 0

            if section == .branches || section == .regions {
                totalsData[section][.notcovered] = 0
            }
        }

        for file in filesData.arrayValue {
            for section in totalSections {
                let summary = file[.summary][section]
                totalsData[section][.count].intValue += summary[.count].intValue
                totalsData[section][.covered].intValue += summary[.covered].intValue

                if section == .branches || section == .regions {
                    totalsData[section][.notcovered].intValue += summary[.notcovered].intValue
                }
            }
        }

        for section in totalSections {
            var percentage = 100.0 * totalsData[section][.covered].doubleValue / totalsData[section][.count].doubleValue
            if !percentage.isNormal {
                percentage = 0.0
            }
            totalsData[section][.percent].doubleValue = percentage
        }

        var exportData: JSON = [:]
        exportData[.files] = filesData
        exportData[.functions] = functionsData
        exportData[.totals] = totalsData
        processedCoverage[.data] = [exportData]
        return processedCoverage
    }

    /// Write the coverage data to the appropriate places according to options.
    func stepOutputResults(coverage: JSON) {
        spinner.stopAndClear()

        let totals = coverage[.data].arrayValue[0][.totals]
        let section: JSON

        switch options.llvmTotalType {
        case .branches:
            section = totals[.branches]
        case .functions:
            section = totals[.functions]
        case .instantiations:
            section = totals[.instantiations]
        case .lines:
            section = totals[.lines]
        case .regions:
            section = totals[.regions]
        }
        
        // If progress is being shown then give it some space from the results
        if options.progressMode != .noProgress && (options.showLineCounts || options.showPercentage) {
            print()
        }

        if options.showLineCounts {
            print("""
               Covered: \(section[.covered].intValue)
                 Total: \(section[.count].intValue)
            """)
        }

        if options.showPercentage {
            print("""
            Percentage: \(String(format: "%0.4f", section[.percent].doubleValue))
            """)
        }

        if let llvmCovJSONOutputPath = options.llvmCovJSONOutputPath {
            do {
                var data = try coverage.rawData(options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
                data.append("\n".data(using: .utf8)!)
                try data.write(to: URL(fileURLWithPath: llvmCovJSONOutputPath))
            } catch {
                exit(withError: ExitError(description: "Unable to write llvm-cov JSON file to: \(llvmCovJSONOutputPath)."))
            }
        }
    }
}

// MARK: - Step Helpers
extension SwiftPackageCoverageCommand {
    /// Hides the cursor while running.
    ///
    /// This is needed because the spinner normally hides it but when running without the spinner running we still want to hide it.
    func hideCursor() {
        print("\u{001B}[?25l", terminator: "")
    }
    
    /// If running in a mode that should start the spinner, start it.
    func startSpinnerIfNeeded() {
        guard options.progressMode == .fullProgress && spinner.isRunning == false else {
            return
        }
        spinner.start()
    }

    /// A step has been successful, so mark it as so and setup for the next step.
    func stepSuccess() {
        switch options.progressMode {
        case .noProgress:
            return
        case .progressSteps:
            clearLine()
            print("✔".green, spinner.text)
        case .fullProgress:
            spinner.succeed()
            spinner.text = ""
        }
    }

    func advanceStep(to text: String) {
        switch options.progressMode {
        case .noProgress:
            return
        case .progressSteps:
            spinner.text = text
            print(" ", text, terminator: "")
            // No idea why a flush is needed here. But without it the previous print doesn't get written to the console.
            fflush(stdout)
        case .fullProgress:
            spinner.text = text
            startSpinnerIfNeeded()
        }
    }

    func shouldInclude(filePath: String) -> Bool {
        var isInIncludePaths: Bool {
            options.includedPaths.contains(where:) { includedPath in
                filePath.contains(includedPath)
            }
        }

        var isInExcludedPaths: Bool {
            options.excludedPaths.contains(where:) { excludedPath in
                filePath.contains(excludedPath)
            }
        }

        var isInHiddenDirectory: Bool {
            filePath.components(separatedBy: "/").contains(where:) { $0.first == "." && $0.count > 1 && $0 != ".." }
        }

        return isInIncludePaths && !isInExcludedPaths && (options.includeHiddenDirectories ? true : !isInHiddenDirectory)
    }
    
    struct ExitError: Swift.Error, CustomStringConvertible {
        let description: String
    }
    
    func clearLine() {
        print("\r", terminator: "")
        fflush(stdout)
    }

    /// The same as Self.exit(withError:) but it stops the running process and/or cleans up the consoles progress state.
    func exit(withError error: Error? = nil) -> Never {
        if let process = process,
           process.isRunning {
            process.interrupt()
            process.terminate()
        }
        
        switch options.progressMode {
        case .noProgress:
            break
        case .progressSteps:
            clearLine()
            print("✖".red, spinner.text)
        case .fullProgress:
            spinner.fail()
        }

        spinner.unhideCursor()
        print()
        Self.exit(withError: error)
    }
}
