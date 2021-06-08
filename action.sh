SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
EXECUTABLE=${SCRIPT_DIR}/.build/release/package-coverage

make -C ${SCRIPT_DIR} build-release

${EXECUTABLE} --version
${EXECUTABLE} $@
