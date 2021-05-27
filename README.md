# swift-package-coverage

A utility that runs runs tests on a swift package and gathers the coverage data.

## Development Tips
When testing with SwiftPM you will need to use the command: `swift run --disable-sandbox package-coverage [package-coverage arguments]`.
If you don't disable the sandbox then the `swift test --enable-code-coverage` command will fail.
