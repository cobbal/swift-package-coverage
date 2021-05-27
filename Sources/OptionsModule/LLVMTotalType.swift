//
//  LLVMTotalType.swift
//  swift-package-coverage
//
//  Created by Braden Scothern on 5/27/21.
//  Copyright © 2021 Braden Scothern. All rights reserved.
//

import ArgumentParser

public enum LLVMTotalType: String, CustomStringConvertible, EnumerableFlag {
    case branches
    case functions
    case instantiations
    case lines
    case regions

    public var description: String { rawValue }
}
