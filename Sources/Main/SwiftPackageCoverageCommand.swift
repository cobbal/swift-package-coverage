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
    var arguments: [String] {
        var arguments: [String] = []
        arguments.append(
            contentsOf: swiftBuildFlags.beforeEachValue(insert: "-Xswiftc")
        )
        arguments.append(
            contentsOf: cBuildFlags.beforeEachValue(insert: "-Xcc")
        )
        arguments.append(
            contentsOf: cxxBuildFlags.beforeEachValue(insert: "-Xcxx")
        )
        arguments.append(
            contentsOf: linkerFlags.beforeEachValue(insert: "-Xlinker")
        )
        return arguments
    }
}

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
            print(arguments.joined(separator: " "))
            Self.exit(withError: ExitCode.success)
        }
        do {
            let output = try shellOut(
                to: "swift test",
                arguments: ["--enable-code-coverage"] + arguments,
                at: options.runPath
            )
            print(output)
            print("DONE")
        } catch let error as ShellOutError {
            print("----------------")
            print(error.message)
            print()
            print(error.output)
            print()
            Self.exit(withError: ExitError(description: "Unable to run swift tests and gather coverage"))
        } catch {
            Self.exit(withError: ExitError(description: "Unknown Error. Unable to run swift tests and gather coverage"))
        }
    }
}



SwiftPackageCoverageCommand.main()
