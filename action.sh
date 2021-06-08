EXECUTABLE=.build/release/package-coverage
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

cd ${SCRIPT_DIR}

make build-release
${EXECUTABLE} --version
${EXECUTABLE} $@
