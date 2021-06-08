EXECUTABLE=.build/release/package-coverage

make build-release
${EXECUTABLE} --version
${EXECUTABLE} $@
