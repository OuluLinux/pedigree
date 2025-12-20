#!/bin/bash

# Script that can be run to set up a Pedigree repository for building with minimal
# effort.

# TODO: fix this up as it's currently in the middle of migrating from scons -> cmake

# Use English locale for consistent error messages
export LC_ALL=C.UTF-8

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

old=$(pwd)
script_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P) && script_dir=$script_dir
cd $old

# Function to perform cleanup
clean_build() {
    echo "Cleaning build artifacts..."

    # Remove build directories
    rm -rf build-host
    rm -rf build
    rm -rf external

    # Remove compiler build temporary files
    if [ -d "$script_dir/pedigree-compiler/build_tmp" ]; then
        rm -rf "$script_dir/pedigree-compiler/build_tmp"
    fi

    # Remove compiler directory if it exists
    if [ -L "$script_dir/compilers/dir" ]; then
        compiler_dir=$(readlink "$script_dir/compilers/dir")
        if [ -d "$compiler_dir/build_tmp" ]; then
            rm -rf "$compiler_dir/build_tmp"
        fi
    fi

    echo "Build artifacts cleaned."
}

# If --clean flag is provided, clean and exit
if [ $CLEAN_ONLY -eq 1 ]; then
    clean_build
    exit 0
fi

COMPILER_DIR=$script_dir/pedigree-compiler
. $script_dir/build-etc/travis.sh

set -e

. $script_dir/scripts/easy_build_deps.sh

echo "Please wait, checking for a working cross-compiler."
echo "If none is found, the source code for one will be downloaded, and it will be"
echo "compiled for you."

# Special parameters for some operating systems when building cross-compilers
case $real_os in
    osx)
        compiler_build_options="$compiler_build_options osx-compat"
        ;;
esac

# Install cross-compilers
$script_dir/scripts/checkBuildSystemNoInteractive.pl x86_64-pedigree $COMPILER_DIR $compiler_build_options

old=$(pwd)
cd $script_dir


git submodule update --init --recursive


set +e

# Update the local working copy only if it is clean.
changed=`git status -s -uno`
if [ -z "$changed" ]; then
    git pull --rebase > /dev/null 2>&1
fi

echo
echo "Configuring the Pedigree UPdater..."

$script_dir/setup_pup.py amd64

# Try to sync packages, but continue if the server is unreachable
$script_dir/run_pup.sh sync || echo "Warning: Could not sync packages from server. Continuing with build..."

# Needed for libc
$script_dir/run_pup.sh install ncurses || echo "Warning: Could not install ncurses from server. Continuing with build..."

# Run a quick build of libc and libm for the rest of the build system only if it hasn't been built already.
if [ ! -f "$script_dir/build/musl/lib/libc.so" ] || [ ! -f "$script_dir/build/musl/lib/libc.a" ]; then
    echo "Building libc/libm..."
    scons hosted=1 CROSS=$script_dir/compilers/dir/bin/x86_64-pedigree- build/musl/lib/libc.so
else
    echo "libc/libm already built. Skipping."
fi

# Pull down libtool.
if ! $script_dir/run_pup.sh install libtool; then
    echo "Warning: Could not install libtool from server. Attempting to build from source..."

    # Try to build libtool from source
    if [ -f "$script_dir/scripts/build-libtool.sh" ]; then
        echo "Building libtool from source..."
        # Create external directory for libtool build
        mkdir -p "$script_dir/external"
        # Build libtool with appropriate parameters
        SRCDIR="$script_dir" TARGETDIR="$script_dir/../images/local" bash "$script_dir/scripts/build-libtool.sh"
    else
        echo "libtool build script not found. Continuing without libtool..."
    fi
fi

# Enforce using our libtool.
export LIBTOOL=$script_dir/../images/local/applications:$PATH

# Build GCC again with access to the newly built libc.
# This will create a libstdc++ that can be used by pedigree-apps to build GCC
# again, this time with a shared libstdc++. pedigree-apps should then build GCC
# again to build it against the shared libstdc++. Once a working shared
# libstdc++ exists, the static one built here is no longer relevant.
# What a mess!
$script_dir/scripts/checkBuildSystemNoInteractive.pl x86_64-pedigree $COMPILER_DIR $compiler_build_options "libcpp"

set +e

echo
echo "Ensuring CDI is up-to-date."

# Setup all submodules, make sure they are up-to-date
git submodule init > /dev/null 2>&1
git submodule update > /dev/null 2>&1

# Function to check if packages exist in pedigree-apps and install from there if needed
install_package_from_local() {
    local package=$1

    # Try pup install first
    if $script_dir/run_pup.sh install $package; then
        verbose "Successfully installed $package from server."
    else
        # If server fails, try to install from local pedigree-apps if available
        if [ -d "../pedigree-apps/packages/$package" ]; then
            verbose "Installing $package from local pedigree-apps..."
            # Build and install the package from pedigree-apps if possible
            if [ -f "../pedigree-apps/packages/$package/build.sh" ]; then
                cd ../pedigree-apps/packages/$package
                bash build.sh || echo "Warning: Could not build $package from local source."
                cd $old
            fi
        else
            echo "Warning: Could not install $package from server or local source. Some functionality may be missing."
        fi
    fi
}

echo
echo "Installing a base set of packages..."

# Install packages - first try from server, then from local pedigree-apps if available
install_package_from_local "pedigree-base"
install_package_from_local "libpng"
install_package_from_local "libfreetype"
install_package_from_local "libiconv"
install_package_from_local "zlib"

install_package_from_local "bash"
install_package_from_local "coreutils"
install_package_from_local "fontconfig"
install_package_from_local "pixman"
install_package_from_local "cairo"
install_package_from_local "expat"
install_package_from_local "mesa"
install_package_from_local "gettext"

install_package_from_local "pango"
install_package_from_local "glib"
install_package_from_local "libpcre"
install_package_from_local "harfbuzz"
install_package_from_local "libffi"
install_package_from_local "dialog"

# Install GCC to pull in shared libstdc++.
install_package_from_local "gcc"

set -e

echo
echo "Beginning the Pedigree build."
echo

# Build Pedigree.
scons hosted=1 CROSS=$script_dir/compilers/dir/bin/x86_64-pedigree- $TRAVIS_OPTIONS

# One day we might fix this bug (create proper disk image with built apps).
scons hosted=1 $TRAVIS_OPTIONS

cd "$old"

echo
echo
echo "Pedigree is now ready to be built without running this script."
echo "To build in future, run the following command in the '$script_dir' directory:"
echo "scons"
echo
echo "If you wish, you can continue to run this script. It won't ask questions"
echo "anymore, unless you remove the '.easy_os' file in '$script_dir'."
echo
echo "You can also run scons --help for more information about options."
echo
echo "Patches should be posted in the issue tracker at http://pedigree-project.org/projects/pedigree/issues"
echo "Support can be found in #pedigree on irc.freenode.net."
echo
echo "Have fun with Pedigree! :)"

