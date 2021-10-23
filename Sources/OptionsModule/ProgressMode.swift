//
//  ProgressMode.swift
//  swift-package-coverage
//
//  Created by Braden Scothern on 5/27/21.
//  Copyright © 2021 Braden Scothern. All rights reserved.
//

import ArgumentParser

public enum ProgressMode: String, CustomStringConvertible, EnumerableFlag {
    case noProgress = "no-progress"
    case progressSteps = "progress-steps"
    case fullProgress = "full-progress"

    public var description: String { rawValue }

    private static let longestLength = Self.allCases.map(\.rawValue.count).max()!

    public var help: String {
        let helpDescription: String
        switch self {
        case .noProgress:
            helpDescription = """
            Turns off all progress and step notifications. \
            Only the final output will be printed to the console.
            """
        case .progressSteps:
            helpDescription = """
            When a step is started it will be printed to the console. \
            When a step is completed the line will be cleared and then printed again with a completion status marker. \
            No spinner will be shown while the step is running.
            """
        case .fullProgress:
            helpDescription = """
            Shows the current step being run with a progress spinner to show it is still working. \
            When a step is completed it will be printed to the console with with a status marker.
            """
        }

        var help = "\(rawValue)"
        while help.count < Self.longestLength {
            help += " "
        }
        help += "  \(helpDescription)"
        return help
    }
}
