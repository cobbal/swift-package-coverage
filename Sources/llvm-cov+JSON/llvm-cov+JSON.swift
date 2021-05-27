//
//  llvm-cov+JSON.swift
//  swift-package-coverage
//
//  Created by Braden Scothern on 5/26/21.
//  Copyright © 2021 Braden Scothern. All rights reserved.
//

import SwiftyJSON

/// All of the properties that can be in the llvm-cov files.
///
/// This exists to make it nicer to work with JSON and ensure that these are being accessed with correct spellings etc but they might not exist at a certain layer just like normal JSON that isn't being validated.
public enum LLVMCovPath: String {
    case data
    case files
    case branches
    case expansions
    case filename
    case filenames
    case summary
    case count
    case covered
    case notcovered
    case percent
    case functions
    case instantiations
    case lines
    case regions
    case segments
    case name
    case totals
    case type
    case version
}

extension JSON {
    public subscript(llvmCovPath: LLVMCovPath) -> JSON {
        get {
            self[llvmCovPath.rawValue]
        }
        set {
            self[llvmCovPath.rawValue] = newValue
        }
        _modify {
            yield &self[llvmCovPath.rawValue]
        }
    }
}
