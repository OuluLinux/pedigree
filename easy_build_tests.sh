#!/bin/bash

# Script that can be run to set up a Pedigree repository for building with minimal
# effort.

# Parse command line arguments
CLEAN_ONLY=0
for arg in "$@"; do
    case $arg in
        --clean)
            CLEAN_ONLY=1
            shift
            ;;
        *)
            # Ignore other arguments for now
            ;;
    esac
done

# Function to perform cleanup
clean_build() {
    echo "Cleaning build artifacts..."

    # Remove build directory
    rm -rf build-host

    echo "Build artifacts cleaned."
}

# If --clean flag is provided, clean and exit
if [ $CLEAN_ONLY -eq 1 ]; then
    clean_build
    exit 0
fi

set -e

echo "Pedigree Easy Build"
echo "NOTE: This Easy Build script only builds tools that run on your build" \
    " system; this does not build Pedigree itself. Unless you are specifically" \
    " working on tests or benchmarks, you probably want one of the other Easy" \
    " Build scripts."

mkdir build-host && cd build-host
cmake -DPEDIGREE_WARNINGS=ON ..

make -j1
