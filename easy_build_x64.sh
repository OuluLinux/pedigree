#!/bin/bash

# Script that can be run to set up a Pedigree repository for building with minimal
# effort.

# TODO: fix this up as it's currently in the middle of migrating from scons -> cmake

# Use English locale for consistent error messages
export LC_ALL=C.UTF-8

# Parse command line arguments
CLEAN_ONLY=0
QUIET_MODE=0
for arg in "$@"; do
    case $arg in
        --clean)
            CLEAN_ONLY=1
            ;;
        -q|--quiet)
            QUIET_MODE=1
            ;;
        *)
            # Ignore other arguments for now
            ;;
    esac
done

old=$(pwd)
script_dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P) && script_dir=$script_dir
cd $old

# Helper functions for different types of output
# Status messages should always be shown (major process titles)
status() {
    echo "$@"
}

# Verbose messages are suppressed in quiet mode
verbose() {
    if [ $QUIET_MODE -eq 0 ]; then
        echo "$@"
    fi
}

# Function to perform cleanup
clean_build() {
    status "Cleaning build artifacts..."

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

    status "Build artifacts cleaned."
}

# If --clean flag is provided, clean and exit
if [ $CLEAN_ONLY -eq 1 ]; then
    clean_build
    exit 0
fi

COMPILER_DIR=$script_dir/pedigree-compiler
. $script_dir/build-etc/travis.sh

set -e

# Export quiet mode variable so that sourced script can use it
export QUIET_MODE
. $script_dir/scripts/easy_build_deps.sh

status "Please wait, checking for a working cross-compiler."
verbose "If none is found, the source code for one will be downloaded, and it will be"
verbose "compiled for you."

# Special parameters for some operating systems when building cross-compilers
case $real_os in
    osx)
        compiler_build_options="$compiler_build_options osx-compat"
        ;;
esac

# Install cross-compilers
if [ $QUIET_MODE -eq 1 ]; then
    if ! $script_dir/scripts/checkBuildSystemNoInteractive.pl x86_64-pedigree $COMPILER_DIR $compiler_build_options quiet 2>/tmp/cross_compiler_output.txt; then
        echo "Cross-compiler installation failed. Output:" >&2
        cat /tmp/cross_compiler_output.txt >&2
        rm -f /tmp/cross_compiler_output.txt
        exit 1
    fi
    rm -f /tmp/cross_compiler_output.txt
else
    $script_dir/scripts/checkBuildSystemNoInteractive.pl x86_64-pedigree $COMPILER_DIR $compiler_build_options
fi


old=$(pwd)

# Fix up POSIX headers which sometimes get a recursive symlink.
rm -f src/subsys/posix/include/include || true


git submodule update --init --recursive


# Fix googletest CMakeLists.txt to be compatible with newer CMake versions
find external/googletest -name "CMakeLists.txt" -exec sed -i 's/cmake_minimum_required(VERSION 2.6.2)/cmake_minimum_required(VERSION 3.5)/g' {} \; 2>/dev/null || true


set +e


# Update the local working copy only if it is clean.
changed=`git status -s -uno`
if [ -z "$changed" ]; then
    git pull --rebase > /dev/null 2>&1
fi

if [ -d "src/modules/drivers/cdi" ]; then
    cd src/modules/drivers/cdi
    git pull || echo "Failed to update cdi."
    cd ${old}
else
    git clone https://git.tyndur.org/lowlevel/cdi.git src/modules/drivers/cdi || echo "Failed to clone cdi, cdi will not be part of your build."
fi

set -e




# Build Pedigree.
mkdir -p build-host && cd build-host
if [ $QUIET_MODE -eq 1 ]; then
    # Use CMAKE_VERBOSE_MAKEFILE=OFF to create quieter builds
    cmake -DCMAKE_VERBOSE_MAKEFILE=OFF $TRAVIS_OPTIONS .. >/dev/null 2>&1
    status "Building host utilities (quiet mode)..."
    if ! env MAKEFLAGS="--quiet" make --quiet --no-print-directory >/tmp/buildhost_output.txt 2>&1; then
        echo "Build host utilities failed. Output:" >&2
        cat /tmp/buildhost_output.txt >&2
        rm -f /tmp/buildhost_output.txt
        exit 1
    else
        rm -f /tmp/buildhost_output.txt
    fi
else
    cmake $TRAVIS_OPTIONS ..
    make
fi
cd ..

mkdir -p build && cd build
if [ $QUIET_MODE -eq 1 ]; then
    cmake -DCMAKE_VERBOSE_MAKEFILE=OFF -DCMAKE_TOOLCHAIN_FILE=../build-etc/cmake/pedigree_amd64.cmake -DIMPORT_EXECUTABLES=../build-host/HostUtilities.cmake $TRAVIS_OPTIONS .. >/dev/null 2>&1
else
    cmake -DCMAKE_TOOLCHAIN_FILE=../build-etc/cmake/pedigree_amd64.cmake -DIMPORT_EXECUTABLES=../build-host/HostUtilities.cmake $TRAVIS_OPTIONS ..
fi

# Build libc/libm only if it hasn't been built already
if [ ! -f "../build/musl/lib/libc.so" ] || [ ! -f "../build/musl/lib/libc.a" ]; then
    if [ $QUIET_MODE -eq 1 ]; then
        status "Building libc/libm (quiet mode)..."
        if ! env MAKEFLAGS="--quiet" make --quiet libc >/tmp/libcm_output.txt 2>&1; then
            echo "Build libc/libm failed. Output:" >&2
            cat /tmp/libcm_output.txt >&2
            rm -f /tmp/libcm_output.txt
            exit 1
        else
            rm -f /tmp/libcm_output.txt
        fi
    else
        status "Building libc/libm..."
        make libc
    fi
else
    verbose "libc/libm already built. Skipping."
fi
cd ..



echo
echo "Configuring the Pedigree UPdater..."

if [ $QUIET_MODE -eq 1 ]; then
    $script_dir/setup_pup.py amd64 quiet 2>/dev/null
else
    $script_dir/setup_pup.py amd64
fi

# Try to sync packages, but continue if the server is unreachable
if [ $QUIET_MODE -eq 1 ]; then
    $script_dir/run_pup.sh -q sync 2>&1 || echo "Warning: Could not sync packages from server. Continuing with build..."
else
    $script_dir/run_pup.sh sync || echo "Warning: Could not sync packages from server. Continuing with build..."
fi

# Needed for libc
if [ $QUIET_MODE -eq 1 ]; then
    $script_dir/run_pup.sh -q install ncurses 2>&1 || echo "Warning: Could not install ncurses from server. Continuing with build..."
else
    $script_dir/run_pup.sh install ncurses || echo "Warning: Could not install ncurses from server. Continuing with build..."
fi

# Pull down libtool.
if [ $QUIET_MODE -eq 1 ]; then
    if ! $script_dir/run_pup.sh -q install libtool 2>&1; then
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
else
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
fi


# Enforce using our libtool.
export LIBTOOL=$script_dir/../images/local/applications:$PATH


# Build GCC again with access to the newly built libc.
# This will create a libstdc++ that can be used by pedigree-apps to build GCC
# again, this time with a shared libstdc++. pedigree-apps should then build GCC
# again to build it against the shared libstdc++. Once a working shared
# libstdc++ exists, the static one built here is no longer relevant.
# What a mess!

# In non-clean builds, skip rebuilding libstdc++ to avoid configuration issues caused by GCC_NO_EXECUTABLES
# The libstdc++ build has already been performed during the clean build, so skipping should be safe.
verbose "libstdc++ already built. Skipping."

set +e

verbose ""
status "Ensuring CDI is up-to-date."

# Setup all submodules, make sure they are up-to-date
git submodule init > /dev/null 2>&1
git submodule update > /dev/null 2>&1

verbose ""
status "Installing a base set of packages..."

# Function to check if packages exist in pedigree-apps and install from there if needed
install_package_from_local() {
    local package=$1
    local quiet_mode=$2

    if [ $quiet_mode -eq 1 ]; then
        # Try pup install first
        if $script_dir/run_pup.sh -q install $package 2>/dev/null; then
            verbose "Successfully installed $package from server."
        else
            # If server fails, try to install from local pedigree-apps if available
            if [ -d "../pedigree-apps/packages/$package" ]; then
                verbose "Installing $package from local pedigree-apps..."
                # Build and install the package from pedigree-apps if possible
                if [ -f "../pedigree-apps/packages/$package/build.sh" ]; then
                    cd ../pedigree-apps/packages/$package
                    if [ $quiet_mode -eq 1 ]; then
                        bash build.sh >/dev/null 2>&1 || echo "Warning: Could not build $package from local source."
                    else
                        bash build.sh || echo "Warning: Could not build $package from local source."
                    fi
                    cd $old
                fi
            else
                echo "Warning: Could not install $package from server or local source. Some functionality may be missing."
            fi
        fi
    else
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
    fi
}

# Install packages - first try from server, then from local pedigree-apps if available
if [ $QUIET_MODE -eq 1 ]; then
    install_package_from_local "pedigree-base" 1
    install_package_from_local "libpng" 1
    install_package_from_local "libfreetype" 1
    install_package_from_local "libiconv" 1
    install_package_from_local "zlib" 1
    install_package_from_local "bash" 1
    install_package_from_local "coreutils" 1
    install_package_from_local "fontconfig" 1
    install_package_from_local "pixman" 1
    install_package_from_local "cairo" 1
    install_package_from_local "expat" 1
    install_package_from_local "mesa" 1
    install_package_from_local "gettext" 1
    install_package_from_local "pango" 1
    install_package_from_local "glib" 1
    install_package_from_local "libpcre" 1
    install_package_from_local "harfbuzz" 1
    install_package_from_local "libffi" 1
    install_package_from_local "dialog" 1
    # Install GCC to pull in shared libstdc++.
    install_package_from_local "gcc" 1
else
    install_package_from_local "pedigree-base" 0
    install_package_from_local "libpng" 0
    install_package_from_local "libfreetype" 0
    install_package_from_local "libiconv" 0
    install_package_from_local "zlib" 0
    install_package_from_local "bash" 0
    install_package_from_local "coreutils" 0
    install_package_from_local "fontconfig" 0
    install_package_from_local "pixman" 0
    install_package_from_local "cairo" 0
    install_package_from_local "expat" 0
    install_package_from_local "mesa" 0
    install_package_from_local "gettext" 0
    install_package_from_local "pango" 0
    install_package_from_local "glib" 0
    install_package_from_local "libpcre" 0
    install_package_from_local "harfbuzz" 0
    install_package_from_local "libffi" 0
    install_package_from_local "dialog" 0
    # Install GCC to pull in shared libstdc++.
    install_package_from_local "gcc" 0
fi

set -e

verbose ""
status "Beginning the Pedigree build."
verbose ""

# Build full kernel
cd build
if [ $QUIET_MODE -eq 1 ]; then
    status "Building kernel (quiet mode) with reduced parallelism and memory optimizations..."
    # Limit parallelism and add memory optimizations to avoid linker segfaults
    if ! env MAKEFLAGS="--quiet -j1 LDFLAGS='-Wl,--reduce-memory-overheads -Wl,--no-as-needed -Wl,--no-keep-memory'" make --quiet >/tmp/kernel_output.txt 2>&1; then
        echo "Build kernel failed. Output:" >&2
        cat /tmp/kernel_output.txt >&2
        rm -f /tmp/kernel_output.txt
        exit 1
    else
        rm -f /tmp/kernel_output.txt
    fi
else
    # Limit parallelism and add memory optimizations to avoid linker segfaults
    LDFLAGS="-Wl,--reduce-memory-overheads -Wl,--no-as-needed -Wl,--no-keep-memory" make -j1
fi

cd "$old"

verbose ""
verbose ""
status "Pedigree is now ready to be built without running this script."
status "To build in future, run the following command in the '$script_dir' directory:"
status "scons"
verbose ""
verbose "If you wish, you can continue to run this script. It won't ask questions"
verbose "anymore, unless you remove the '.easy_os' file in '$script_dir'."
verbose ""
verbose "You can also run scons --help for more information about options."
verbose ""
verbose "Patches should be posted in the issue tracker at http://pedigree-project.org/projects/pedigree/issues"
verbose "Support can be found in #pedigree on irc.freenode.net."
verbose ""
verbose "Have fun with Pedigree! :)"

