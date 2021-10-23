# swift-package-coverage

A utility that runs runs tests on a swift package and gathers the coverage data.

## Usage
Inside your swift package run the command:
```zsh
swift package-coverage
```

By default this will create output like this finding coverage of typical source file locations:
```
   Covered: 1451
     Total: 1936
Percentage: 74.9483
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
The llvm-cov files do not always mark when a `deinit` is called during testing.
This results in them always having 0% code coverage even if they run.
Xcode will also show this if you go to the coverage report despite the in file code coverage mechanism showing that it is covered.
So your code coverage will likely be lower than you expect if you are testing your `deinit`s.
If this is happening then you can move all of your `deinit` logic out into another function and call it in your `deinit`.
It will then correctly gather coverage for that function even if it still fails to do so for the traditional `deinit`.

## Development Tips
When testing with SwiftPM you will need to use the command: `swift run --disable-sandbox package-coverage [package-coverage arguments]`.
If you don't disable the sandbox then the `swift test --enable-code-coverage` command will fail more often than not.
Even with the `--enable-code-coverage` sometimes a build will fail so in that case just run again.
