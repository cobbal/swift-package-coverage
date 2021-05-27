//
//  SwiftPackageCoverage.swift
//  swift-package-coverage
//
//  Created by Braden Scothern on 5/26/21.
//  Copyright © 2021 Braden Scothern. All rights reserved.
//

import ArgumentParser
import OptionsModule
import ShellOut

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
        runSwiftTest()
    }
    
    func runSwiftTest() {
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
            Self.exit(withError: ExitError(description: "Unable to run swift tests and gather coverage"))
        } catch {
            Self.exit(withError: ExitError(description: "Unknown Error. Unable to run swift tests and gather coverage"))
        }
    }
}

SwiftPackageCoverageCommand.main()
