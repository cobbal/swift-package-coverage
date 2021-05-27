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
public struct LLVMCovPath {
    public let data: Any
    public let files: Any
    public let branches: Any
    public let expansions: Any
    public let filename: Any
    public let summary: Any
    public let count: Any
    public let covered: Any
    public let notcovered: Any
    public let percent: Any
    public let functions: Any
    public let instantiations: Any
    public let lines: Any
    public let regions: Any
    public let segments: Any
    public let name: Any
    public let totals: Any
    public let type: Any
    public let version: Any
}

extension JSON {
    public subscript(llvmCovPath: KeyPath<LLVMCovPath, Any>) -> JSON {
        switch llvmCovPath {
        case \LLVMCovPath.data:
            return self["data"]
        case \LLVMCovPath.files:
            return self["files"]
        case \LLVMCovPath.branches:
            return self["branches"]
        case \LLVMCovPath.expansions:
            return self["expansions"]
        case \LLVMCovPath.filename:
            return self["filename"]
        case \LLVMCovPath.summary:
            return self["summary"]
        case \LLVMCovPath.count:
            return self["count"]
        case \LLVMCovPath.covered:
            return self["covered"]
        case \LLVMCovPath.notcovered:
            return self["notcovered"]
        case \LLVMCovPath.percent:
            return self["percent"]
        case \LLVMCovPath.functions:
            return self["functions"]
        case \LLVMCovPath.instantiations:
            return self["instantiations"]
        case \LLVMCovPath.lines:
            return self["lines"]
        case \LLVMCovPath.regions:
            return self["regions"]
        case \LLVMCovPath.segments:
            return self["segments"]
        case \LLVMCovPath.name:
            return self["name"]
        case \LLVMCovPath.totals:
            return self["totals"]
        case \LLVMCovPath.type:
            return self["type"]
        case \LLVMCovPath.version:
            return self["version"]
        default:
            fatalError("Unknown KeyPath")
        }
    }
}
