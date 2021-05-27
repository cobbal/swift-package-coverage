#  llvm-cov 2.0.1

[Main Documentation](https://clang.llvm.org/docs/SourceBasedCodeCoverage.html)

<br>

[JSON Format Description](https://github.com/llvm/llvm-project/blob/8f23fac4da254e8cd2a3160a4fa029613a284ebe/llvm/tools/llvm-cov/CoverageExporterJson.cpp):

    Root: dict => Root Element containing metadata
    -- Data: array => Homogeneous array of one or more export objects
    -- Export: dict => Json representation of one CoverageMapping
        -- Files: array => List of objects describing coverage for files
        -- File: dict => Coverage for a single file
            -- Branches: array => List of Branches in the file
            -- Branch: dict => Describes a branch of the file with counters
            -- Segments: array => List of Segments contained in the file
            -- Segment: dict => Describes a segment of the file with a counter
            -- Expansions: array => List of expansion records
            -- Expansion: dict => Object that descibes a single expansion
                -- CountedRegion: dict => The region to be expanded
                -- TargetRegions: array => List of Regions in the expansion
                -- CountedRegion: dict => Single Region in the expansion
                -- Branches: array => List of Branches in the expansion
                -- Branch: dict => Describes a branch in expansion and counters
            -- Summary: dict => Object summarizing the coverage for this file
            -- LineCoverage: dict => Object summarizing line coverage
            -- FunctionCoverage: dict => Object summarizing function coverage
            -- RegionCoverage: dict => Object summarizing region coverage
            -- BranchCoverage: dict => Object summarizing branch coverage
        -- Functions: array => List of objects describing coverage for functions
        -- Function: dict => Coverage info for a single function
            -- Filenames: array => List of filenames that the function relates to
    -- Summary: dict => Object summarizing the coverage for the entire binary
        -- LineCoverage: dict => Object summarizing line coverage
        -- FunctionCoverage: dict => Object summarizing function coverage
        -- InstantiationCoverage: dict => Object summarizing inst. coverage
        -- RegionCoverage: dict => Object summarizing region coverage
        -- BranchCoverage: dict => Object summarizing branch coverage
