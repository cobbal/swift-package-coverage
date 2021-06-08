# swift-package-coverage

A utility that runs runs tests on a swift package and gathers the coverage data.

## Usage
Inside your swift package run the command:
```zsh
swift package-coverage
```

By default this will create output like this finding coverage of typical source file locations:
```
   Covered: 1395
     Total: 2033
Percentage: 68.61780619773734
```

Where the Covered and Total are the number of lines found in the package.
If this isn't what you want or you need to customize paths or your build you can see all the options by running:
```zsh
swift package-coverage --help
```

## Installation
Brew:
```zsh
echo "TODO"
```

Manual:
```zsh
git clone https://github.com/bscothern/swift-package-coverage
cd swift-package-coverage
make install
```

## Code Coverge Issues
The llvm-cov files do not properly mark when a `deinit` is called during testing.
This results in them always having 0% code coverage even if they run.
Xcode will also show this if you go to the coverage report despite the in file code coverage mechanism showing that it is covered.
So your code coverage will likely be lower than you expect if you are testing your `deinit`s.

## Development Tips
When testing with SwiftPM you will need to use the command: `swift run --disable-sandbox package-coverage [package-coverage arguments]`.
If you don't disable the sandbox then the `swift test --enable-code-coverage` command will fail.
