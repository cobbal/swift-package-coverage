# swift-package-coverage

A utility that runs runs tests on a swift package and gathers the coverage data.

## Code Coverge Issues
The llvm-cov files do not properly mark when a `deinit` is called during testing.
This results in them always having 0% code coverage even if they run.
Xcode will also show this if you go to the coverage report despite the in file code coverage mechanism showing that it is covered.

## Development Tips
When testing with SwiftPM you will need to use the command: `swift run --disable-sandbox package-coverage [package-coverage arguments]`.
If you don't disable the sandbox then the `swift test --enable-code-coverage` command will fail.
